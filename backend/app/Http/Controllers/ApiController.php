<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Table;
use App\Models\TableSession;
use App\Models\Category;
use App\Models\AppUser;
use App\Models\UserActivity;
use App\Models\MenuItem;
use App\Models\Order;
use App\Models\OrderItem;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

class ApiController extends Controller
{
    public function startSession(Request $request)
    {
        $request->validate([
            'qr_token' => 'required|string',
            'device_id' => 'required|string'
        ]);

        AppUser::firstOrCreate(['device_id' => $request->device_id]);

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

    public function recordActivity(Request $request)
    {
        $request->validate([
            'device_id' => 'required|string',
            'menu_item_id' => 'required|integer|exists:menu_items,id',
            'action_type' => 'required|string|in:view,like,cart,order'
        ]);

        UserActivity::create($request->only('device_id', 'menu_item_id', 'action_type'));

        return response()->json(['status' => 'success']);
    }

    public function getRecommendations(Request $request)
    {
        $request->validate([
            'device_id' => 'required|string',
        ]);

        $deviceId = $request->device_id;

        // Simple AI logic: 
        // 1. Get items the user interacted with (liked, ordered, cart)
        // 2. Recommend popular items
        // 3. Just merging for a basic recommendation engine

        // Popular items based on ordering/viewing
        $popularItems = UserActivity::select('menu_item_id', DB::raw('count(*) as total'))
            ->groupBy('menu_item_id')
            ->orderBy('total', 'desc')
            ->take(5)
            ->pluck('menu_item_id');

        $recommendations = MenuItem::whereIn('id', $popularItems)->get();

        // If no interactions across the board, just send generic available items
        if ($recommendations->isEmpty()) {
            $recommendations = MenuItem::where('is_available', true)->inRandomOrder()->take(5)->get();
        }

        return response()->json($recommendations);
    }

    public function submitOrder(Request $request)
    {
        $request->validate([
            'session_code' => 'required|string',
            'items' => 'required|array',
            'items.*.menu_item_id' => 'required|integer|exists:menu_items,id',
            'items.*.quantity' => 'required|integer|min:1',
            'items.*.special_instructions' => 'nullable|string'
        ]);

        $session = TableSession::where('session_code', $request->session_code)->where('is_active', true)->first();

        if (!$session) {
            return response()->json(['error' => 'Invalid or inactive session'], 400);
        }

        DB::beginTransaction();

        try {
            $totalPrice = 0;
            $orderItemsData = [];

            foreach ($request->items as $itemData) {
                $menuItem = MenuItem::find($itemData['menu_item_id']);
                
                if (!$menuItem->is_available) {
                    return response()->json(['error' => "Item {$menuItem->name} is not available right now."], 400);
                }

                $itemTotal = $menuItem->price * $itemData['quantity'];
                $totalPrice += $itemTotal;

                $orderItemsData[] = [
                    'menu_item_id' => $menuItem->id,
                    'quantity' => $itemData['quantity'],
                    'unit_price' => $menuItem->price,
                    'special_instructions' => $itemData['special_instructions'] ?? null
                ];
            }

            $order = Order::create([
                'table_session_id' => $session->id,
                'status' => 'pending',
                'total_price' => $totalPrice
            ]);

            foreach ($orderItemsData as $itemData) {
                $itemData['order_id'] = $order->id;
                OrderItem::create($itemData);
            }

            DB::commit();

            return response()->json([
                'message' => 'Order placed successfully',
                'order_id' => $order->id,
                'status' => $order->status,
                'total_price' => $order->total_price
            ], 201);

        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json(['error' => 'An error occurred while placing your order'], 500);
        }
    }

    public function getOrderStatus(Request $request)
    {
        $request->validate([
            'session_code' => 'required|string',
        ]);

        $session = TableSession::where('session_code', $request->session_code)->where('is_active', true)->first();

        if (!$session) {
            return response()->json(['error' => 'Invalid or inactive session'], 400);
        }

        $orders = Order::with('items.menuItem')
            ->where('table_session_id', $session->id)
            ->orderBy('created_at', 'desc')
            ->get();

        return response()->json($orders);
    }
}
