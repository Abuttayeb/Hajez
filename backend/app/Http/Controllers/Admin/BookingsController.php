<?php
namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Booking;
use Illuminate\Http\Request;

class BookingsController extends Controller
{
    public function index(Request $request)
    {
        $query = Booking::with(['user', 'farm']);
        if ($request->filled('status')) {
            $query->where('status', $request->status);
        }
        $bookings = $query->latest()->paginate(20)->withQueryString();
        return view('admin.bookings.index', compact('bookings'));
    }

    public function updateStatus(Request $request, Booking $booking)
    {
        $request->validate(['status' => 'required|in:pending,confirmed,cancelled,completed']);
        $booking->update(['status' => $request->status]);
        return back()->with('success', 'تم تحديث حالة الحجز');
    }
}
