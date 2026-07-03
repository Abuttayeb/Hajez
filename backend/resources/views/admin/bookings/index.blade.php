@extends('admin.layouts.app')
@section('title', 'الحجوزات')

@section('content')
    <div class="flex items-center justify-between mb-6">
        <h1 class="text-2xl font-extrabold">الحجوزات</h1>
        <form method="GET" class="flex gap-2">
            <select name="status" onchange="this.form.submit()"
                    class="rounded-xl border border-gray-200 px-4 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-primary/30">
                <option value="">كل الحالات</option>
                @foreach (['pending' => 'قيد المراجعة', 'confirmed' => 'مؤكد', 'completed' => 'مكتمل', 'cancelled' => 'ملغي'] as $val => $label)
                    <option value="{{ $val }}" {{ request('status') === $val ? 'selected' : '' }}>{{ $label }}</option>
                @endforeach
            </select>
        </form>
    </div>

    <div class="bg-white rounded-2xl shadow-sm overflow-hidden">
        <table class="w-full text-sm">
            <thead class="bg-gray-50 text-gray-500 text-right">
                <tr>
                    <th class="px-5 py-3 font-bold">المزرعة</th>
                    <th class="px-5 py-3 font-bold">العميل</th>
                    <th class="px-5 py-3 font-bold">التواريخ</th>
                    <th class="px-5 py-3 font-bold">المبلغ</th>
                    <th class="px-5 py-3 font-bold">الحالة</th>
                    <th class="px-5 py-3 font-bold">تغيير الحالة</th>
                </tr>
            </thead>
            <tbody class="divide-y divide-gray-100">
                @forelse ($bookings as $b)
                    <tr class="hover:bg-gray-50">
                        <td class="px-5 py-3 font-bold">{{ $b->farm->name ?? '—' }}
                            @unless ($b->farm) <span class="text-red-400 text-xs">(محذوفة)</span> @endunless
                        </td>
                        <td class="px-5 py-3 text-gray-500">{{ $b->user->name ?? '—' }}</td>
                        <td class="px-5 py-3 text-gray-500 text-xs">{{ $b->check_in }} → {{ $b->check_out }}</td>
                        <td class="px-5 py-3">{{ number_format($b->total_price, 0) }} د.أ</td>
                        <td class="px-5 py-3">
                            <span class="text-xs px-2 py-1 rounded-full
                                @class([
                                    'bg-orange-100 text-orange-600' => $b->status === 'pending',
                                    'bg-green-100 text-green-600' => $b->status === 'confirmed',
                                    'bg-red-100 text-red-600' => $b->status === 'cancelled',
                                    'bg-gray-100 text-gray-600' => $b->status === 'completed',
                                ])">{{ $b->status }}</span>
                        </td>
                        <td class="px-5 py-3">
                            <form method="POST" action="{{ route('admin.bookings.status', $b) }}" class="flex gap-2">
                                @csrf
                                <select name="status" class="text-xs rounded-lg border border-gray-200 px-2 py-1">
                                    @foreach (['pending' => 'قيد المراجعة', 'confirmed' => 'تأكيد', 'completed' => 'إكمال', 'cancelled' => 'إلغاء'] as $val => $label)
                                        <option value="{{ $val }}" {{ $b->status === $val ? 'selected' : '' }}>{{ $label }}</option>
                                    @endforeach
                                </select>
                                <button class="text-xs bg-primary/10 text-primary font-bold px-3 rounded-lg">تحديث</button>
                            </form>
                        </td>
                    </tr>
                @empty
                    <tr><td colspan="6" class="px-5 py-8 text-center text-gray-400">لا توجد حجوزات</td></tr>
                @endforelse
            </tbody>
        </table>
    </div>

    <div class="mt-4">{{ $bookings->links() }}</div>
@endsection
