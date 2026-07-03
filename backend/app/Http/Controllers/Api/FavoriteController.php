<?php
namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Favorite;
use App\Models\Farm;
use Illuminate\Http\Request;

class FavoriteController extends Controller
{
    /** قائمة مزارع المستخدم المفضلة (بنفس شكل عناصر /farms) */
    public function index(Request $request)
    {
        $farmIds = Favorite::where('user_id', $request->user()->id)->pluck('farm_id');
        $farms = Farm::with(['images','reviews'])
            ->whereIn('id', $farmIds)
            ->where('is_active', true)
            ->latest()
            ->get();
        return response()->json(['data' => $farms]);
    }

    /** إضافة/إزالة مزرعة من المفضلة */
    public function toggle(Request $request)
    {
        $request->validate(['farm_id' => 'required|exists:farms,id']);
        $userId = $request->user()->id;
        $existing = Favorite::where('user_id', $userId)->where('farm_id', $request->farm_id)->first();
        if ($existing) {
            $existing->delete();
            return response()->json(['favorited' => false, 'message' => 'أزيلت من المفضلة']);
        }
        Favorite::create(['user_id' => $userId, 'farm_id' => $request->farm_id]);
        return response()->json(['favorited' => true, 'message' => 'أضيفت إلى المفضلة']);
    }

    /** قائمة معرفات المزارع المفضلة فقط (خفيفة لتهيئة حالة القلوب بالتطبيق) */
    public function ids(Request $request)
    {
        return response()->json([
            'ids' => Favorite::where('user_id', $request->user()->id)->pluck('farm_id'),
        ]);
    }
}
