<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class AppUser extends Model
{
    use HasFactory;
    protected $guarded = [];
    protected $primaryKey = 'device_id';
    public $incrementing = false;
    protected $keyType = 'string';
}
