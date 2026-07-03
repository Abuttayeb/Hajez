<?php
namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Farm extends Model
{
    protected $fillable = [
        'user_id','name','description','city','address','location',
        'price_per_night','price_per_night_weekend','capacity','cover_image',
        'has_pool','is_active','is_verified','whatsapp',
        'check_in_time','check_out_time','rules','type',
        'cancellation_policy','deposit_amount','deposit_notes',
    ];
    protected $casts = [
        'has_pool'=>'boolean','is_active'=>'boolean','is_verified'=>'boolean',
        'price_per_night'=>'decimal:2','price_per_night_weekend'=>'decimal:2',
        'deposit_amount'=>'decimal:2',
    ];
    public function owner() { return $this->belongsTo(User::class,'user_id'); }
    public function images() { return $this->hasMany(FarmImage::class); }
    public function amenities() { return $this->belongsToMany(Amenity::class,'farm_amenity'); }
    public function bookings() { return $this->hasMany(Booking::class); }
    public function reviews() { return $this->hasMany(Review::class); }
    public function isAvailable($checkIn,$checkOut) {
        return !$this->bookings()
            ->whereIn('status',['pending','confirmed'])
            ->where(function($q) use($checkIn,$checkOut) {
                $q->whereBetween('check_in',[$checkIn,$checkOut])
                  ->orWhereBetween('check_out',[$checkIn,$checkOut])
                  ->orWhere(function($q) use($checkIn,$checkOut) {
                      $q->where('check_in','<=',$checkIn)->where('check_out','>=',$checkOut);
                  });
            })->exists();
    }
}
