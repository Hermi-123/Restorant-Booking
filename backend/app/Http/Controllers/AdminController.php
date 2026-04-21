<?php

namespace App\Http\Controllers;

use App\Models\Table;
use App\Models\Category;
use App\Models\MenuItem;
use Illuminate\Http\Request;
use Illuminate\Support\Str;

class AdminController extends Controller
{
    // Table Management
    public function getTables()
    {
        return response()->json(Table::all());
    }

    public function addTable(Request $request)
    {
        $request->validate([
            'table_number' => 'required|string|unique:tables,table_number',
            'capacity' => 'required|integer|min:1'
        ]);

        $table = Table::create([
            'table_number' => $request->table_number,
            'capacity' => $request->capacity,
            'qr_token' => Str::upper(Str::random(10)),
            'status' => 'available'
        ]);

        return response()->json($table, 201);
    }

    // Category Management
    public function getCategories()
    {
        return response()->json(Category::all());
    }

    public function addCategory(Request $request)
    {
        $request->validate([
            'name' => 'required|string',
            'sort_order' => 'nullable|integer'
        ]);

        $category = Category::create($request->all());
        return response()->json($category, 201);
    }

    // Menu Item Management
    public function addMenuItem(Request $request)
    {
        $request->validate([
            'category_id' => 'required|exists:categories,id',
            'name' => 'required|string',
            'price' => 'required|numeric',
            'is_available' => 'boolean'
        ]);

        $item = MenuItem::create($request->all());
        return response()->json($item, 201);
    }

    public function updateMenuItemAvailability(Request $request, $id)
    {
        $request->validate(['is_available' => 'required|boolean']);
        $item = MenuItem::findOrFail($id);
        $item->update(['is_available' => $request->is_available]);
        return response()->json($item);
    }
}
