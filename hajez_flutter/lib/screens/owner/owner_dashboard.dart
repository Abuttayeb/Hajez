import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';
import '../../services/farm_service.dart';
import 'add_farm_screen.dart';
import 'my_farms_screen.dart';
import 'owner_bookings_screen.dart';

class OwnerDashboard extends StatefulWidget {
  const OwnerDashboard({super.key});
  @override
  State<OwnerDashboard> createState() => _OwnerDashboardState();
}

class _OwnerDashboardState extends State<OwnerDashboard> {
  List<dynamic> _farms = [];
  List<dynamic> _bookings = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  void _load() async {
    setState(() => _loading = true);
    try {
      final farms = await FarmService.getMyFarms();
      final bookings = await FarmService.getOwnerBookings();
      setState(() { _farms = farms; _bookings = bookings; });
    } catch (_) {}
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final pending = _bookings.where((b) => b['status'] == 'pending').length;
    final revenue = _bookings.where((b) => b['status'] == 'completed').fold<double>(0, (s, b) => s + (b['total_price'] as num).toDouble());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('لوحة المالك'), actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _load)]),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : RefreshIndicator(
              onRefresh: () async => _load(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    _stat('مزارعي', '${_farms.length}', Icons.agriculture, AppColors.primary),
                    const SizedBox(width: 10),
                    _stat('طلبات جديدة', '$pending', Icons.pending_outlined, AppColors.warning),
                    const SizedBox(width: 10),
                    _stat('إيراداتي', '${revenue.toStringAsFixed(0)} د.أ', Icons.attach_money, AppColors.success),
                  ]),
                  const SizedBox(height: 20),
                  const Text('الإجراءات السريعة', style: AppText.heading3),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(child: _action(Icons.add_circle_outline, 'إضافة مزرعة', AppColors.primary, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddFarmScreen())).then((_) => _load()))),
                    const SizedBox(width: 10),
                    Expanded(child: _action(Icons.list_alt_outlined, 'مزارعي', AppColors.secondary, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyFarmsScreen())))),
                    const SizedBox(width: 10),
                    Expanded(child: _action(Icons.book_online_outlined, 'الحجوزات', AppColors.warning, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OwnerBookingsScreen())))),
                  ]),
                  const SizedBox(height: 20),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    const Text('طلبات جديدة', style: AppText.heading3),
                    TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OwnerBookingsScreen())), child: const Text('عرض الكل', style: TextStyle(fontFamily: 'Cairo', color: AppColors.primary))),
                  ]),
                  ..._bookings.where((b) => b['status'] == 'pending').take(3).map((b) => _bookingCard(b)),
                  if (_bookings.where((b) => b['status'] == 'pending').isEmpty)
                    Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(16)),
                      child: const Center(child: Text('لا توجد طلبات جديدة', style: TextStyle(color: AppColors.grey, fontFamily: 'Cairo')))),
                ]),
              ),
            ),
    );
  }

  Widget _stat(String label, String value, IconData icon, Color color) => Expanded(
    child: Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(14)),
      child: Column(children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 6),
        Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color, fontFamily: 'Cairo')),
        Text(label, style: const TextStyle(color: AppColors.grey, fontFamily: 'Cairo', fontSize: 11), textAlign: TextAlign.center),
      ])),
  );

  Widget _action(IconData icon, String label, Color color, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(14), border: Border.all(color: color.withOpacity(0.3))),
      child: Column(children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 6),
        Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontFamily: 'Cairo', fontSize: 12), textAlign: TextAlign.center),
      ])),
  );

  Widget _bookingCard(Map<String, dynamic> b) => Container(
    margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(14)),
    child: Row(children: [
      CircleAvatar(backgroundColor: AppColors.primary.withOpacity(0.1), radius: 20,
        child: Text((b['user']?['name'] ?? 'م')[0], style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontFamily: 'Cairo'))),
      const SizedBox(width: 10),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(b['user']?['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
        Text('${b['check_in']} ← ${b['check_out']}', style: AppText.small),
      ])),
      Text('${b['total_price']} د.أ', style: AppText.price.copyWith(fontSize: 13)),
    ]),
  );
}
