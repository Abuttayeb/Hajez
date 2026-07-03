<?php
namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Coupon;
use Illuminate\Http\Request;

class CouponsController extends Controller
{
    public function index()
    {
        $coupons = Coupon::withCount('usages')->latest()->paginate(20);
        return view('admin.coupons.index', compact('coupons'));
    }

    public function create()
    {
        return view('admin.coupons.create');
    }

    private function rules($couponId = null): array
    {
        return [
            'code' => 'required|string|max:50|unique:coupons,code' . ($couponId ? ",$couponId" : ''),
            'type' => 'required|in:percent,fixed',
            'value' => 'required|numeric|min:0',
            'max_discount' => 'nullable|numeric|min:0',
            'min_total' => 'nullable|numeric|min:0',
            'usage_limit' => 'nullable|integer|min:1',
            'per_user_limit' => 'nullable|integer|min:1',
            'starts_at' => 'nullable|date',
            'expires_at' => 'nullable|date|after_or_equal:starts_at',
        ];
    }

    public function store(Request $request)
    {
        $data = $request->validate($this->rules());
        $data['code'] = strtoupper(trim($data['code']));
        $data['is_active'] = $request->boolean('is_active');
        Coupon::create($data);
        return redirect()->route('admin.coupons.index')->with('success', 'تم إنشاء الكوبون');
    }

    public function edit(Coupon $coupon)
    {
        return view('admin.coupons.edit', compact('coupon'));
    }

    public function update(Request $request, Coupon $coupon)
    {
        $data = $request->validate($this->rules($coupon->id));
        $data['code'] = strtoupper(trim($data['code']));
        $data['is_active'] = $request->boolean('is_active');
        $coupon->update($data);
        return redirect()->route('admin.coupons.index')->with('success', 'تم تحديث الكوبون');
    }

    public function toggleActive(Coupon $coupon)
    {
        $coupon->update(['is_active' => !$coupon->is_active]);
        return back()->with('success', $coupon->is_active ? 'تم تفعيل الكوبون' : 'تم إيقاف الكوبون');
    }

    public function destroy(Coupon $coupon)
    {
        $coupon->delete();
        return back()->with('success', 'تم حذف الكوبون');
    }
}
