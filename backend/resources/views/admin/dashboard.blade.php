@extends('admin.layouts.app')
@section('title', 'الداشبورد')

@section('content')
    <h1 class="text-2xl font-extrabold mb-6">الداشبورد</h1>

    @if ($orphanBookings > 0)
        <div class="mb-6 rounded-xl bg-amber-50 border border-amber-300 text-amber-800 px-4 py-3 text-sm flex items-start gap-2">
            <span class="text-lg">⚠️</span>
            <div>
                <strong>تنبيه بيانات:</strong> يوجد {{ $orphanBookings }} حجز/حجوزات مرتبطة بمزارع محذوفة من قاعدة البيانات
                (مزرعة غير موجودة). هذا سبب عدم تطابق عداد المزارع مع الحجوزات — يُنصح بمراجعتها من قاعدة البيانات مباشرة.
            </div>
        </div>
    @endif

    {{-- بطاقات الإحصائيات --}}
    <div class="grid grid-cols-2 md:grid-cols-3 gap-4 mb-8">
        @php
            $cards = [
                ['label' => 'الحجوزات', 'value' => $stats['bookings'], 'icon' => '📅', 'color' => 'bg-purple-100 text-purple-600'],
                ['label' => 'المزارع', 'value' => $stats['farms'], 'icon' => '🏡', 'color' => 'bg-primary/10 text-primary'],
                ['label' => 'المستخدمين', 'value' => $stats['users'], 'icon' => '👥', 'color' => 'bg-blue-100 text-blue-600'],
                ['label' => 'مزارع نشطة', 'value' => $stats['active_farms'], 'icon' => '✅', 'color' => 'bg-emerald-100 text-emerald-600'],
                ['label' => 'حجوزات قيد المراجعة', 'value' => $stats['pending'], 'icon' => '⏳', 'color' => 'bg-orange-100 text-orange-600'],
                ['label' => 'الإيرادات (د.أ)', 'value' => number_format($stats['revenue'], 0), 'icon' => '💰', 'color' => 'bg-green-100 text-green-600'],
            ];
        @endphp
        @foreach ($cards as $card)
            <div class="bg-white rounded-2xl shadow-sm p-5 flex items-center justify-between">
                <div>
                    <div class="text-sm text-gray-400 mb-1">{{ $card['label'] }}</div>
                    <div class="text-2xl font-extrabold text-gray-800">{{ $card['value'] }}</div>
                </div>
                <div class="w-12 h-12 rounded-xl {{ $card['color'] }} flex items-center justify-center text-xl">
                    {{ $card['icon'] }}
                </div>
            </div>
        @endforeach
    </div>

    <div class="grid md:grid-cols-2 gap-6">
        {{-- آخر الحجوزات --}}
        <div class="bg-white rounded-2xl shadow-sm p-5">
            <div class="flex items-center justify-between mb-4">
                <h2 class="font-bold text-gray-700">آخر الحجوزات</h2>
                <a href="{{ route('admin.bookings.index') }}" class="text-xs text-primary font-bold">عرض الكل ←</a>
            </div>
            <div class="space-y-3">
                @forelse ($recentBookings as $b)
                    <div class="flex items-center justify-between text-sm border-b border-gray-100 pb-2 last:border-0">
                        <div class="min-w-0">
                            <div class="font-bold truncate">{{ $b->farm->name ?? 'مزرعة محذوفة' }}</div>
                            <div class="text-gray-400 text-xs">{{ $b->user->name ?? '—' }}</div>
                        </div>
                        <span class="text-xs px-2 py-1 rounded-full
                            @class([
                                'bg-orange-100 text-orange-600' => $b->status === 'pending',
                                'bg-green-100 text-green-600' => $b->status === 'confirmed',
                                'bg-red-100 text-red-600' => $b->status === 'cancelled',
                                'bg-gray-100 text-gray-600' => $b->status === 'completed',
                            ])">{{ $b->status }}</span>
                    </div>
                @empty
                    <p class="text-sm text-gray-400">لا توجد حجوزات بعد</p>
                @endforelse
            </div>
        </div>

        {{-- آخر التقييمات --}}
        <div class="bg-white rounded-2xl shadow-sm p-5">
            <div class="flex items-center justify-between mb-4">
                <h2 class="font-bold text-gray-700">آخر التقييمات</h2>
                <a href="{{ route('admin.reviews.index') }}" class="text-xs text-primary font-bold">عرض الكل ←</a>
            </div>
            <div class="space-y-3">
                @forelse ($recentReviews as $r)
                    <div class="text-sm border-b border-gray-100 pb-2 last:border-0">
                        <div class="flex items-center justify-between mb-1">
                            <span class="font-bold">{{ $r->user->name ?? '—' }}</span>
                            <span class="text-amber-500">{{ str_repeat('★', $r->rating) }}{{ str_repeat('☆', 5 - $r->rating) }}</span>
                        </div>
                        <p class="text-gray-500 text-xs truncate">{{ $r->comment ?: 'بدون تعليق' }}</p>
                    </div>
                @empty
                    <p class="text-sm text-gray-400">لا توجد تقييمات بعد</p>
                @endforelse
            </div>
        </div>
    </div>
@endsection
