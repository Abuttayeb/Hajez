<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Admin\AdminAuthController;
use App\Http\Controllers\Admin\DashboardController;
use App\Http\Controllers\Admin\FarmsController;
use App\Http\Controllers\Admin\BookingsController;
use App\Http\Controllers\Admin\UsersController;
use App\Http\Controllers\Admin\ReviewsController;
use App\Http\Controllers\Admin\CouponsController;

Route::get('/', function () {
    return redirect()->route('admin.login');
});

// تسجيل الدخول (بدون حماية)
Route::prefix('admin')->name('admin.')->group(function () {
    Route::get('/login', [AdminAuthController::class, 'showLogin'])->name('login');
    Route::post('/login', [AdminAuthController::class, 'login'])->name('login.submit');
    Route::post('/logout', [AdminAuthController::class, 'logout'])->name('logout');
});

// لوحة الإدارة (محمية بجلسة + صلاحية admin)
Route::prefix('admin')->name('admin.')->middleware(['auth', 'role:admin'])->group(function () {
    Route::get('/', [DashboardController::class, 'index'])->name('dashboard');

    Route::get('/farms', [FarmsController::class, 'index'])->name('farms.index');
    Route::get('/farms/{farm}/edit', [FarmsController::class, 'edit'])->name('farms.edit');
    Route::put('/farms/{farm}', [FarmsController::class, 'update'])->name('farms.update');
    Route::post('/farms/{farm}/toggle', [FarmsController::class, 'toggleActive'])->name('farms.toggle');
    Route::delete('/farms/{farm}', [FarmsController::class, 'destroy'])->name('farms.destroy');

    Route::get('/bookings', [BookingsController::class, 'index'])->name('bookings.index');
    Route::post('/bookings/{booking}/status', [BookingsController::class, 'updateStatus'])->name('bookings.status');

    Route::get('/users', [UsersController::class, 'index'])->name('users.index');
    Route::post('/users/{user}/toggle', [UsersController::class, 'toggleActive'])->name('users.toggle');
    Route::delete('/users/{user}', [UsersController::class, 'destroy'])->name('users.destroy');

    Route::get('/reviews', [ReviewsController::class, 'index'])->name('reviews.index');
    Route::delete('/reviews/{review}', [ReviewsController::class, 'destroy'])->name('reviews.destroy');

    Route::get('/coupons', [CouponsController::class, 'index'])->name('coupons.index');
    Route::get('/coupons/create', [CouponsController::class, 'create'])->name('coupons.create');
    Route::post('/coupons', [CouponsController::class, 'store'])->name('coupons.store');
    Route::get('/coupons/{coupon}/edit', [CouponsController::class, 'edit'])->name('coupons.edit');
    Route::put('/coupons/{coupon}', [CouponsController::class, 'update'])->name('coupons.update');
    Route::post('/coupons/{coupon}/toggle', [CouponsController::class, 'toggleActive'])->name('coupons.toggle');
    Route::delete('/coupons/{coupon}', [CouponsController::class, 'destroy'])->name('coupons.destroy');
});
