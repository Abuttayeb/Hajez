@php
    $c = $coupon ?? null;
@endphp

<div class="grid grid-cols-2 gap-4">
    <div>
        <label class="block text-sm font-bold text-gray-600 mb-1">كود الكوبون</label>
        <input type="text" name="code" value="{{ old('code', $c->code ?? '') }}" required placeholder="مثال: WELCOME20"
               class="w-full rounded-xl border border-gray-200 px-4 py-2.5 text-sm font-mono uppercase focus:outline-none focus:ring-2 focus:ring-primary/30">
        @error('code') <p class="text-red-500 text-xs mt-1">{{ $message }}</p> @enderror
    </div>
    <div>
        <label class="block text-sm font-bold text-gray-600 mb-1">نوع الخصم</label>
        <select name="type" required class="w-full rounded-xl border border-gray-200 px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-primary/30">
            <option value="percent" {{ old('type', $c->type ?? '') === 'percent' ? 'selected' : '' }}>نسبة مئوية %</option>
            <option value="fixed" {{ old('type', $c->type ?? '') === 'fixed' ? 'selected' : '' }}>مبلغ ثابت (د.أ)</option>
        </select>
    </div>
</div>

<div class="grid grid-cols-2 gap-4 mt-5">
    <div>
        <label class="block text-sm font-bold text-gray-600 mb-1">قيمة الخصم</label>
        <input type="number" step="0.01" name="value" value="{{ old('value', $c->value ?? '') }}" required
               class="w-full rounded-xl border border-gray-200 px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-primary/30">
        @error('value') <p class="text-red-500 text-xs mt-1">{{ $message }}</p> @enderror
    </div>
    <div>
        <label class="block text-sm font-bold text-gray-600 mb-1">سقف الخصم الأقصى (اختياري)</label>
        <input type="number" step="0.01" name="max_discount" value="{{ old('max_discount', $c->max_discount ?? '') }}"
               placeholder="مفيد للنسبة المئوية"
               class="w-full rounded-xl border border-gray-200 px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-primary/30">
    </div>
</div>

<div class="grid grid-cols-2 gap-4 mt-5">
    <div>
        <label class="block text-sm font-bold text-gray-600 mb-1">أقل مجموع حجز لقبول الكوبون (اختياري)</label>
        <input type="number" step="0.01" name="min_total" value="{{ old('min_total', $c->min_total ?? '') }}"
               class="w-full rounded-xl border border-gray-200 px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-primary/30">
    </div>
    <div>
        <label class="block text-sm font-bold text-gray-600 mb-1">حد الاستخدام لكل مستخدم</label>
        <input type="number" name="per_user_limit" value="{{ old('per_user_limit', $c->per_user_limit ?? 1) }}" min="1"
               class="w-full rounded-xl border border-gray-200 px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-primary/30">
    </div>
</div>

<div class="grid grid-cols-2 gap-4 mt-5">
    <div>
        <label class="block text-sm font-bold text-gray-600 mb-1">حد الاستخدام الكلي (اختياري)</label>
        <input type="number" name="usage_limit" value="{{ old('usage_limit', $c->usage_limit ?? '') }}" min="1"
               placeholder="اتركه فارغاً لعدد غير محدود"
               class="w-full rounded-xl border border-gray-200 px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-primary/30">
    </div>
    <div class="flex items-end pb-2.5">
        <label class="flex items-center gap-2 text-sm font-bold text-gray-600">
            <input type="checkbox" name="is_active" value="1" {{ old('is_active', $c->is_active ?? true) ? 'checked' : '' }}
                   class="w-4 h-4 rounded accent-primary">
            الكوبون مفعّل
        </label>
    </div>
</div>

<div class="grid grid-cols-2 gap-4 mt-5">
    <div>
        <label class="block text-sm font-bold text-gray-600 mb-1">تاريخ البداية (اختياري)</label>
        <input type="date" name="starts_at" value="{{ old('starts_at', isset($c->starts_at) ? \Illuminate\Support\Carbon::parse($c->starts_at)->format('Y-m-d') : '') }}"
               class="w-full rounded-xl border border-gray-200 px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-primary/30">
    </div>
    <div>
        <label class="block text-sm font-bold text-gray-600 mb-1">تاريخ الانتهاء (اختياري)</label>
        <input type="date" name="expires_at" value="{{ old('expires_at', isset($c->expires_at) ? \Illuminate\Support\Carbon::parse($c->expires_at)->format('Y-m-d') : '') }}"
               class="w-full rounded-xl border border-gray-200 px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-primary/30">
        @error('expires_at') <p class="text-red-500 text-xs mt-1">{{ $message }}</p> @enderror
    </div>
</div>
