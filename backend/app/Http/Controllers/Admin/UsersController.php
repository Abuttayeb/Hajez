<?php
namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;

class UsersController extends Controller
{
    public function index(Request $request)
    {
        $query = User::with('roles');
        if ($request->filled('search')) {
            $query->where(function ($q) use ($request) {
                $q->where('name', 'like', "%{$request->search}%")
                  ->orWhere('email', 'like', "%{$request->search}%");
            });
        }
        $users = $query->latest()->paginate(20)->withQueryString();
        return view('admin.users.index', compact('users'));
    }

    public function toggleActive(User $user)
    {
        if ($user->id === auth()->id()) {
            return back()->with('error', 'لا يمكنك إيقاف حسابك الخاص');
        }
        $user->update(['is_active' => !$user->is_active]);
        return back()->with('success', $user->is_active ? 'تم تفعيل الحساب' : 'تم إيقاف الحساب');
    }

    public function destroy(User $user)
    {
        if ($user->id === auth()->id()) {
            return back()->with('error', 'لا يمكنك حذف حسابك الخاص');
        }
        $user->delete();
        return back()->with('success', 'تم حذف المستخدم');
    }
}
