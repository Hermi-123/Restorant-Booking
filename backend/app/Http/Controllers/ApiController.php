<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Table;
use App\Models\TableSession;
use App\Models\Category;
use Illuminate\Support\Str;

class ApiController extends Controller
{
    public function startSession(Request $request)
    {
        $request->validate([
            'qr_token' => 'required|string',
            'device_id' => 'required|string'
        ]);

        $table = Table::where('qr_token', $request->qr_token)->first();

        if (!$table) {
            return response()->json(['error' => 'Invalid QR token'], 404);
        }

        $session = TableSession::where('table_id', $table->id)
            ->where('is_active', true)
            ->first();

        if (!$session) {
            $session = TableSession::create([
                'table_id' => $table->id,
                'session_code' => Str::random(10),
                'device_id' => $request->device_id,
                'is_active' => true,
            ]);
        } else {
            $session->update(['device_id' => $request->device_id]);
        }

        return response()->json([
            'table_session_id' => $session->id,
            'session_code' => $session->session_code,
            'table_number' => $table->table_number
        ]);
    }

    public function recoverSession(Request $request)
    {
        $request->validate([
            'session_code' => 'required|string'
        ]);

        $session = TableSession::where('session_code', $request->session_code)->first();

        if (!$session || !$session->is_active) {
            return response()->json(['error' => 'Session not found or inactive'], 404);
        }

        $table = Table::find($session->table_id);

        return response()->json([
            'table_session_id' => $session->id,
            'session_code' => $session->session_code,
            'table_number' => $table ? $table->table_number : 'Unknown'
        ]);
    }

    public function getMenu()
    {
        $categories = Category::with('menuItems')->orderBy('sort_order')->get();
        return response()->json($categories);
    }
}
