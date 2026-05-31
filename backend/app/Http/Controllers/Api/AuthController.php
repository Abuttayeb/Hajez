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
}
