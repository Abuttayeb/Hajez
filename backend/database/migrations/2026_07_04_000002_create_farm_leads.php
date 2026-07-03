<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (!Schema::hasTable('farm_leads')) {
            Schema::create('farm_leads', function (Blueprint $table) {
                $table->id();
                // بيانات المالك
                $table->string('owner_name');
                $table->string('phone', 30);
                $table->string('whatsapp', 30)->nullable();

                // بيانات المزرعة الأولية (يراجعها الفريق قبل النشر)
                $table->string('farm_name');
                $table->string('city');
                $table->string('address')->nullable();
                $table->text('description')->nullable();
                $table->decimal('price_per_night', 8, 2)->nullable();
                $table->unsignedInteger('capacity')->nullable();
                $table->json('photos')->nullable(); // مسارات صور مرفوعة مبدئياً

                // حالة المتابعة الداخلية
                $table->enum('status', ['new', 'contacted', 'approved', 'rejected'])->default('new');
                $table->text('internal_notes')->nullable();
                $table->foreignId('converted_farm_id')->nullable()->constrained('farms')->nullOnDelete();

                $table->timestamps();
            });
        }
    }

    public function down(): void
    {
        Schema::dropIfExists('farm_leads');
    }
};
