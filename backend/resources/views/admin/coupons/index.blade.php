@extends('admin.layouts.app')
@section('title', 'الكوبونات')

@section('content')
    <div class="flex items-center justify-between mb-6">
        <h1 class="text-2xl font-extrabold">الكوبونات</h1>
        <a href="{{ route('admin.coupons.create') }}"
           class="bg-primary hover:bg-primary-dark text-white font-bold rounded-xl px-5 py-2.5 text-sm">+ كوبون جديد</a>
    </div>

    <div class="bg-white rounded-2xl shadow-sm overflow-hidden">
        <table class="w-full text-sm">
            <thead class="bg-gray-50 text-gray-500 text-right">
                <tr>
                    <th class="px-5 py-3 font-bold">الكود</th>
                    <th class="px-5 py-3 font-bold">الخصم</th>
                    <th class="px-5 py-3 font-bold">الحد الأدنى</th>
                    <th class="px-5 py-3 font-bold">الاستخدام</th>
                    <th class="px-5 py-3 font-bold">الصلاحية</th>
                    <th class="px-5 py-3 font-bold">الحالة</th>
                    <th class="px-5 py-3 font-bold">إجراءات</th>
                </tr>
            </thead>
            <tbody class="divide-y divide-gray-100">
                @forelse ($coupons as $c)
                    <tr class="hover:bg-gray-50">
                        <td class="px-5 py-3 font-bold font-mono">{{ $c->code }}</td>
                        <td class="px-5 py-3">
                            {{ $c->type === 'percent' ? $c->value.'%' : number_format($c->value, 0).' د.أ' }}
                            @if ($c->max_discount) <span class="text-gray-400 text-xs">(سقف {{ number_format($c->max_discount, 0) }})</span> @endif
                        </td>
                        <td class="px-5 py-3 text-gray-500">{{ $c->min_total ? number_format($c->min_total, 0).' د.أ' : '—' }}</td>
                        <td class="px-5 py-3 text-gray-500 text-xs">
                            {{ $c->usages_count }} استخدام
                            @if ($c->usage_limit) / {{ $c->usage_limit }} @endif
                            <br>({{ $c->per_user_limit }} لكل مستخدم)
                        </td>
                        <td class="px-5 py-3 text-gray-500 text-xs">
                            @if ($c->expires_at) ينتهي {{ \Illuminate\Support\Carbon::parse($c->expires_at)->format('Y-m-d') }}
                            @else بدون تاريخ انتهاء @endif
                        </td>
                        <td class="px-5 py-3">
                            <span class="text-xs px-2 py-1 rounded-full {{ $c->is_active ? 'bg-green-100 text-green-600' : 'bg-gray-100 text-gray-500' }}">
                                {{ $c->is_active ? 'مفعّل' : 'موقوف' }}
                            </span>
                        </td>
                        <td class="px-5 py-3">
                            <div class="flex items-center gap-2">
                                <a href="{{ route('admin.coupons.edit', $c) }}" class="text-primary font-bold text-xs">تعديل</a>
                                <form method="POST" action="{{ route('admin.coupons.toggle', $c) }}">
                                    @csrf
                                    <button class="text-xs text-gray-500 font-bold">{{ $c->is_active ? 'إيقاف' : 'تفعيل' }}</button>
                                </form>
                                <form method="POST" action="{{ route('admin.coupons.destroy', $c) }}"
                                      onsubmit="return confirm('هل أنت متأكد من حذف هذا الكوبون؟')">
                                    @csrf @method('DELETE')
                                    <button class="text-xs text-red-500 font-bold">حذف</button>
                                </form>
                            </div>
                        </td>
                    </tr>
                @empty
                    <tr><td colspan="7" class="px-5 py-8 text-center text-gray-400">لا توجد كوبونات — أنشئ أول كوبون تسويقي الآن</td></tr>
                @endforelse
            </tbody>
        </table>
    </div>

    <div class="mt-4">{{ $coupons->links() }}</div>
@endsection
