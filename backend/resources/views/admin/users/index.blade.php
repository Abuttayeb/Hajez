@extends('admin.layouts.app')
@section('title', 'المستخدمين')

@section('content')
    <div class="flex items-center justify-between mb-6">
        <h1 class="text-2xl font-extrabold">المستخدمين</h1>
        <form method="GET" class="flex gap-2">
            <input type="text" name="search" value="{{ request('search') }}" placeholder="ابحث بالاسم أو الإيميل..."
                   class="rounded-xl border border-gray-200 px-4 py-2 text-sm w-64 focus:outline-none focus:ring-2 focus:ring-primary/30">
            <button class="bg-primary text-white rounded-xl px-4 py-2 text-sm font-bold">بحث</button>
        </form>
    </div>

    <div class="bg-white rounded-2xl shadow-sm overflow-hidden">
        <table class="w-full text-sm">
            <thead class="bg-gray-50 text-gray-500 text-right">
                <tr>
                    <th class="px-5 py-3 font-bold">الاسم</th>
                    <th class="px-5 py-3 font-bold">الإيميل</th>
                    <th class="px-5 py-3 font-bold">الهاتف</th>
                    <th class="px-5 py-3 font-bold">الدور</th>
                    <th class="px-5 py-3 font-bold">الحالة</th>
                    <th class="px-5 py-3 font-bold">إجراءات</th>
                </tr>
            </thead>
            <tbody class="divide-y divide-gray-100">
                @forelse ($users as $user)
                    <tr class="hover:bg-gray-50">
                        <td class="px-5 py-3 font-bold">{{ $user->name }}</td>
                        <td class="px-5 py-3 text-gray-500">{{ $user->email }}</td>
                        <td class="px-5 py-3 text-gray-500">{{ $user->phone }}</td>
                        <td class="px-5 py-3">
                            @foreach ($user->roles as $role)
                                <span class="text-xs px-2 py-1 rounded-full bg-primary/10 text-primary">{{ $role->name }}</span>
                            @endforeach
                        </td>
                        <td class="px-5 py-3">
                            <span class="text-xs px-2 py-1 rounded-full {{ $user->is_active ? 'bg-green-100 text-green-600' : 'bg-gray-100 text-gray-500' }}">
                                {{ $user->is_active ? 'نشط' : 'موقوف' }}
                            </span>
                        </td>
                        <td class="px-5 py-3">
                            @if ($user->id !== auth()->id())
                                <div class="flex items-center gap-2">
                                    <form method="POST" action="{{ route('admin.users.toggle', $user) }}">
                                        @csrf
                                        <button class="text-xs text-gray-500 font-bold">{{ $user->is_active ? 'إيقاف' : 'تفعيل' }}</button>
                                    </form>
                                    <form method="POST" action="{{ route('admin.users.destroy', $user) }}"
                                          onsubmit="return confirm('هل أنت متأكد من حذف هذا المستخدم؟')">
                                        @csrf @method('DELETE')
                                        <button class="text-xs text-red-500 font-bold">حذف</button>
                                    </form>
                                </div>
                            @else
                                <span class="text-xs text-gray-300">(حسابك)</span>
                            @endif
                        </td>
                    </tr>
                @empty
                    <tr><td colspan="6" class="px-5 py-8 text-center text-gray-400">لا يوجد مستخدمين</td></tr>
                @endforelse
            </tbody>
        </table>
    </div>

    <div class="mt-4">{{ $users->links() }}</div>
@endsection
