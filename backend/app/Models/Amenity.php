<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;
class Amenity extends Model
{
    protected $fillable = ['name','icon','category'];
    public function farms() { return $this->belongsToMany(Farm::class,'farm_amenity'); }
}
