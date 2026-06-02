import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../utils/app_theme.dart';
import '../../services/farm_service.dart';
import 'booking_detail_screen.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});
  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  List<dynamic> _bookings = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _tabCtrl = TabController(length: 3, vsync: this); _load(); }

  void _load() async {
    setState(() => _loading = true);
    try { final res = await FarmService.getMyBookings(); setState(() => _bookings = res); } catch (_) {}
    setState(() => _loading = false);
  }

  List<dynamic> _filtered(List<String> statuses) => _bookings.where((b) => statuses.contains(b['status'])).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('حجوزاتي'),
        bottom: TabBar(
          controller: _tabCtrl,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.grey,
          indicatorColor: AppColors.primary,
          labelStyle: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
          tabs: [
            Tab(text: 'قادمة (${_filtered(['pending','confirmed']).length})'),
            Tab(text: 'مكتملة (${_filtered(['completed']).length})'),
            Tab(text: 'ملغية (${_filtered(['cancelled']).length})'),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : RefreshIndicator(
              onRefresh: () async => _load(),
              child: TabBarView(controller: _tabCtrl, children: [
                _buildList(_filtered(['pending','confirmed'])),
                _buildList(_filtered(['completed'])),
                _buildList(_filtered(['cancelled'])),
              ]),
            ),
    );
  }

  Widget _buildList(List<dynamic> bookings) {
    if (bookings.isEmpty) return const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.bookmark_outline, size: 70, color: AppColors.greyMedium),
      SizedBox(height: 16),
      Text('لا توجد حجوزات', style: TextStyle(color: AppColors.grey, fontFamily: 'Cairo', fontSize: 16)),
    ]));
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: bookings.length,
      itemBuilder: (_, i) => _BookingCard(booking: bookings[i], onTap: () async {
        await Navigator.push(context, MaterialPageRoute(builder: (_) => BookingDetailScreen(bookingId: bookings[i]['id'])));
        _load();
      }),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final Map<String, dynamic> booking;
  final VoidCallback onTap;
  const _BookingCard({required this.booking, required this.onTap});

  String _fixUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    if (url.startsWith('http')) return url;
    return 'https://hajez.esnaad-sa.com$url';
  }

  @override
  Widget build(BuildContext context) {
    final status = booking['status'] ?? 'pending';
    final sc = {
      'pending': {'label': 'قيد المراجعة', 'color': AppColors.warning},
      'confirmed': {'label': 'مؤكد', 'color': AppColors.success},
      'cancelled': {'label': 'ملغي', 'color': AppColors.error},
      'completed': {'label': 'مكتمل', 'color': AppColors.primary},
    }[status] ?? {'label': '', 'color': AppColors.grey};
    final farm = booking['farm'] ?? {};
    final images = farm['images'] as List? ?? [];
    final rawCover = farm['cover_image'] ?? (images.isNotEmpty ? images[0]['image_path'] : null);
    final coverImage = rawCover != null ? _fixUrl(rawCover.toString()) : null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(18)),
        child: Column(children: [
          if (coverImage != null && coverImage.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
              child: CachedNetworkImage(
                imageUrl: coverImage,
                height: 130, width: double.infinity, fit: BoxFit.cover,
                placeholder: (_, __) => Container(height: 130, color: AppColors.greyLight),
                errorWidget: (_, __, ___) => Container(height: 130, color: AppColors.greyLight),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: Text(farm['name'] ?? '', style: AppText.heading3, maxLines: 1, overflow: TextOverflow.ellipsis)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: (sc['color'] as Color).withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                  child: Text(sc['label'] as String, style: TextStyle(color: sc['color'] as Color, fontFamily: 'Cairo', fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ]),
              const SizedBox(height: 8),
              Row(children: [
                const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.grey),
                const SizedBox(width: 4),
                Text('${booking['check_in']} → ${booking['check_out']}', style: AppText.small),
                const Spacer(),
                Text('${booking['total_price']} د.أ', style: AppText.price.copyWith(fontSize: 14)),
              ]),
            ]),
          ),
        ]),
      ),
    );
  }
}
