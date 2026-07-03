<?php
namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\AppNotification;
use Illuminate\Http\Request;

class NotificationController extends Controller
{
    public function index(Request $request)
    {
        $notifications = AppNotification::where('user_id', $request->user()->id)
            ->latest()
            ->limit(100)
            ->get();
        $unread = AppNotification::where('user_id', $request->user()->id)->where('is_read', false)->count();
        return response()->json(['data' => $notifications, 'unread_count' => $unread]);
    }

    public function unreadCount(Request $request)
    {
        return response()->json([
            'unread_count' => AppNotification::where('user_id', $request->user()->id)->where('is_read', false)->count(),
        ]);
    }

    public function markRead(Request $request, $id)
    {
        $n = AppNotification::where('user_id', $request->user()->id)->findOrFail($id);
        $n->update(['is_read' => true]);
        return response()->json(['message' => 'تم']);
    }

    public function markAllRead(Request $request)
    {
        AppNotification::where('user_id', $request->user()->id)->where('is_read', false)->update(['is_read' => true]);
        return response()->json(['message' => 'تم تعليم الكل كمقروء']);
    }
}
