<?php
namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Farm;
use Illuminate\Http\Request;

class FarmsController extends Controller
{
    public function index(Request $request)
    {
        $query = Farm::with(['owner', 'images']);
        if ($request->filled('search')) {
            $query->where(function ($q) use ($request) {
                $q->where('name', 'like', "%{$request->search}%")
                  ->orWhere('city', 'like', "%{$request->search}%");
            });
        }
        $farms = $query->latest()->paginate(15)->withQueryString();
        return view('admin.farms.index', compact('farms'));
    }

    public function edit(Farm $farm)
    {
        return view('admin.farms.edit', compact('farm'));
    }

    public function update(Request $request, Farm $farm)
    {
        $request->validate([
            'name' => 'required|string|max:150',
            'description' => 'nullable|string',
            'price_per_night' => 'required|numeric|min:0',
            'price_per_night_weekend' => 'nullable|numeric|min:0',
            'is_active' => 'sometimes|boolean',
            'is_verified' => 'sometimes|boolean',
        ]);
        $farm->update([
            'name' => $request->name,
            'description' => $request->description,
            'price_per_night' => $request->price_per_night,
            'price_per_night_weekend' => $request->price_per_night_weekend,
            'is_active' => $request->boolean('is_active'),
            'is_verified' => $request->boolean('is_verified'),
        ]);
        return redirect()->route('admin.farms.index')->with('success', 'تم تحديث المزرعة');
    }

    public function toggleActive(Farm $farm)
    {
        $farm->update(['is_active' => !$farm->is_active]);
        return back()->with('success', $farm->is_active ? 'تم تفعيل المزرعة' : 'تم إيقاف المزرعة');
    }

    public function destroy(Farm $farm)
    {
        $farm->delete();
        return back()->with('success', 'تم حذف المزرعة');
    }
}
