import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_theme.dart';
import '../services/farm_service.dart';
import '../providers/favorites_provider.dart';
import '../widgets/farm_card.dart';
import 'farm/farm_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});
  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<dynamic> _farms = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final farms = await FarmService.getFavorites();
    if (!mounted) return;
    setState(() {
      _farms = farms;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // إزالة فورية من القائمة لما ينشال القلب من داخل هاي الشاشة
    final fav = context.watch<FavoritesProvider>();
    final visible = _farms.where((f) => fav.isFavorite(int.tryParse(f['id'].toString()) ?? -1)).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('المفضلة')),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : visible.isEmpty
              ? Center(
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.favorite_border_rounded, size: 72, color: AppColors.grey.withOpacity(0.4)),
                    const SizedBox(height: 16),
                    const Text('ما أضفت شي للمفضلة بعد', style: TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.dark)),
                    const SizedBox(height: 6),
                    const Text('اضغط على القلب ♥ بأي مزرعة لتحفظها هون', style: TextStyle(fontFamily: 'Cairo', fontSize: 13, color: AppColors.grey)),
                  ]),
                )
              : RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: visible.length,
                    itemBuilder: (context, i) {
                      final farm = visible[i];
                      return FarmCard(
                        farm: farm,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => FarmDetailScreen(farmId: farm['id'])),
                        ).then((_) => _load()),
                      );
                    },
                  ),
                ),
    );
  }
}
