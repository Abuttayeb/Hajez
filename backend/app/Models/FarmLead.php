<?php
namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class FarmLead extends Model
{
    protected $fillable = [
        'owner_name', 'phone', 'whatsapp',
        'farm_name', 'city', 'address', 'description',
        'price_per_night', 'capacity', 'photos',
        'status', 'internal_notes', 'converted_farm_id',
    ];
    protected $casts = [
        'photos' => 'array',
        'price_per_night' => 'decimal:2',
    ];

    public function convertedFarm() { return $this->belongsTo(Farm::class, 'converted_farm_id'); }
}
