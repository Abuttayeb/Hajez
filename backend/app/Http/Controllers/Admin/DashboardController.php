<?php
namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Models\Farm;
use App\Models\Booking;
use App\Models\Review;

class DashboardController extends Controller
{
    public function index()
    {
        $stats = [
            'users' => User::count(),
            'farms' => Farm::count(),
            'active_farms' => Farm::where('is_active', true)->count(),
            'bookings' => Booking::count(),
            'pending' => Booking::where('status', 'pending')->count(),
            'revenue' => Booking::where('status', 'completed')->sum('total_price'),
        ];

        // آخر 5 حجوزات وآخر 5 تقييمات لعرض سريع بالداشبورد
        $recentBookings = Booking::with(['user', 'farm'])->latest()->limit(5)->get();
        $recentReviews = Review::with(['user', 'farm'])->latest()->limit(5)->get();

        // تنبيه بيانات: حجوزات بلا مزرعة مرتبطة (بيانات يتيمة)
        $orphanBookings = Booking::whereNotIn('farm_id', Farm::pluck('id'))->count();

        return view('admin.dashboard', compact('stats', 'recentBookings', 'recentReviews', 'orphanBookings'));
    }
}
