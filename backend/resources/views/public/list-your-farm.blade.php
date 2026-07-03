<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>سجّل مزرعتك على حاجز 🏡</title>
    <link href="https://fonts.googleapis.com/css2?family=Cairo:wght@400;600;700;800&display=swap" rel="stylesheet">
    <script src="https://cdn.tailwindcss.com"></script>
    <script>
        tailwind.config = { theme: { extend: {
            fontFamily: { cairo: ['Cairo', 'sans-serif'] },
            colors: { primary: { DEFAULT: '#0097A7', dark: '#006064', light: '#4DD0E1' } },
        } } };
    </script>
    <style> body { font-family: 'Cairo', sans-serif; } </style>
</head>
<body class="bg-gray-50 text-gray-800">

    {{-- هيدر بسيط --}}
    <div class="bg-gradient-to-br from-primary-dark via-primary to-primary-light text-white">
        <div class="max-w-2xl mx-auto px-5 pt-10 pb-16 text-center">
            <div class="w-16 h-16 rounded-2xl bg-white/15 flex items-center justify-center text-3xl mx-auto mb-4">🏡</div>
            <h1 class="text-2xl md:text-3xl font-extrabold mb-2">اعرض مزرعتك أو شاليهك على حاجز</h1>
            <p class="text-white/85 text-sm md:text-base">وصل مزرعتك لآلاف الباحثين عن استراحة نهاية الأسبوع — سجّل بياناتك وفريقنا رح يتواصل معك خلال يومين</p>
        </div>
    </div>

    <div class="max-w-2xl mx-auto px-5 -mt-10 pb-16">

        @if (session('success'))
            <div class="mb-5 rounded-2xl bg-green-50 border border-green-200 text-green-700 px-5 py-4 text-sm flex items-center gap-2 shadow-sm">
                <span class="text-lg">✅</span> {{ session('success') }}
            </div>
        @endif

        {{-- لماذا تنضم --}}
        <div class="grid grid-cols-3 gap-3 mb-6">
            <div class="bg-white rounded-2xl shadow-sm p-4 text-center">
                <div class="text-2xl mb-1">📢</div>
                <div class="text-xs font-bold text-gray-600">وصول لعملاء جدد</div>
            </div>
            <div class="bg-white rounded-2xl shadow-sm p-4 text-center">
                <div class="text-2xl mb-1">🆓</div>
                <div class="text-xs font-bold text-gray-600">التسجيل مجاني</div>
            </div>
            <div class="bg-white rounded-2xl shadow-sm p-4 text-center">
                <div class="text-2xl mb-1">📱</div>
                <div class="text-xs font-bold text-gray-600">إدارة سهلة</div>
            </div>
        </div>

        <form method="POST" action="{{ route('public.list-your-farm.submit') }}" enctype="multipart/form-data"
              class="bg-white rounded-3xl shadow-sm p-6 space-y-5">
            @csrf

            <div>
                <h2 class="font-extrabold text-lg mb-4">بياناتك</h2>
                <div class="grid md:grid-cols-2 gap-4">
                    <div>
                        <label class="block text-sm font-bold text-gray-600 mb-1">اسمك الكامل *</label>
                        <input type="text" name="owner_name" value="{{ old('owner_name') }}" required
                               class="w-full rounded-xl border border-gray-200 px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-primary/30">
                        @error('owner_name') <p class="text-red-500 text-xs mt-1">{{ $message }}</p> @enderror
                    </div>
                    <div>
                        <label class="block text-sm font-bold text-gray-600 mb-1">رقم الهاتف *</label>
                        <input type="tel" name="phone" value="{{ old('phone') }}" required placeholder="07XXXXXXXX"
                               class="w-full rounded-xl border border-gray-200 px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-primary/30">
                        @error('phone') <p class="text-red-500 text-xs mt-1">{{ $message }}</p> @enderror
                    </div>
                </div>
                <div class="mt-4">
                    <label class="block text-sm font-bold text-gray-600 mb-1">رقم واتساب (إذا مختلف)</label>
                    <input type="tel" name="whatsapp" value="{{ old('whatsapp') }}" placeholder="اتركه فارغاً لو نفس رقم الهاتف"
                           class="w-full rounded-xl border border-gray-200 px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-primary/30">
                </div>
            </div>

            <hr class="border-gray-100">

            <div>
                <h2 class="font-extrabold text-lg mb-4">بيانات المزرعة</h2>
                <div class="space-y-4">
                    <div>
                        <label class="block text-sm font-bold text-gray-600 mb-1">اسم المزرعة/الشاليه *</label>
                        <input type="text" name="farm_name" value="{{ old('farm_name') }}" required
                               class="w-full rounded-xl border border-gray-200 px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-primary/30">
                        @error('farm_name') <p class="text-red-500 text-xs mt-1">{{ $message }}</p> @enderror
                    </div>
                    <div class="grid md:grid-cols-2 gap-4">
                        <div>
                            <label class="block text-sm font-bold text-gray-600 mb-1">المدينة/المنطقة *</label>
                            <input type="text" name="city" value="{{ old('city') }}" required placeholder="مثال: إربد، عمان، جرش..."
                                   class="w-full rounded-xl border border-gray-200 px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-primary/30">
                            @error('city') <p class="text-red-500 text-xs mt-1">{{ $message }}</p> @enderror
                        </div>
                        <div>
                            <label class="block text-sm font-bold text-gray-600 mb-1">العنوان التفصيلي</label>
                            <input type="text" name="address" value="{{ old('address') }}"
                                   class="w-full rounded-xl border border-gray-200 px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-primary/30">
                        </div>
                    </div>
                    <div class="grid md:grid-cols-2 gap-4">
                        <div>
                            <label class="block text-sm font-bold text-gray-600 mb-1">السعر المتوقع لليلة (د.أ)</label>
                            <input type="number" step="0.01" name="price_per_night" value="{{ old('price_per_night') }}"
                                   class="w-full rounded-xl border border-gray-200 px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-primary/30">
                        </div>
                        <div>
                            <label class="block text-sm font-bold text-gray-600 mb-1">السعة (عدد الأشخاص)</label>
                            <input type="number" name="capacity" value="{{ old('capacity') }}"
                                   class="w-full rounded-xl border border-gray-200 px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-primary/30">
                        </div>
                    </div>
                    <div>
                        <label class="block text-sm font-bold text-gray-600 mb-1">وصف مختصر (المرافق، المميزات...)</label>
                        <textarea name="description" rows="3"
                                  class="w-full rounded-xl border border-gray-200 px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-primary/30">{{ old('description') }}</textarea>
                    </div>
                    <div>
                        <label class="block text-sm font-bold text-gray-600 mb-1">صور المزرعة (اختياري، تقدر تضيفها لاحقاً)</label>
                        <input type="file" name="photos[]" multiple accept="image/*"
                               class="w-full text-sm text-gray-500 file:ml-4 file:py-2.5 file:px-4 file:rounded-xl file:border-0 file:bg-primary/10 file:text-primary file:font-bold">
                        @error('photos.*') <p class="text-red-500 text-xs mt-1">{{ $message }}</p> @enderror
                    </div>
                </div>
            </div>

            <button type="submit"
                    class="w-full bg-primary hover:bg-primary-dark text-white font-extrabold rounded-xl py-3.5 transition shadow-lg shadow-primary/30 text-base">
                إرسال الطلب 🚀
            </button>
            <p class="text-center text-xs text-gray-400">بإرسالك للطلب، فريق حاجز رح يتواصل معك لمراجعة البيانات ونشر مزرعتك</p>
        </form>
    </div>
</body>
</html>
