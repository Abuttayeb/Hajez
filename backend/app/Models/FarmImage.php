<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;
class FarmImage extends Model
{
    protected $fillable = ['farm_id','image_path','category','is_cover','sort_order'];
    public function farm() { return $this->belongsTo(Farm::class); }
}
