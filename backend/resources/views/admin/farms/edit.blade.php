@extends('admin.layouts.app')
@section('title', 'تعديل مزرعة')

@section('content')
    <div class="flex items-center gap-3 mb-6">
        <a href="{{ route('admin.farms.index') }}" class="text-gray-400 hover:text-gray-600">← رجوع</a>
        <h1 class="text-2xl font-extrabold">تعديل: {{ $farm->name }}</h1>
    </div>

    <form method="POST" action="{{ route('admin.farms.update', $farm) }}" class="bg-white rounded-2xl shadow-sm p-6 max-w-2xl space-y-5">
        @csrf @method('PUT')

        <div>
            <label class="block text-sm font-bold text-gray-600 mb-1">اسم المزرعة</label>
            <input type="text" name="name" value="{{ old('name', $farm->name) }}" required
                   class="w-full rounded-xl border border-gray-200 px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-primary/30">
            @error('name') <p class="text-red-500 text-xs mt-1">{{ $message }}</p> @enderror
        </div>

        <div>
            <label class="block text-sm font-bold text-gray-600 mb-1">الوصف</label>
            <textarea name="description" rows="3"
                      class="w-full rounded-xl border border-gray-200 px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-primary/30">{{ old('description', $farm->description) }}</textarea>
        </div>

        <div class="grid grid-cols-2 gap-4">
            <div>
                <label class="block text-sm font-bold text-gray-600 mb-1">السعر بالليلة العادية (د.أ)</label>
                <input type="number" step="0.01" name="price_per_night" value="{{ old('price_per_night', $farm->price_per_night) }}" required
                       class="w-full rounded-xl border border-gray-200 px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-primary/30">
                @error('price_per_night') <p class="text-red-500 text-xs mt-1">{{ $message }}</p> @enderror
            </div>
            <div>
                <label class="block text-sm font-bold text-gray-600 mb-1">سعر ليلة الويكند (اختياري)</label>
                <input type="number" step="0.01" name="price_per_night_weekend" value="{{ old('price_per_night_weekend', $farm->price_per_night_weekend) }}"
                       placeholder="اتركه فارغاً لو نفس السعر العادي"
                       class="w-full rounded-xl border border-gray-200 px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-primary/30">
            </div>
        </div>

        <div class="flex items-center gap-6">
            <label class="flex items-center gap-2 text-sm font-bold text-gray-600">
                <input type="checkbox" name="is_active" value="1" {{ old('is_active', $farm->is_active) ? 'checked' : '' }}
                       class="w-4 h-4 rounded accent-primary">
                مزرعة نشطة (تظهر بالتطبيق)
            </label>
            <label class="flex items-center gap-2 text-sm font-bold text-gray-600">
                <input type="checkbox" name="is_verified" value="1" {{ old('is_verified', $farm->is_verified) ? 'checked' : '' }}
                       class="w-4 h-4 rounded accent-primary">
                موثّقة ✓
            </label>
        </div>

        <div class="flex gap-3 pt-2">
            <button type="submit" class="bg-primary hover:bg-primary-dark text-white font-bold rounded-xl px-6 py-2.5 text-sm">حفظ التعديلات</button>
            <a href="{{ route('admin.farms.index') }}" class="text-gray-500 text-sm px-4 py-2.5">إلغاء</a>
        </div>
    </form>
@endsection
