@extends('admin.layouts.app')
@section('title', 'المزارع')

@section('content')
    <div class="flex items-center justify-between mb-6">
        <h1 class="text-2xl font-extrabold">المزارع</h1>
        <form method="GET" class="flex gap-2">
            <input type="text" name="search" value="{{ request('search') }}" placeholder="ابحث بالاسم أو المدينة..."
                   class="rounded-xl border border-gray-200 px-4 py-2 text-sm w-64 focus:outline-none focus:ring-2 focus:ring-primary/30">
            <button class="bg-primary text-white rounded-xl px-4 py-2 text-sm font-bold">بحث</button>
        </form>
    </div>

    <div class="bg-white rounded-2xl shadow-sm overflow-hidden">
        <table class="w-full text-sm">
            <thead class="bg-gray-50 text-gray-500 text-right">
                <tr>
                    <th class="px-5 py-3 font-bold">المزرعة</th>
                    <th class="px-5 py-3 font-bold">المالك</th>
                    <th class="px-5 py-3 font-bold">المدينة</th>
                    <th class="px-5 py-3 font-bold">السعر/ليلة</th>
                    <th class="px-5 py-3 font-bold">الحالة</th>
                    <th class="px-5 py-3 font-bold">إجراءات</th>
                </tr>
            </thead>
            <tbody class="divide-y divide-gray-100">
                @forelse ($farms as $farm)
                    <tr class="hover:bg-gray-50">
                        <td class="px-5 py-3 font-bold">{{ $farm->name }}</td>
                        <td class="px-5 py-3 text-gray-500">{{ $farm->owner->name ?? '—' }}</td>
                        <td class="px-5 py-3 text-gray-500">{{ $farm->city }}</td>
                        <td class="px-5 py-3">{{ number_format($farm->price_per_night, 0) }} د.أ</td>
                        <td class="px-5 py-3">
                            <span class="text-xs px-2 py-1 rounded-full {{ $farm->is_active ? 'bg-green-100 text-green-600' : 'bg-gray-100 text-gray-500' }}">
                                {{ $farm->is_active ? 'نشطة' : 'موقوفة' }}
                            </span>
                        </td>
                        <td class="px-5 py-3">
                            <div class="flex items-center gap-2">
                                <a href="{{ route('admin.farms.edit', $farm) }}" class="text-primary font-bold text-xs">تعديل</a>
                                <form method="POST" action="{{ route('admin.farms.toggle', $farm) }}">
                                    @csrf
                                    <button class="text-xs text-gray-500 font-bold">{{ $farm->is_active ? 'إيقاف' : 'تفعيل' }}</button>
                                </form>
                                <form method="POST" action="{{ route('admin.farms.destroy', $farm) }}"
                                      onsubmit="return confirm('هل أنت متأكد من حذف هذه المزرعة؟ سيتم حذف كل بياناتها المرتبطة.')">
                                    @csrf @method('DELETE')
                                    <button class="text-xs text-red-500 font-bold">حذف</button>
                                </form>
                            </div>
                        </td>
                    </tr>
                @empty
                    <tr><td colspan="6" class="px-5 py-8 text-center text-gray-400">لا توجد مزارع</td></tr>
                @endforelse
            </tbody>
        </table>
    </div>

    <div class="mt-4">{{ $farms->links() }}</div>
@endsection
