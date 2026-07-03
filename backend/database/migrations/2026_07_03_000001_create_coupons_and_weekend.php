<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // جدول الكوبونات
        if (!Schema::hasTable('coupons')) {
            Schema::create('coupons', function (Blueprint $table) {
                $table->id();
                $table->string('code', 50)->unique();
                $table->enum('type', ['percent', 'fixed'])->default('percent');
                $table->decimal('value', 8, 2); // نسبة مئوية أو مبلغ ثابت بالدينار
                $table->decimal('max_discount', 8, 2)->nullable(); // سقف الخصم (للنسبة المئوية)
                $table->decimal('min_total', 8, 2)->nullable();    // أقل مجموع حجز يقبل الكوبون
                $table->unsignedInteger('usage_limit')->nullable();      // حد الاستخدام الكلي
                $table->unsignedInteger('per_user_limit')->default(1);   // حد الاستخدام لكل مستخدم
                $table->timestamp('starts_at')->nullable();
                $table->timestamp('expires_at')->nullable();
                $table->boolean('is_active')->default(true);
                $table->timestamps();
            });
        }

        // سجل استخدامات الكوبونات
        if (!Schema::hasTable('coupon_usages')) {
            Schema::create('coupon_usages', function (Blueprint $table) {
                $table->id();
                $table->foreignId('coupon_id')->constrained()->cascadeOnDelete();
                $table->foreignId('user_id')->constrained()->cascadeOnDelete();
                $table->foreignId('booking_id')->nullable()->constrained()->nullOnDelete();
                $table->decimal('discount_amount', 8, 2)->default(0);
                $table->timestamps();
            });
        }

        // أعمدة الخصم على جدول الحجوزات
        Schema::table('bookings', function (Blueprint $table) {
            if (!Schema::hasColumn('bookings', 'coupon_id')) {
                $table->unsignedBigInteger('coupon_id')->nullable()->after('total_price');
            }
            if (!Schema::hasColumn('bookings', 'discount_amount')) {
                $table->decimal('discount_amount', 8, 2)->default(0)->after('coupon_id');
            }
        });

        // سعر الويكند على جدول المزارع (احتياطاً إذا غير موجود بقاعدة الإنتاج)
        Schema::table('farms', function (Blueprint $table) {
            if (!Schema::hasColumn('farms', 'price_per_night_weekend')) {
                $table->decimal('price_per_night_weekend', 8, 2)->nullable()->after('price_per_night');
            }
        });
    }

    public function down(): void
    {
        Schema::table('bookings', function (Blueprint $table) {
            if (Schema::hasColumn('bookings', 'discount_amount')) $table->dropColumn('discount_amount');
            if (Schema::hasColumn('bookings', 'coupon_id')) $table->dropColumn('coupon_id');
        });
        Schema::dropIfExists('coupon_usages');
        Schema::dropIfExists('coupons');
    }
};
