<?php
namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Coupon extends Model
{
    protected $fillable = [
        'code','type','value','max_discount','min_total',
        'usage_limit','per_user_limit','starts_at','expires_at','is_active',
    ];
    protected $casts = [
        'value'=>'decimal:2','max_discount'=>'decimal:2','min_total'=>'decimal:2',
        'is_active'=>'boolean','starts_at'=>'datetime','expires_at'=>'datetime',
    ];

    public function usages() { return $this->hasMany(CouponUsage::class); }

    /**
     * التحقق من صلاحية الكوبون لمستخدم ومجموع معيّن.
     * يرجع ['valid'=>bool, 'message'=>string, 'discount'=>float]
     */
    public function validateFor(int $userId, float $total): array
    {
        if (!$this->is_active)
            return ['valid'=>false, 'message'=>'هذا الكوبون غير مفعّل', 'discount'=>0];

        $now = now();
        if ($this->starts_at && $now->lt($this->starts_at))
            return ['valid'=>false, 'message'=>'هذا الكوبون لم يبدأ بعد', 'discount'=>0];
        if ($this->expires_at && $now->gt($this->expires_at))
            return ['valid'=>false, 'message'=>'انتهت صلاحية هذا الكوبون', 'discount'=>0];

        if ($this->min_total && $total < (float)$this->min_total)
            return ['valid'=>false, 'message'=>'الحد الأدنى لاستخدام الكوبون هو '.number_format((float)$this->min_total).' د.أ', 'discount'=>0];

        if ($this->usage_limit && $this->usages()->count() >= $this->usage_limit)
            return ['valid'=>false, 'message'=>'تم استنفاد هذا الكوبون', 'discount'=>0];

        if ($this->per_user_limit && $this->usages()->where('user_id',$userId)->count() >= $this->per_user_limit)
            return ['valid'=>false, 'message'=>'استخدمت هذا الكوبون من قبل', 'discount'=>0];

        return ['valid'=>true, 'message'=>'كوبون صالح', 'discount'=>$this->computeDiscount($total)];
    }

    /** حساب قيمة الخصم الفعلية (لا تتجاوز المجموع أبداً) */
    public function computeDiscount(float $total): float
    {
        $discount = $this->type === 'percent'
            ? $total * ((float)$this->value / 100)
            : (float)$this->value;

        if ($this->max_discount)
            $discount = min($discount, (float)$this->max_discount);

        return round(min($discount, $total), 2);
    }
}
