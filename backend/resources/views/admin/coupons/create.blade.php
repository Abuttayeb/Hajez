@extends('admin.layouts.app')
@section('title', 'كوبون جديد')

@section('content')
    <div class="flex items-center gap-3 mb-6">
        <a href="{{ route('admin.coupons.index') }}" class="text-gray-400 hover:text-gray-600">← رجوع</a>
        <h1 class="text-2xl font-extrabold">كوبون جديد</h1>
    </div>

    <form method="POST" action="{{ route('admin.coupons.store') }}" class="bg-white rounded-2xl shadow-sm p-6 max-w-2xl">
        @csrf
        @include('admin.coupons._form')
        <div class="flex gap-3 pt-6">
            <button type="submit" class="bg-primary hover:bg-primary-dark text-white font-bold rounded-xl px-6 py-2.5 text-sm">إنشاء الكوبون</button>
            <a href="{{ route('admin.coupons.index') }}" class="text-gray-500 text-sm px-4 py-2.5">إلغاء</a>
        </div>
    </form>
@endsection
