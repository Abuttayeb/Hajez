<?php
namespace App\Http\Controllers\Api;
use App\Http\Controllers\Controller;
use App\Models\User;
use App\Models\Farm;
use App\Models\Booking;
use App\Models\Review;
use Illuminate\Http\Request;

class AdminController extends Controller
{
    public function stats() {
        return response()->json(['users'=>User::count(),'farms'=>Farm::count(),'bookings'=>Booking::count(),'revenue'=>Booking::where('status','completed')->sum('total_price'),'pending'=>Booking::where('status','pending')->count(),'active_farms'=>Farm::where('is_active',true)->count()]);
    }
    public function getUsers() { return response()->json(User::with('roles')->latest()->get()); }
    public function deleteUser($id) { User::findOrFail($id)->delete(); return response()->json(['message'=>'تم الحذف']); }
    public function toggleUser($id) { $user=User::findOrFail($id); $user->update(['is_active'=>!$user->is_active]); return response()->json(['message'=>'تم التحديث','user'=>$user]); }
    public function getFarms() { return response()->json(Farm::with(['owner','images'])->latest()->get()); }
    public function updateFarm(Request $request,$id) { $farm=Farm::findOrFail($id); $farm->update($request->only(['is_active','is_verified','name','description','price_per_night'])); return response()->json(['message'=>'تم التحديث','farm'=>$farm]); }
    public function deleteFarm($id) { Farm::findOrFail($id)->delete(); return response()->json(['message'=>'تم الحذف']); }
    public function getBookings() { return response()->json(Booking::with(['user','farm'])->latest()->get()); }
    public function updateBooking(Request $request,$id) { $booking=Booking::findOrFail($id); $booking->update(['status'=>$request->status]); return response()->json(['message'=>'تم التحديث','booking'=>$booking]); }
    public function getReviews() { return response()->json(Review::with(['user','farm'])->latest()->get()); }
    public function deleteReview($id) { Review::findOrFail($id)->delete(); return response()->json(['message'=>'تم الحذف']); }
}
