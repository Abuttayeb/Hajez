<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;
class Review extends Model
{
    protected $fillable = ['user_id','farm_id','booking_id','rating','comment','is_approved'];
    protected $casts = ['is_approved'=>'boolean'];
    public function user() { return $this->belongsTo(User::class); }
    public function farm() { return $this->belongsTo(Farm::class); }
}
