<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('user_activities', function (Blueprint $table) {
            $table->id();
            $table->string('device_id')->nullable();
            $table->foreign('device_id')->references('device_id')->on('app_users')->cascadeOnDelete();
            $table->foreignId('menu_item_id')->constrained('menu_items')->cascadeOnDelete();
            $table->string('action_type')->default('view');
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('user_activities');
    }
};
