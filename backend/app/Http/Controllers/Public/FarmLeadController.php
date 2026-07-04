<?php
namespace App\Http\Controllers\Public;

use App\Http\Controllers\Controller;
use App\Models\FarmLead;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class FarmLeadController extends Controller
{
    public function show()
    {
        return view('public.list-your-farm');
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'owner_name' => 'required|string|max:100',
            'phone' => 'required|string|max:30',
            'whatsapp' => 'nullable|string|max:30',
            'farm_name' => 'required|string|max:150',
            'city' => 'required|string|max:100',
            'address' => 'nullable|string|max:255',
            'description' => 'nullable|string|max:1000',
            'price_per_night' => 'nullable|numeric|min:0',
            'capacity' => 'nullable|integer|min:1',
            'photos.*' => 'nullable|image|max:5120',
        ]);

        $photoPaths = [];
        if ($request->hasFile('photos')) {
            foreach ($request->file('photos') as $photo) {
                $photoPaths[] = Storage::disk('direct')->url($photo->store('farm-leads', 'direct'));
            }
        }

        FarmLead::create(array_merge($validated, ['photos' => $photoPaths]));

        return redirect()->route('public.list-your-farm')->with('success',
            'تم استلام طلبك بنجاح! فريقنا رح يتواصل معك خلال يومين لمتابعة نشر مزرعتك على حاجز.');
    }
}
