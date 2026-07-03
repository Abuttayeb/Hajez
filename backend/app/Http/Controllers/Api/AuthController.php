<?php
namespace App\Http\Controllers\Api;
use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;

class AuthController extends Controller
{
    public function register(Request $request) {
        $request->validate([
            'name'=>'required|string','email'=>'required|email|unique:users',
            'phone'=>'required','password'=>'required|min:6|confirmed','role'=>'required|in:customer,owner',
        ]);
        $user = User::create(['name'=>$request->name,'email'=>$request->email,'phone'=>$request->phone,'password'=>Hash::make($request->password)]);
        $user->assignRole($request->role);
        $token = $user->createToken('auth_token')->plainTextToken;
        return response()->json(['message'=>'تم التسجيل بنجاح','token'=>$token,'user'=>$user,'role'=>$request->role],201);
    }
    public function login(Request $request) {
        $request->validate(['email'=>'required|email','password'=>'required']);
        $user = User::where('email',$request->email)->first();
        if (!$user || !Hash::check($request->password,$user->password))
            return response()->json(['message'=>'بيانات خاطئة'],401);
        if (!$user->is_active)
            return response()->json(['message'=>'الحساب معطل'],403);
        $token = $user->createToken('auth_token')->plainTextToken;
        $role = $user->getRoleNames()->first() ?? 'customer';
        return response()->json(['message'=>'تم تسجيل الدخول','token'=>$token,'user'=>$user,'role'=>$role]);
    }
    public function logout(Request $request) {
        $request->user()->currentAccessToken()->delete();
        return response()->json(['message'=>'تم تسجيل الخروج']);
    }
    public function me(Request $request) {
        $user = $request->user()->load('roles');
        return response()->json(['user'=>$user,'role'=>$user->getRoleNames()->first()]);
    }

    /** تعديل الملف الشخصي (الاسم والهاتف) */
    public function updateProfile(Request $request) {
        $request->validate(['name'=>'required|string|max:100','phone'=>'required|string|max:20']);
        $user = $request->user();
        $user->update(['name'=>$request->name,'phone'=>$request->phone]);
        return response()->json(['message'=>'تم تحديث بياناتك','user'=>$user]);
    }

    /** تغيير كلمة السر (يتطلب الحالية) */
    public function changePassword(Request $request) {
        $request->validate(['current_password'=>'required','new_password'=>'required|min:6|confirmed']);
        $user = $request->user();
        if (!Hash::check($request->current_password, $user->password))
            return response()->json(['message'=>'كلمة السر الحالية غير صحيحة'],422);
        $user->update(['password'=>Hash::make($request->new_password)]);
        // إبطال بقية الجلسات مع إبقاء الجلسة الحالية (أمان: أي جهاز آخر يخرج تلقائياً)
        $currentId = $request->user()->currentAccessToken()->id;
        $user->tokens()->where('id','!=',$currentId)->delete();
        return response()->json(['message'=>'تم تغيير كلمة السر']);
    }
}
