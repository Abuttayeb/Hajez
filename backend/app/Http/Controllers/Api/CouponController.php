<?php
namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Coupon;
use Illuminate\Http\Request;

class CouponController extends Controller
{
    /**
     * التحقق من كوبون قبل الحجز (معاينة الخصم).
     * POST /coupons/validate { code, total }
     */
    public function validateCoupon(Request $request)
    {
        $request->validate([
            'code' => 'required|string|max:50',
            'total' => 'required|numeric|min:0',
        ]);

        $coupon = Coupon::where('code', strtoupper(trim($request->code)))->first();
        if (!$coupon)
            return response()->json(['valid'=>false, 'message'=>'كوبون غير موجود', 'discount'=>0], 422);

        $result = $coupon->validateFor($request->user()->id, (float)$request->total);
        if (!$result['valid'])
            return response()->json($result, 422);

        return response()->json($result + [
            'code' => $coupon->code,
            'final_total' => round((float)$request->total - $result['discount'], 2),
        ]);
    }
}
