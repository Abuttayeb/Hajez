import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';
import '../../services/farm_service.dart';

class OwnerBookingsScreen extends StatefulWidget {
  const OwnerBookingsScreen({super.key});
  @override
  State<OwnerBookingsScreen> createState() => _OwnerBookingsScreenState();
}

class _OwnerBookingsScreenState extends State<OwnerBookingsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  List<dynamic> _bookings = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _tabCtrl = TabController(length: 3, vsync: this); _load(); }

  void _load() async {
    setState(() => _loading = true);
    try { final res = await FarmService.getOwnerBookings(); setState(() => _bookings = res); } catch (_) {}
    setState(() => _loading = false);
  }

  List<dynamic> get _pending => _bookings.where((b) => b['status'] == 'pending').toList();
  List<dynamic> get _confirmed => _bookings.where((b) => b['status'] == 'confirmed').toList();
  List<dynamic> get _other => _bookings.where((b) => ['cancelled','completed'].contains(b['status'])).toList();

  void _updateStatus(int id, String status) async {
    await FarmService.updateBookingStatus(id, status); _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('إدارة الحجوزات'),
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _load)],
        bottom: TabBar(
          controller: _tabCtrl,
          labelColor: AppColors.primary, unselectedLabelColor: AppColors.grey, indicatorColor: AppColors.primary,
          labelStyle: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
          tabs: [Tab(text: 'جديد (${_pending.length})'), Tab(text: 'مؤكد (${_confirmed.length})'), Tab(text: 'الكل (${_bookings.length})')],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : TabBarView(controller: _tabCtrl, children: [
              _buildList(_pending, showActions: true),
              _buildList(_confirmed),
              _buildList(_bookings),
            ]),
    );
  }

  Widget _buildList(List<dynamic> list, {bool showActions = false}) {
    if (list.isEmpty) return const Center(child: Text('لا توجد حجوزات', style: TextStyle(color: AppColors.grey, fontFamily: 'Cairo')));
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (_, i) {
        final b = list[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 14), padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(18)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              CircleAvatar(backgroundColor: AppColors.primary.withOpacity(0.1), radius: 22,
                child: Text((b['user']?['name'] ?? 'م')[0], style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontFamily: 'Cairo'))),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(b['user']?['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
                Text(b['user']?['phone'] ?? '', style: AppText.small),
              ])),
              Text('${b['total_price']} د.أ', style: AppText.price.copyWith(fontSize: 14)),
            ]),
            const Divider(height: 16),
            Row(children: [
              const Icon(Icons.home_work_outlined, size: 14, color: AppColors.grey), const SizedBox(width: 4),
              Text(b['farm']?['name'] ?? '', style: AppText.small),
            ]),
            const SizedBox(height: 4),
            Row(children: [
              const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.grey), const SizedBox(width: 4),
              Text('${b['check_in']} ← ${b['check_out']}', style: AppText.small),
              const SizedBox(width: 8),
              const Icon(Icons.people_outline, size: 14, color: AppColors.grey), const SizedBox(width: 4),
              Text('${b['guests']} أشخاص', style: AppText.small),
            ]),
            if (showActions) ...[
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: ElevatedButton.icon(
                  onPressed: () => _updateStatus(b['id'], 'confirmed'),
                  icon: const Icon(Icons.check, size: 16), label: const Text('تأكيد'),
                  style: ElevatedButton.styleFrom(minimumSize: const Size(0, 40)),
                )),
                const SizedBox(width: 10),
                Expanded(child: OutlinedButton.icon(
                  onPressed: () => _updateStatus(b['id'], 'cancelled'),
                  icon: const Icon(Icons.close, size: 16, color: AppColors.error),
                  label: const Text('رفض', style: TextStyle(color: AppColors.error)),
                  style: OutlinedButton.styleFrom(minimumSize: const Size(0, 40), side: const BorderSide(color: AppColors.error)),
                )),
              ]),
            ],
          ]),
        );
      },
    );
  }
}
