import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../utils/app_theme.dart';
import '../../services/farm_service.dart';
import 'add_farm_screen.dart';

class MyFarmsScreen extends StatefulWidget {
  const MyFarmsScreen({super.key});
  @override
  State<MyFarmsScreen> createState() => _MyFarmsScreenState();
}

class _MyFarmsScreenState extends State<MyFarmsScreen> {
  List<dynamic> _farms = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  void _load() async {
    setState(() => _loading = true);
    try { final res = await FarmService.getMyFarms(); setState(() => _farms = res); } catch (_) {}
    setState(() => _loading = false);
  }

  void _delete(int id) async {
    final confirm = await showDialog<bool>(context: context, builder: (_) => AlertDialog(
      title: const Text('حذف المزرعة', style: TextStyle(fontFamily: 'Cairo')),
      content: const Text('هل أنت متأكد؟', style: TextStyle(fontFamily: 'Cairo')),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('لا')),
        TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('حذف', style: TextStyle(color: AppColors.error))),
      ],
    ));
    if (confirm == true) { await FarmService.deleteFarm(id); _load(); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('مزارعي')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddFarmScreen())).then((_) => _load()),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: AppColors.white),
        label: const Text('إضافة مزرعة', style: TextStyle(color: AppColors.white, fontFamily: 'Cairo')),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _farms.isEmpty
              ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.agriculture_outlined, size: 80, color: AppColors.greyMedium),
                  const SizedBox(height: 16),
                  const Text('لا توجد مزارع بعد', style: TextStyle(color: AppColors.grey, fontSize: 16, fontFamily: 'Cairo')),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddFarmScreen())).then((_) => _load()),
                    icon: const Icon(Icons.add), label: const Text('أضف مزرعتك الأولى'),
                  ),
                ]))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _farms.length,
                  itemBuilder: (_, i) {
                    final f = _farms[i];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(18)),
                      child: Column(children: [
                        if (f['cover_image'] != null)
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                            child: CachedNetworkImage(imageUrl: f['cover_image'], height: 140, width: double.infinity, fit: BoxFit.cover),
                          ),
                        Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(children: [
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(f['name'] ?? '', style: AppText.heading3),
                              const SizedBox(height: 4),
                              Row(children: [
                                const Icon(Icons.location_on_rounded, size: 13, color: AppColors.primary),
                                Text(f['city'] ?? '', style: AppText.small),
                                const SizedBox(width: 8),
                                Text('${f['price_per_night']} د.أ/ليلة', style: const TextStyle(color: AppColors.primary, fontFamily: 'Cairo', fontSize: 12, fontWeight: FontWeight.bold)),
                              ]),
                            ])),
                            PopupMenuButton(
                              itemBuilder: (_) => [
                                const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, color: AppColors.primary, size: 18), SizedBox(width: 8), Text('تعديل', style: TextStyle(fontFamily: 'Cairo'))])),
                                const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, color: AppColors.error, size: 18), SizedBox(width: 8), Text('حذف', style: TextStyle(fontFamily: 'Cairo'))])),
                              ],
                              onSelected: (v) {
                                if (v == 'edit') Navigator.push(context, MaterialPageRoute(builder: (_) => AddFarmScreen(farm: f))).then((_) => _load());
                                else if (v == 'delete') _delete(f['id']);
                              },
                            ),
                          ]),
                        ),
                      ]),
                    );
                  },
                ),
    );
  }
}
