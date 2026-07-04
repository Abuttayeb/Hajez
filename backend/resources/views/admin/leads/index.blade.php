@extends('admin.layouts.app')
@section('title', 'طلبات تسجيل الملاك')

@section('content')
    <div class="flex items-center justify-between mb-6">
        <h1 class="text-2xl font-extrabold">طلبات تسجيل الملاك الجدد</h1>
        <div class="flex items-center gap-3">
            <a href="{{ route('public.list-your-farm') }}" target="_blank" class="text-xs text-primary font-bold">
                🔗 عرض صفحة التسجيل العامة
            </a>
            <form method="GET" class="flex gap-2">
                <select name="status" onchange="this.form.submit()"
                        class="rounded-xl border border-gray-200 px-4 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-primary/30">
                    <option value="">كل الحالات</option>
                    @foreach (['new' => 'جديد', 'contacted' => 'تم التواصل', 'approved' => 'مُعتمد', 'rejected' => 'مرفوض'] as $val => $label)
                        <option value="{{ $val }}" {{ request('status') === $val ? 'selected' : '' }}>{{ $label }}</option>
                    @endforeach
                </select>
            </form>
        </div>
    </div>

    <div class="space-y-4">
        @forelse ($leads as $lead)
            <div class="bg-white rounded-2xl shadow-sm p-5">
                <div class="flex items-start justify-between gap-4 flex-wrap">
                    <div class="min-w-0">
                        <div class="flex items-center gap-2 mb-1 flex-wrap">
                            <span class="font-extrabold text-lg">{{ $lead->farm_name }}</span>
                            <span class="text-xs px-2 py-1 rounded-full
                                @class([
                                    'bg-blue-100 text-blue-600' => $lead->status === 'new',
                                    'bg-amber-100 text-amber-600' => $lead->status === 'contacted',
                                    'bg-green-100 text-green-600' => $lead->status === 'approved',
                                    'bg-red-100 text-red-600' => $lead->status === 'rejected',
                                ])">
                                {{ ['new'=>'جديد','contacted'=>'تم التواصل','approved'=>'مُعتمد','rejected'=>'مرفوض'][$lead->status] }}
                            </span>
                        </div>
                        <div class="text-sm text-gray-500 space-y-0.5">
                            <div>👤 {{ $lead->owner_name }} — 📞 {{ $lead->phone }}
                                @if ($lead->whatsapp && $lead->whatsapp !== $lead->phone) (واتساب: {{ $lead->whatsapp }}) @endif
                            </div>
                            <div>📍 {{ $lead->city }} @if($lead->address) — {{ $lead->address }} @endif</div>
                            @if ($lead->price_per_night) <div>💰 السعر المتوقع: {{ number_format($lead->price_per_night, 0) }} د.أ/ليلة</div> @endif
                            @if ($lead->capacity) <div>👥 السعة: {{ $lead->capacity }} أشخاص</div> @endif
                        </div>
                        @if ($lead->description)
                            <p class="text-sm text-gray-600 mt-2">{{ $lead->description }}</p>
                        @endif
                        @if (!empty($lead->photos))
                            <div class="flex gap-2 mt-3">
                                @foreach ($lead->photos as $photo)
                                    <img src="{{ $photo }}" class="w-16 h-16 rounded-lg object-cover border border-gray-100">
                                @endforeach
                            </div>
                        @endif
                    </div>

                    <div class="flex flex-col gap-2 shrink-0 w-full md:w-auto">
                        <a href="https://wa.me/{{ preg_replace('/\D/', '', $lead->whatsapp ?: $lead->phone) }}" target="_blank"
                           class="text-xs bg-green-50 text-green-600 font-bold px-4 py-2 rounded-lg text-center">💬 تواصل واتساب</a>

                        <form method="POST" action="{{ route('admin.leads.status', $lead) }}" class="flex gap-1">
                            @csrf
                            <select name="status" class="text-xs rounded-lg border border-gray-200 px-2 py-1 flex-1">
                                @foreach (['new' => 'جديد', 'contacted' => 'تم التواصل', 'approved' => 'مُعتمد', 'rejected' => 'مرفوض'] as $val => $label)
                                    <option value="{{ $val }}" {{ $lead->status === $val ? 'selected' : '' }}>{{ $label }}</option>
                                @endforeach
                            </select>
                            <button class="text-xs bg-gray-100 text-gray-600 font-bold px-2 rounded-lg">حفظ</button>
                        </form>

                        @if (!$lead->converted_farm_id)
                            <form method="POST" action="{{ route('admin.leads.convert', $lead) }}"
                                  onsubmit="return confirm('رح ننشئ مزرعة جديدة (كمسودة غير منشورة) من هذا الطلب. متأكد؟')">
                                @csrf
                                <button class="w-full text-xs bg-primary text-white font-bold px-4 py-2 rounded-lg">
                                    ✅ تحويل لمزرعة
                                </button>
                            </form>
                        @else
                            <a href="{{ route('admin.farms.edit', $lead->converted_farm_id) }}"
                               class="text-xs bg-primary/10 text-primary font-bold px-4 py-2 rounded-lg text-center">
                                عرض المزرعة →
                            </a>
                        @endif
                    </div>
                </div>

                <form method="POST" action="{{ route('admin.leads.notes', $lead) }}" class="mt-4 pt-4 border-t border-gray-100 flex gap-2">
                    @csrf
                    <input type="text" name="internal_notes" value="{{ $lead->internal_notes }}" placeholder="ملاحظات داخلية للفريق..."
                           class="flex-1 text-xs rounded-lg border border-gray-200 px-3 py-2">
                    <button class="text-xs bg-gray-100 text-gray-600 font-bold px-3 rounded-lg">حفظ الملاحظة</button>
                </form>
            </div>
        @empty
            <div class="bg-white rounded-2xl shadow-sm p-8 text-center text-gray-400">
                لا توجد طلبات بعد. شارك رابط صفحة التسجيل مع الملاك المحتملين:
                <br><span class="text-primary font-mono text-sm">{{ route('public.list-your-farm') }}</span>
            </div>
        @endforelse
    </div>

    <div class="mt-4">{{ $leads->links() }}</div>
@endsection
