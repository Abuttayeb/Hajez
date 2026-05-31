<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;
class Booking extends Model
{
    protected $fillable = ['user_id','farm_id','check_in','check_out','guests','total_price','status','payment_method','payment_status','cliq_ref','notes','cancellation_reason'];
    protected $casts = ['check_in'=>'date','check_out'=>'date','total_price'=>'decimal:2'];
    public function user() { return $this->belongsTo(User::class); }
    public function farm() { return $this->belongsTo(Farm::class); }
    public function review() { return $this->hasOne(Review::class); }
}
