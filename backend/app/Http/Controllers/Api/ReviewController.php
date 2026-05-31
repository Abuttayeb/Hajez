<?php
namespace App\Http\Controllers\Api;
use App\Http\Controllers\Controller;
use App\Models\Review;
use App\Models\Booking;
use Illuminate\Http\Request;

class ReviewController extends Controller
{
    public function farmReviews($id) {
        return response()->json(Review::with('user')->where('farm_id',$id)->where('is_approved',true)->latest()->get());
    }
    public function store(Request $request) {
        $request->validate(['booking_id'=>'required|exists:bookings,id','rating'=>'required|integer|min:1|max:5','comment'=>'nullable|string|max:500']);
        $booking = Booking::where('user_id',$request->user()->id)->where('status','completed')->findOrFail($request->booking_id);
        if ($booking->review) return response()->json(['message'=>'لقد قيّمت هذا الحجز مسبقاً'],422);
        $review = Review::create(['user_id'=>$request->user()->id,'farm_id'=>$booking->farm_id,'booking_id'=>$request->booking_id,'rating'=>$request->rating,'comment'=>$request->comment]);
        return response()->json(['message'=>'شكراً على تقييمك','review'=>$review->load('user')],201);
    }
}
