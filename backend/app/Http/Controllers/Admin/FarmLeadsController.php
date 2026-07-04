<?php
namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\FarmLead;
use App\Models\Farm;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

class FarmLeadsController extends Controller
{
    public function index(Request $request)
    {
        $query = FarmLead::query();
        if ($request->filled('status')) {
            $query->where('status', $request->status);
        }
        $leads = $query->latest()->paginate(20)->withQueryString();
        return view('admin.leads.index', compact('leads'));
    }

    public function updateStatus(Request $request, FarmLead $lead)
    {
        $request->validate(['status' => 'required|in:new,contacted,approved,rejected']);
        $lead->update(['status' => $request->status]);
        return back()->with('success', 'تم تحديث حالة الطلب');
    }

    public function updateNotes(Request $request, FarmLead $lead)
    {
        $request->validate(['internal_notes' => 'nullable|string|max:1000']);
        $lead->update(['internal_notes' => $request->internal_notes]);
        return back()->with('success', 'تم حفظ الملاحظات');
    }

    /**
     * تحويل الطلب لمزرعة فعلية منشورة: ينشئ حساب مالك (لو ما كان موجود بنفس الرقم)
     * ثم مزرعة غير نشطة افتراضياً لحد ما يراجعها الفريق ويفعّلها يدوياً من شاشة المزارع.
     */
    public function convert(FarmLead $lead)
    {
        if ($lead->converted_farm_id) {
            return back()->with('error', 'تم تحويل هذا الطلب مسبقاً');
        }

        // إيجاد أو إنشاء حساب المالك (يُستخدم رقم الهاتف كأساس التمييز عبر إيميل مؤقت)
        $emailPlaceholder = 'owner_'.preg_replace('/\D/', '', $lead->phone).'@hajez.leads';
        $owner = User::firstOrCreate(
            ['phone' => $lead->phone],
            [
                'name' => $lead->owner_name,
                'email' => $emailPlaceholder,
                'password' => Hash::make(Str::random(24)),
                'is_active' => true,
            ]
        );
        if (!$owner->hasRole('owner')) {
            $owner->assignRole('owner');
        }

        $farm = Farm::create([
            'user_id' => $owner->id,
            'name' => $lead->farm_name,
            'description' => $lead->description ?? '',
            'city' => $lead->city,
            'address' => $lead->address ?? $lead->city,
            'price_per_night' => $lead->price_per_night ?? 0,
            'capacity' => $lead->capacity ?? 1,
            'whatsapp' => $lead->whatsapp ?: $lead->phone,
            'is_active' => false,   // يبقى مخفي لحد ما الفريق يراجعه ويفعّله يدوياً
            'is_verified' => false,
        ]);

        foreach ($lead->photos ?? [] as $i => $path) {
            $farm->images()->create([
                'image_path' => $path,
                'is_cover' => $i === 0,
            ]);
        }
        if (!empty($lead->photos[0])) {
            $farm->update(['cover_image' => $lead->photos[0]]);
        }

        $lead->update(['status' => 'approved', 'converted_farm_id' => $farm->id]);

        return redirect()->route('admin.farms.edit', $farm)
            ->with('success', 'تم إنشاء المزرعة كمسودة — راجع البيانات وفعّلها من هنا عند الجاهزية');
    }
}
