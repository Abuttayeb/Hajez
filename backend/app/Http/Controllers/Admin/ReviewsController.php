<?php
namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Review;

class ReviewsController extends Controller
{
    public function index()
    {
        $reviews = Review::with(['user', 'farm'])->latest()->paginate(20);
        return view('admin.reviews.index', compact('reviews'));
    }

    public function destroy(Review $review)
    {
        $review->delete();
        return back()->with('success', 'تم حذف التقييم');
    }
}
