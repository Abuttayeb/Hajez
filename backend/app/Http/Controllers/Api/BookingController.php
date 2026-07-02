<?php
namespace App\Http\Controllers\Api;
use App\Http\Controllers\Controller;
use App\Models\Booking;
use App\Models\Farm;
use App\Models\Coupon;
use App\Models\CouponUsage;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;
use Carbon\Carbon;

class BookingController extends Controller
{
    public function store(Request $request) {
        $request->validate(['farm_id'=>'required|exists:farms,id','check_in'=>'required|date|after:today','check_out'=>'required|date|after:check_in','guests'=>'required|integer|min:1','coupon_code'=>'nullable|string|max:50']);
        $farm = Farm::findOrFail($request->farm_id);
        if (!$farm->isAvailable($request->check_in,$request->check_out))
            return response()->json(['message'=>'المزرعة غير متاحة في هذه الأيام'],422);
        if ($request->guests > $farm->capacity)
            return response()->json(['message'=>'عدد الأشخاص يتجاوز السعة'],422);

        // حساب السعر ليلة بليلة: الجمعة والسبت بسعر الويكند إن وُجد
        $total = $this->computeTotal($farm, $request->check_in, $request->check_out);

        // تطبيق كوبون الخصم إن وُجد
        $coupon = null; $discount = 0.0;
        if ($request->filled('coupon_code')) {
            $coupon = Coupon::where('code', strtoupper(trim($request->coupon_code)))->first();
            if (!$coupon)
                return response()->json(['message'=>'كوبون غير موجود'],422);
            $check = $coupon->validateFor($request->user()->id, $total);
            if (!$check['valid'])
                return response()->json(['message'=>$check['message']],422);
            $discount = $check['discount'];
        }

        $booking = Booking::create(['user_id'=>$request->user()->id,'farm_id'=>$request->farm_id,'check_in'=>$request->check_in,'check_out'=>$request->check_out,'guests'=>$request->guests,'total_price'=>round($total - $discount, 2),'coupon_id'=>$coupon?->id,'discount_amount'=>$discount,'payment_method'=>$request->payment_method??'cash','notes'=>$request->notes]);

        if ($coupon) {
            CouponUsage::create(['coupon_id'=>$coupon->id,'user_id'=>$request->user()->id,'booking_id'=>$booking->id,'discount_amount'=>$discount]);
        }

        // إشعار المالك
        $owner = $farm->owner;
        if ($owner && $owner->fcm_token) {
            $this->sendFcmNotification(
                $owner->fcm_token,
                'حجز جديد! 🎉',
                "تم حجز {$farm->name} من {$request->check_in} إلى {$request->check_out}"
            );
        }

        return response()->json(['message'=>'تم الحجز بنجاح','booking'=>$booking->load(['farm','user'])],201);
    }

    /**
     * حساب المجموع ليلة بليلة: ليالي الجمعة والسبت بسعر الويكند إن كان محدداً.
     */
    private function computeTotal(Farm $farm, string $checkIn, string $checkOut): float {
        $base = (float)$farm->price_per_night;
        $weekend = $farm->price_per_night_weekend ? (float)$farm->price_per_night_weekend : $base;
        $total = 0.0;
        $night = Carbon::parse($checkIn);
        $end = Carbon::parse($checkOut);
        while ($night->lt($end)) {
            // Carbon: الجمعة = 5، السبت = 6
            $total += in_array($night->dayOfWeek, [Carbon::FRIDAY, Carbon::SATURDAY]) ? $weekend : $base;
            $night->addDay();
        }
        return round($total, 2);
    }

    private function sendFcmNotification(string $token, string $title, string $body): void {
        $serverKey = env('FCM_SERVER_KEY');
        if (!$serverKey) return;
        Http::withHeaders([
            'Authorization' => 'key=' . $serverKey,
            'Content-Type' => 'application/json',
        ])->post('https://fcm.googleapis.com/fcm/send', [
            'to' => $token,
            'notification' => ['title' => $title, 'body' => $body],
        ]);
    }

    public function myBookings(Request $request) {
        return response()->json(Booking::with(['farm.images','farm.owner','review'])->where('user_id',$request->user()->id)->latest()->get());
    }
    public function show(Request $request,$id) {
        return response()->json(Booking::with(['farm.images','farm.owner','user','review'])->where('user_id',$request->user()->id)->findOrFail($id));
    }
    public function cancel(Request $request,$id) {
        $booking = Booking::where('user_id',$request->user()->id)->findOrFail($id);
        if (!in_array($booking->status,['pending','confirmed']))
            return response()->json(['message'=>'لا يمكن إلغاء هذا الحجز'],422);
        $booking->update(['status'=>'cancelled','cancellation_reason'=>$request->reason]);
        return response()->json(['message'=>'تم إلغاء الحجز']);
    }
    public function ownerBookings(Request $request) {
        return response()->json(Booking::with(['user','farm'])->whereHas('farm',fn($q)=>$q->where('user_id',$request->user()->id))->latest()->get());
    }
    public function updateStatus(Request $request,$id) {
        $booking = Booking::whereHas('farm',fn($q)=>$q->where('user_id',$request->user()->id))->findOrFail($id);
        $request->validate(['status'=>'required|in:confirmed,cancelled,completed']);
        $booking->update(['status'=>$request->status]);
        return response()->json(['message'=>'تم التحديث','booking'=>$booking]);
    }
}