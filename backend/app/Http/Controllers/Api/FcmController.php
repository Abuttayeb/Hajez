<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;

class FcmController extends Controller {
    public function update(Request $request) {
        $request->user()->update(['fcm_token' => $request->fcm_token]);
        return response()->json(['message' => 'ok']);
    }
}