import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/app_theme.dart';
import '../../utils/constants.dart';
import '../../services/farm_service.dart';
import '../../services/auth_service.dart';
import '../../widgets/farm_card.dart';
import '../../providers/favorites_provider.dart';
import '../farm/farm_detail_screen.dart';
import '../farm/filter_screen.dart';
import '../booking/my_bookings_screen.dart';
import '../profile/profile_screen.dart';
import '../notifications_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> _farms = [];
  bool _loading = true;
  final _searchCtrl = TextEditingController();
  String _selectedCity = '';
  int _navIndex = 0;
  Map<String, dynamic>? _user;
  Map<String, dynamic> _filters = {};

  final List<Map<String, String>> _cities = [
    {'name': '', 'label': 'الكل', 'emoji': '🌍'},
    {'name': 'عمان', 'label': 'عمان', 'emoji': '🏙️'},
    {'name': 'إربد', 'label': 'إربد', 'emoji': '🌿'},
    {'name': 'الزرقاء', 'label': 'الزرقاء', 'emoji': '🏘️'},
    {'name': 'السلط', 'label': 'السلط', 'emoji': '⛰️'},
    {'name': 'الكرك', 'label': 'الكرك', 'emoji': '🏰'},
    {'name': 'العقبة', 'label': 'العقبة', 'emoji': '🌊'},
    {'name': 'جرش', 'label': 'جرش', 'emoji': '🏛️'},
    {'name': 'البحر الميت', 'label': 'البحر الميت', 'emoji': '💧'},
  ];

  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _loadFarms();
    _loadUser();
    _loadUnreadCount();
    // تحميل معرفات المفضلة مرة واحدة لتلوين القلوب
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FavoritesProvider>().load();
    });
  }

  void _loadUser() async { final u = await AuthService.getUser(); setState(() => _user = u); }

  void _loadUnreadCount() async {
    final res = await FarmService.getUnreadCount();
    final count = int.tryParse(res['unread_count'].toString()) ?? 0;
    if (mounted) setState(() => _unreadCount = count);
  }

  void _loadFarms() async {
    setState(() => _loading = true);
    try {
      final res = await FarmService.getFarms(search: _searchCtrl.text, city: _selectedCity, type: _filters['type'], hasPool: _filters['has_pool'], minPrice: _filters['min_price'], maxPrice: _filters['max_price'], capacity: _filters['capacity']);
      setState(() => _farms = res['data'] ?? []);
    } catch (_) { setState(() => _farms = []); }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(index: _navIndex, children: [_buildHomeTab(), const MyBookingsScreen(), const ProfileScreen()]),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(color: AppColors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 16, offset: const Offset(0, -4))]),
        child: BottomNavigationBar(
          currentIndex: _navIndex,
          onTap: (i) => setState(() => _navIndex = i),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.explore_outlined), activeIcon: Icon(Icons.explore), label: 'استكشف'),
            BottomNavigationBarItem(icon: Icon(Icons.bookmark_outline), activeIcon: Icon(Icons.bookmark), label: 'حجوزاتي'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'حسابي'),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeTab() {
    final name = _user?['name']?.toString().split(' ').first ?? 'زائر';
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 200, pinned: true, backgroundColor: AppColors.white,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: const BoxDecoration(gradient: LinearGradient(colors: [AppColors.primaryDark, AppColors.primary, AppColors.primaryLight], begin: Alignment.topRight, end: Alignment.bottomLeft)),
              child: SafeArea(child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 70),
                child: Row(children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text('أهلاً، $name 👋', style: const TextStyle(color: Colors.white70, fontFamily: 'Cairo', fontSize: 13)),
                    const SizedBox(height: 4),
                    const Text('ابحث عن وجهتك القادمة', style: TextStyle(color: AppColors.white, fontFamily: 'Cairo', fontSize: 20, fontWeight: FontWeight.bold)),
                  ])),
                  // جرس الإشعارات
                  Stack(clipBehavior: Clip.none, children: [
                    IconButton(
                      icon: const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 26),
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen())).then((_) => _loadUnreadCount()),
                    ),
                    if (_unreadCount > 0)
                      Positioned(top: 6, left: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(color: AppColors.error, borderRadius: BorderRadius.circular(10)),
                          constraints: const BoxConstraints(minWidth: 17),
                          child: Text('$_unreadCount', textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 10, fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
                        )),
                  ]),
                  LOGO_BASE64.isEmpty
                      ? const Icon(Icons.home_work_outlined, size: 50, color: Colors.white70)
                      : Image.memory(base64Decode(LOGO_BASE64), height: 55),
                ]),
              )),
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(56),
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 4))]),
              child: Row(children: [
                Expanded(child: TextField(
                  controller: _searchCtrl, onSubmitted: (_) => _loadFarms(),
                  decoration: InputDecoration(
                    hintText: 'ابحث عن مزرعة أو شاليه...',
                    hintStyle: const TextStyle(fontFamily: 'Cairo', color: AppColors.grey, fontSize: 13),
                    prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
                    fillColor: AppColors.white, filled: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    suffixIcon: _searchCtrl.text.isNotEmpty ? IconButton(icon: const Icon(Icons.close, color: AppColors.grey), onPressed: () { _searchCtrl.clear(); _loadFarms(); }) : null,
                  ),
                )),
                Container(
                  margin: const EdgeInsets.only(left: 4, right: 4),
                  decoration: BoxDecoration(color: _filters.isNotEmpty ? AppColors.primary : AppColors.greyLight, borderRadius: BorderRadius.circular(12)),
                  child: IconButton(
                    icon: Icon(Icons.tune_rounded, color: _filters.isNotEmpty ? AppColors.white : AppColors.grey),
                    onPressed: () async {
                      final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => FilterScreen(filters: _filters)));
                      if (result != null) { setState(() => _filters = result); _loadFarms(); }
                    },
                  ),
                ),
              ]),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SizedBox(height: 12),
            SizedBox(height: 40, child: ListView.builder(
              scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _cities.length,
              itemBuilder: (_, i) {
                final c = _cities[i]; final sel = _selectedCity == c['name'];
                return GestureDetector(
                  onTap: () { setState(() => _selectedCity = c['name']!); _loadFarms(); },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(left: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: sel ? AppColors.primary : AppColors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: sel ? AppColors.primary : AppColors.greyMedium),
                      boxShadow: sel ? [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3))] : [],
                    ),
                    child: Text('${c['emoji']} ${c['label']}', style: TextStyle(color: sel ? AppColors.white : AppColors.darkSecondary, fontFamily: 'Cairo', fontSize: 12, fontWeight: sel ? FontWeight.bold : FontWeight.normal)),
                  ),
                );
              },
            )),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(children: [
                Text(_farms.isEmpty ? 'لا توجد نتائج' : '${_farms.length} مكان متاح', style: AppText.heading3),
                if (_filters.isNotEmpty) ...[
                  const Spacer(),
                  GestureDetector(onTap: () { setState(() => _filters = {}); _loadFarms(); }, child: const Text('مسح الفلاتر', style: TextStyle(color: AppColors.primary, fontFamily: 'Cairo', fontSize: 12))),
                ],
              ]),
            ),
          ]),
        ),
        _loading
            ? const SliverFillRemaining(child: Center(child: CircularProgressIndicator(color: AppColors.primary)))
            : _farms.isEmpty
                ? SliverFillRemaining(child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: const [
                    Icon(Icons.search_off_rounded, size: 70, color: AppColors.greyMedium),
                    SizedBox(height: 16),
                    Text('لا توجد مزارع', style: TextStyle(color: AppColors.grey, fontSize: 16, fontFamily: 'Cairo')),
                  ])))
                : SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList(delegate: SliverChildBuilderDelegate(
                      (_, i) => FarmCard(farm: _farms[i], onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => FarmDetailScreen(farmId: _farms[i]['id'])))),
                      childCount: _farms.length,
                    )),
                  ),
      ],
    );
  }
}
