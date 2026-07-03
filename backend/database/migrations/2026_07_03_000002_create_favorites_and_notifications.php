<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (!Schema::hasTable('favorites')) {
            Schema::create('favorites', function (Blueprint $table) {
                $table->id();
                $table->foreignId('user_id')->constrained()->cascadeOnDelete();
                $table->foreignId('farm_id')->constrained()->cascadeOnDelete();
                $table->timestamps();
                $table->unique(['user_id', 'farm_id']);
            });
        }

        if (!Schema::hasTable('app_notifications')) {
            Schema::create('app_notifications', function (Blueprint $table) {
                $table->id();
                $table->foreignId('user_id')->constrained()->cascadeOnDelete();
                $table->string('title');
                $table->text('body')->nullable();
                $table->string('type', 30)->default('general'); // booking, booking_status, general
                $table->json('data')->nullable(); // مثل booking_id / farm_id للتنقل داخل التطبيق
                $table->boolean('is_read')->default(false);
                $table->timestamps();
                $table->index(['user_id', 'is_read']);
            });
        }
    }

    public function down(): void
    {
        Schema::dropIfExists('app_notifications');
        Schema::dropIfExists('favorites');
    }
};
