<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>تسجيل الدخول — لوحة إدارة حاجز</title>
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
<body class="min-h-screen flex items-center justify-center bg-gradient-to-br from-primary-dark via-primary to-primary-light px-4">
    <div class="w-full max-w-sm bg-white rounded-3xl shadow-2xl p-8">
        <div class="flex flex-col items-center mb-6">
            <div class="w-16 h-16 rounded-2xl bg-primary/10 flex items-center justify-center text-3xl mb-3">🏡</div>
            <h1 class="text-xl font-extrabold text-gray-800">حاجز</h1>
            <p class="text-sm text-gray-400">لوحة الإدارة</p>
        </div>

        @if ($errors->any())
            <div class="mb-4 rounded-xl bg-red-50 border border-red-200 text-red-600 text-sm px-4 py-3 text-center">
                {{ $errors->first() }}
            </div>
        @endif

        <form method="POST" action="{{ route('admin.login.submit') }}" class="space-y-4">
            @csrf
            <div>
                <label class="block text-sm font-bold text-gray-600 mb-1">البريد الإلكتروني</label>
                <input type="email" name="email" value="{{ old('email') }}" required autofocus
                       class="w-full rounded-xl border border-gray-200 bg-gray-50 px-4 py-3 text-sm focus:outline-none focus:ring-2 focus:ring-primary/40 focus:border-primary">
            </div>
            <div>
                <label class="block text-sm font-bold text-gray-600 mb-1">كلمة المرور</label>
                <input type="password" name="password" required
                       class="w-full rounded-xl border border-gray-200 bg-gray-50 px-4 py-3 text-sm focus:outline-none focus:ring-2 focus:ring-primary/40 focus:border-primary">
            </div>
            <button type="submit"
                    class="w-full bg-primary hover:bg-primary-dark text-white font-bold rounded-xl py-3 transition shadow-lg shadow-primary/30">
                دخول
            </button>
        </form>
    </div>
</body>
</html>
