<?php
namespace App\Http\Controllers\Api;
use App\Http\Controllers\Controller;
use App\Models\Farm;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class FarmController extends Controller
{
    public function index(Request $request) {
        $query = Farm::with(['images','amenities','reviews','owner'])->where('is_active',true);
        if ($request->search) $query->where(function($q) use($request) { $q->where('name','like',"%{$request->search}%")->orWhere('city','like',"%{$request->search}%"); });
        if ($request->city) $query->where('city',$request->city);
        if ($request->type) $query->where('type',$request->type);
        if ($request->has_pool) $query->where('has_pool',true);
        if ($request->min_price) $query->where('price_per_night','>=',$request->min_price);
        if ($request->max_price) $query->where('price_per_night','<=',$request->max_price);
        if ($request->capacity) $query->where('capacity','>=',$request->capacity);
        return response()->json($query->latest()->paginate(10));
    }
    public function show($id) {
        $farm = Farm::with(['images','amenities','reviews.user','owner'])->findOrFail($id);
        $farm->average_rating = $farm->reviews->avg('rating') ?? 0;
        return response()->json($farm);
    }
    public function availability(Request $request,$id) {
        $farm = Farm::findOrFail($id);
        $available = $farm->isAvailable($request->check_in,$request->check_out);
        $nights = \Carbon\Carbon::parse($request->check_in)->diffInDays($request->check_out);
        return response()->json(['available'=>$available,'nights'=>$nights,'price_per_night'=>$farm->price_per_night,'total_price'=>$nights*$farm->price_per_night]);
    }
    public function myFarms(Request $request) {
        return response()->json(Farm::with(['images','bookings','reviews'])->where('user_id',$request->user()->id)->latest()->get());
    }
    public function store(Request $request) {
        $request->validate(['name'=>'required','description'=>'required','city'=>'required','address'=>'required','price_per_night'=>'required|numeric|min:1','capacity'=>'required|integer|min:1']);
        $farm = Farm::create(array_merge($request->only(['name','description','city','address','location','price_per_night','price_per_night_weekend','capacity','has_pool','whatsapp','check_in_time','check_out_time','rules','type']),['user_id'=>$request->user()->id]));
        if ($request->amenities) $farm->amenities()->sync($request->amenities);
        return response()->json(['message'=>'تمت إضافة المزرعة','farm'=>$farm->load('amenities')],201);
    }
    public function update(Request $request,$id) {
        $farm = Farm::where('user_id',$request->user()->id)->findOrFail($id);
        $farm->update($request->only(['name','description','city','address','location','price_per_night','price_per_night_weekend','capacity','has_pool','whatsapp','check_in_time','check_out_time','rules','type','is_active']));
        if ($request->amenities) $farm->amenities()->sync($request->amenities);
        return response()->json(['message'=>'تم التحديث','farm'=>$farm->load('amenities')]);
    }
    public function uploadImage(Request $request,$id) {
        $farm = Farm::where('user_id',$request->user()->id)->findOrFail($id);
        $request->validate(['image'=>'required|image|max:5120']);
        $path = $request->file('image')->store('farms','direct');
        $url = Storage::disk('direct')->url($path);
        $image = $farm->images()->create(['image_path'=>$url,'category'=>$request->category??'general','is_cover'=>$request->is_cover??false]);
        if ($request->is_cover) $farm->update(['cover_image'=>$url]);
        return response()->json(['message'=>'تم رفع الصورة','image'=>$image]);
    }
    public function destroy(Request $request,$id) {
        Farm::where('user_id',$request->user()->id)->findOrFail($id)->delete();
        return response()->json(['message'=>'تم حذف المزرعة']);
    }
}
