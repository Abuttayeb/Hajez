<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('reviews', function (Blueprint $table) {
            if (!Schema::hasColumn('reviews', 'cleanliness_rating')) $table->unsignedTinyInteger('cleanliness_rating')->nullable()->after('rating');
            if (!Schema::hasColumn('reviews', 'service_rating')) $table->unsignedTinyInteger('service_rating')->nullable()->after('cleanliness_rating');
            if (!Schema::hasColumn('reviews', 'value_rating')) $table->unsignedTinyInteger('value_rating')->nullable()->after('service_rating');
            if (!Schema::hasColumn('reviews', 'location_rating')) $table->unsignedTinyInteger('location_rating')->nullable()->after('value_rating');
        });
    }

    public function down(): void
    {
        Schema::table('reviews', function (Blueprint $table) {
            foreach (['cleanliness_rating','service_rating','value_rating','location_rating'] as $col) {
                if (Schema::hasColumn('reviews', $col)) $table->dropColumn($col);
            }
        });
    }
};
