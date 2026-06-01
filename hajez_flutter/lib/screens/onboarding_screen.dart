import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_theme.dart';  // صح - يرجع خطوة للـ lib/

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _pages = [
    {'title': 'مرحباً في حاجز', 'subtitle': 'ملاذك الخاص لحجز المزارع والشاليهات في الأردن', 'icon': Icons.home_work_outlined, 'color': AppColors.primaryDark},
    {'title': 'آلاف الخيارات', 'subtitle': 'من طريق المطار إلى الغور وجرش — اكتشف أجمل الأماكن قريباً منك', 'icon': Icons.explore_outlined, 'color': AppColors.primary},
    {'title': 'حجز سهل وسريع', 'subtitle': 'احجز بضغطة واحدة وادفع بالطريقة اللي تناسبك — كاش أو CliQ', 'icon': Icons.calendar_today_outlined, 'color': AppColors.secondary},
  ];

  void _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarded', true);
    if (mounted) Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [(_pages[_currentPage]['color'] as Color).withOpacity(0.9), AppColors.primaryLight.withOpacity(0.5)],
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Align(alignment: Alignment.topLeft,
                child: TextButton(onPressed: _finish, child: const Text('تخطي', style: TextStyle(color: Colors.white70, fontFamily: 'Cairo')))),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  itemCount: _pages.length,
                  itemBuilder: (_, i) {
                    final page = _pages[i];
                    return Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 140, height: 140,
                            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                            child: Icon(page['icon'] as IconData, size: 70, color: AppColors.white),
                          ),
                          const SizedBox(height: 40),
                          Text(page['title'] as String, style: const TextStyle(color: AppColors.white, fontSize: 28, fontWeight: FontWeight.bold, fontFamily: 'Cairo'), textAlign: TextAlign.center),
                          const SizedBox(height: 16),
                          Text(page['subtitle'] as String, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 16, fontFamily: 'Cairo', height: 1.6), textAlign: TextAlign.center),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_pages.length, (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == i ? 24 : 8, height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == i ? AppColors.white : Colors.white38,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      )),
                    ),
                    const SizedBox(height: 32),
                    _currentPage == _pages.length - 1
                        ? ElevatedButton(onPressed: _finish, style: ElevatedButton.styleFrom(backgroundColor: AppColors.white, foregroundColor: AppColors.primary), child: const Text('ابدأ الآن', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)))
                        : ElevatedButton(onPressed: () => _controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut), style: ElevatedButton.styleFrom(backgroundColor: AppColors.white, foregroundColor: AppColors.primary), child: const Text('التالي', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold))),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
