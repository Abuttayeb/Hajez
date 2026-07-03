<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('farms', function (Blueprint $table) {
            if (!Schema::hasColumn('farms', 'cancellation_policy')) {
                $table->enum('cancellation_policy', ['flexible', 'moderate', 'strict'])
                      ->default('moderate')->after('rules');
            }
            if (!Schema::hasColumn('farms', 'deposit_amount')) {
                $table->decimal('deposit_amount', 8, 2)->nullable()->after('cancellation_policy');
            }
            if (!Schema::hasColumn('farms', 'deposit_notes')) {
                $table->string('deposit_notes', 255)->nullable()->after('deposit_amount');
            }
        });
    }

    public function down(): void
    {
        Schema::table('farms', function (Blueprint $table) {
            foreach (['cancellation_policy', 'deposit_amount', 'deposit_notes'] as $col) {
                if (Schema::hasColumn('farms', $col)) $table->dropColumn($col);
            }
        });
    }
};
