<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>@yield('title', 'لوحة الإدارة') — حاجز</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Cairo:wght@400;600;700;800&display=swap" rel="stylesheet">
    <script src="https://cdn.tailwindcss.com"></script>
    <script defer src="https://cdn.jsdelivr.net/npm/alpinejs@3.x.x/dist/cdn.min.js"></script>
    <script>
        tailwind.config = {
            theme: {
                extend: {
                    fontFamily: { cairo: ['Cairo', 'sans-serif'] },
                    colors: {
                        primary: { DEFAULT: '#0097A7', dark: '#006064', light: '#4DD0E1' },
                    },
                },
            },
        };
    </script>
    <style> body { font-family: 'Cairo', sans-serif; } </style>
</head>
<body class="bg-gray-50 text-gray-800">
<div class="flex min-h-screen">

    {{-- الشريط الجانبي --}}
    <aside class="w-64 shrink-0 bg-gradient-to-b from-primary-dark to-primary text-white flex flex-col" x-data="{ open: false }">
        <div class="p-6 flex items-center gap-3 border-b border-white/10">
            <div class="w-11 h-11 rounded-xl bg-white/15 flex items-center justify-center text-2xl">🏡</div>
            <div>
                <div class="font-extrabold text-lg leading-tight">حاجز</div>
                <div class="text-xs text-white/70">لوحة الإدارة</div>
            </div>
        </div>

        <nav class="flex-1 p-3 space-y-1">
            @php
                $links = [
                    ['route' => 'admin.dashboard', 'icon' => '📊', 'label' => 'الداشبورد'],
                    ['route' => 'admin.farms.index', 'icon' => '🏡', 'label' => 'المزارع'],
                    ['route' => 'admin.bookings.index', 'icon' => '📅', 'label' => 'الحجوزات'],
                    ['route' => 'admin.coupons.index', 'icon' => '🏷️', 'label' => 'الكوبونات'],
                    ['route' => 'admin.users.index', 'icon' => '👥', 'label' => 'المستخدمين'],
                    ['route' => 'admin.reviews.index', 'icon' => '⭐', 'label' => 'التقييمات'],
                ];
            @endphp
            @foreach ($links as $link)
                <a href="{{ route($link['route']) }}"
                   class="flex items-center gap-3 px-4 py-2.5 rounded-xl transition
                          {{ request()->routeIs($link['route']) || (str_contains($link['route'], 'farms') && request()->routeIs('admin.farms.*')) || (str_contains($link['route'], 'coupons') && request()->routeIs('admin.coupons.*'))
                                ? 'bg-white text-primary-dark font-bold shadow'
                                : 'text-white/85 hover:bg-white/10' }}">
                    <span class="text-lg">{{ $link['icon'] }}</span>
                    <span>{{ $link['label'] }}</span>
                </a>
            @endforeach
        </nav>

        <div class="p-4 border-t border-white/10">
            <div class="flex items-center gap-3 mb-3">
                <div class="w-9 h-9 rounded-full bg-white/20 flex items-center justify-center font-bold">
                    {{ mb_substr(auth()->user()->name ?? 'أ', 0, 1) }}
                </div>
                <div class="text-sm min-w-0">
                    <div class="font-bold truncate">{{ auth()->user()->name }}</div>
                    <div class="text-white/70 text-xs truncate">{{ auth()->user()->email }}</div>
                </div>
            </div>
            <form method="POST" action="{{ route('admin.logout') }}">
                @csrf
                <button type="submit" class="w-full text-sm bg-white/10 hover:bg-white/20 rounded-lg py-2 transition flex items-center justify-center gap-2">
                    <span>🚪</span> تسجيل الخروج
                </button>
            </form>
        </div>
    </aside>

    {{-- المحتوى --}}
    <main class="flex-1 min-w-0">
        <div class="max-w-6xl mx-auto px-6 py-8">

            @if (session('success'))
                <div class="mb-5 rounded-xl bg-green-50 border border-green-200 text-green-700 px-4 py-3 flex items-center gap-2">
                    <span>✅</span> {{ session('success') }}
                </div>
            @endif
            @if (session('error'))
                <div class="mb-5 rounded-xl bg-red-50 border border-red-200 text-red-700 px-4 py-3 flex items-center gap-2">
                    <span>⚠️</span> {{ session('error') }}
                </div>
            @endif

            @yield('content')
        </div>
    </main>
</div>
</body>
</html>
