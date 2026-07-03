<?php
namespace App\Http\Controllers\Api;
use App\Http\Controllers\Controller;
use App\Models\User;
use App\Models\Farm;
use App\Models\Booking;
use App\Models\Review;
use App\Models\Coupon;
use Illuminate\Http\Request;

class AdminController extends Controller
{
    public function stats() {
        return response()->json(['users'=>User::count(),'farms'=>Farm::count(),'bookings'=>Booking::count(),'revenue'=>Booking::where('status','completed')->sum('total_price'),'pending'=>Booking::where('status','pending')->count(),'active_farms'=>Farm::where('is_active',true)->count()]);
    }
    public function getUsers() { return response()->json(User::with('roles')->latest()->get()); }
    public function deleteUser($id) { User::findOrFail($id)->delete(); return response()->json(['message'=>'تم الحذف']); }
    public function toggleUser($id) { $user=User::findOrFail($id); $user->update(['is_active'=>!$user->is_active]); return response()->json(['message'=>'تم التحديث','user'=>$user]); }
    public function getFarms() { return response()->json(Farm::with(['owner','images'])->latest()->get()); }
    public function updateFarm(Request $request,$id) { $farm=Farm::findOrFail($id); $farm->update($request->only(['is_active','is_verified','name','description','price_per_night','price_per_night_weekend'])); return response()->json(['message'=>'تم التحديث','farm'=>$farm]); }
    public function deleteFarm($id) { Farm::findOrFail($id)->delete(); return response()->json(['message'=>'تم الحذف']); }
    public function getBookings() { return response()->json(Booking::with(['user','farm'])->latest()->get()); }
    public function updateBooking(Request $request,$id) { $booking=Booking::findOrFail($id); $booking->update(['status'=>$request->status]); return response()->json(['message'=>'تم التحديث','booking'=>$booking]); }
    public function getReviews() { return response()->json(Review::with(['user','farm'])->latest()->get()); }
    public function deleteReview($id) { Review::findOrFail($id)->delete(); return response()->json(['message'=>'تم الحذف']); }

    // ================= إدارة الكوبونات =================
    public function getCoupons() {
        return response()->json(Coupon::withCount('usages')->latest()->get());
    }
    public function createCoupon(Request $request) {
        $request->validate([
            'code'=>'required|string|max:50|unique:coupons,code',
            'type'=>'required|in:percent,fixed',
            'value'=>'required|numeric|min:0',
            'max_discount'=>'nullable|numeric|min:0',
            'min_total'=>'nullable|numeric|min:0',
            'usage_limit'=>'nullable|integer|min:1',
            'per_user_limit'=>'nullable|integer|min:1',
            'starts_at'=>'nullable|date',
            'expires_at'=>'nullable|date|after_or_equal:starts_at',
            'is_active'=>'boolean',
        ]);
        $coupon = Coupon::create(array_merge($request->all(), ['code'=>strtoupper(trim($request->code))]));
        return response()->json(['message'=>'تم إنشاء الكوبون','coupon'=>$coupon],201);
    }
    public function updateCoupon(Request $request,$id) {
        $coupon = Coupon::findOrFail($id);
        $request->validate([
            'code'=>'sometimes|string|max:50|unique:coupons,code,'.$id,
            'type'=>'sometimes|in:percent,fixed',
            'value'=>'sometimes|numeric|min:0',
            'max_discount'=>'nullable|numeric|min:0',
            'min_total'=>'nullable|numeric|min:0',
            'usage_limit'=>'nullable|integer|min:1',
            'per_user_limit'=>'nullable|integer|min:1',
            'starts_at'=>'nullable|date',
            'expires_at'=>'nullable|date',
            'is_active'=>'boolean',
        ]);
        $data = $request->all();
        if (isset($data['code'])) $data['code'] = strtoupper(trim($data['code']));
        $coupon->update($data);
        return response()->json(['message'=>'تم التحديث','coupon'=>$coupon]);
    }
    public function deleteCoupon($id) {
        Coupon::findOrFail($id)->delete();
        return response()->json(['message'=>'تم الحذف']);
    }
}
