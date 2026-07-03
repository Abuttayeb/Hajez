@extends('admin.layouts.app')
@section('title', 'التقييمات')

@section('content')
    <h1 class="text-2xl font-extrabold mb-6">التقييمات</h1>

    <div class="space-y-4">
        @forelse ($reviews as $r)
            <div class="bg-white rounded-2xl shadow-sm p-5 flex items-start justify-between gap-4">
                <div class="min-w-0">
                    <div class="flex items-center gap-2 mb-1">
                        <span class="font-bold">{{ $r->user->name ?? '—' }}</span>
                        <span class="text-gray-300">•</span>
                        <span class="text-gray-500 text-sm">{{ $r->farm->name ?? 'مزرعة محذوفة' }}</span>
                    </div>
                    <div class="text-amber-500 mb-2">{{ str_repeat('★', $r->rating) }}{{ str_repeat('☆', 5 - $r->rating) }}</div>

                    @if ($r->cleanliness_rating || $r->service_rating || $r->value_rating || $r->location_rating)
                        <div class="flex flex-wrap gap-3 text-xs text-gray-500 mb-2">
                            @if ($r->cleanliness_rating) <span>🧹 النظافة: {{ $r->cleanliness_rating }}/5</span> @endif
                            @if ($r->service_rating) <span>🤝 الخدمة: {{ $r->service_rating }}/5</span> @endif
                            @if ($r->value_rating) <span>💰 القيمة: {{ $r->value_rating }}/5</span> @endif
                            @if ($r->location_rating) <span>📍 الموقع: {{ $r->location_rating }}/5</span> @endif
                        </div>
                    @endif

                    @if ($r->comment)
                        <p class="text-gray-600 text-sm">{{ $r->comment }}</p>
                    @endif
                </div>
                <form method="POST" action="{{ route('admin.reviews.destroy', $r) }}"
                      onsubmit="return confirm('هل أنت متأكد من حذف هذا التقييم؟')" class="shrink-0">
                    @csrf @method('DELETE')
                    <button class="text-xs text-red-500 font-bold">حذف</button>
                </form>
            </div>
        @empty
            <div class="bg-white rounded-2xl shadow-sm p-8 text-center text-gray-400">لا توجد تقييمات</div>
        @endforelse
    </div>

    <div class="mt-4">{{ $reviews->links() }}</div>
@endsection
