import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../utils/app_theme.dart';
import '../../services/farm_service.dart';
import '../booking/booking_screen.dart';

class FarmDetailScreen extends StatefulWidget {
  final int farmId;
  const FarmDetailScreen({super.key, required this.farmId});
  @override
  State<FarmDetailScreen> createState() => _FarmDetailScreenState();
}

class _FarmDetailScreenState extends State<FarmDetailScreen> {
  Map<String, dynamic>? _farm;
  bool _loading = true;
  int _currentImage = 0;

  @override
  void initState() { super.initState(); _load(); }

  void _load() async {
    try { final res = await FarmService.getFarm(widget.farmId); setState(() { _farm = res; _loading = false; }); }
    catch (_) { setState(() => _loading = false); }
  }

  String _fixUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    if (url.startsWith('http')) return url;
    return 'https://hajez.esnaad-sa.com$url';
  }

  void _openWhatsApp() async {
    final phone = _farm?['whatsapp'] ?? '';
    if (phone.isEmpty) return;
    final url = 'https://wa.me/$phone';
    if (await canLaunchUrl(Uri.parse(url))) launchUrl(Uri.parse(url));
  }

  void _openMaps() async {
    final lat = _farm?['latitude'];
    final lng = _farm?['longitude'];
    if (lat == null || lng == null) return;
    final url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
    if (await canLaunchUrl(Uri.parse(url))) launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  void _openWaze() async {
    final lat = _farm?['latitude'];
    final lng = _farm?['longitude'];
    if (lat == null || lng == null) return;
    final url = 'https://waze.com/ul?ll=$lat,$lng&navigate=yes';
    if (await canLaunchUrl(Uri.parse(url))) launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator(color: AppColors.primary)));
    if (_farm == null) return const Scaffold(body: Center(child: Text('حدث خطأ', style: TextStyle(fontFamily: 'Cairo'))));

    final rawImages = [
      if (_farm!['cover_image'] != null) _fixUrl(_farm!['cover_image'].toString()),
      ...(_farm!['images'] as List? ?? []).map((i) => _fixUrl(i['image_path']?.toString())).where((u) => u.isNotEmpty),
    ].toSet().toList();

    final reviews = _farm!['reviews'] as List? ?? [];
    final avgRating = reviews.isEmpty ? 0.0 : reviews.fold<double>(0, (s, r) => s + (r['rating'] ?? 0)) / reviews.length;
    final amenities = _farm!['amenities'] as List? ?? [];

    final double? lat = _farm!['latitude'] != null ? double.tryParse(_farm!['latitude'].toString()) : null;
    final double? lng = _farm!['longitude'] != null ? double.tryParse(_farm!['longitude'].toString()) : null;
    final hasLocation = lat != null && lng != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(slivers: [
        SliverAppBar(
          expandedHeight: 300, pinned: true, backgroundColor: AppColors.primaryDark,
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(children: [
              if (rawImages.isNotEmpty)
                PageView.builder(
                  itemCount: rawImages.length,
                  onPageChanged: (i) => setState(() => _currentImage = i),
                  itemBuilder: (_, i) => CachedNetworkImage(imageUrl: rawImages[i], fit: BoxFit.cover,
                    placeholder: (_, __) => Container(color: AppColors.greyLight),
                    errorWidget: (_, __, ___) => Container(color: AppColors.greyLight, child: const Icon(Icons.home_work_outlined, size: 60, color: AppColors.grey))),
                )
              else Container(color: AppColors.greyLight, child: const Center(child: Icon(Icons.home_work_outlined, size: 80, color: AppColors.grey))),
              if (rawImages.length > 1)
                Positioned(bottom: 16, left: 0, right: 0,
                  child: Row(mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(rawImages.length, (i) => AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: _currentImage == i ? 20 : 6, height: 6,
                      decoration: BoxDecoration(color: _currentImage == i ? AppColors.white : Colors.white54, borderRadius: BorderRadius.circular(3)),
                    )))),
              Positioned(bottom: 16, right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(20)),
                  child: Text('${_farm!['price_per_night']} د.أ/ليلة', style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
                )),
            ]),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: Text(_farm!['name'] ?? '', style: AppText.heading1)),
                if (_farm!['whatsapp'] != null)
                  GestureDetector(onTap: _openWhatsApp,
                    child: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: const Color(0xFF25D366).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.chat_outlined, color: Color(0xFF25D366), size: 24))),
              ]),
              const SizedBox(height: 8),
              Row(children: [const Icon(Icons.location_on_rounded, size: 16, color: AppColors.primary), const SizedBox(width: 4), Text('${_farm!['city']} · ${_farm!['address']}', style: AppText.bodyGrey)]),
              const SizedBox(height: 12),
              Row(children: [
                _stat(Icons.star_rounded, avgRating > 0 ? avgRating.toStringAsFixed(1) : 'جديد', AppColors.star),
                const SizedBox(width: 16),
                _stat(Icons.people_outline, 'حتى ${_farm!['capacity']} شخص', AppColors.primary),
                const SizedBox(width: 16),
                _stat(Icons.login_outlined, 'دخول ${_farm!['check_in_time']?.toString().substring(0, 5) ?? ''}', AppColors.secondary),
              ]),
              if (_farm!['is_verified'] == true) ...[
                const SizedBox(height: 10),
                Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: AppColors.success.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                  child: const Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.verified_rounded, size: 14, color: AppColors.success), SizedBox(width: 4), Text('مزرعة موثقة', style: TextStyle(color: AppColors.success, fontFamily: 'Cairo', fontSize: 12, fontWeight: FontWeight.bold))])),
              ],
              const SizedBox(height: 20),
              const Text('عن المزرعة', style: AppText.heading3),
              const SizedBox(height: 8),
              Text(_farm!['description'] ?? '', style: AppText.body.copyWith(height: 1.7)),
              if (_farm!['rules'] != null) ...[
                const SizedBox(height: 20),
                const Text('قواعد المزرعة', style: AppText.heading3),
                const SizedBox(height: 8),
                Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: AppColors.warning.withOpacity(0.08), borderRadius: BorderRadius.circular(12)),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [const Icon(Icons.info_outline, color: AppColors.warning, size: 18), const SizedBox(width: 8), Expanded(child: Text(_farm!['rules']!, style: AppText.body.copyWith(height: 1.6)))])),
              ],
              if (amenities.isNotEmpty) ...[
                const SizedBox(height: 20),
                const Text('المرافق والخدمات', style: AppText.heading3),
                const SizedBox(height: 12),
                Wrap(spacing: 10, runSpacing: 10,
                  children: amenities.map((a) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(color: AppColors.accent.withOpacity(0.5), borderRadius: BorderRadius.circular(25)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.check_circle_outline, size: 14, color: AppColors.primaryDark), const SizedBox(width: 6), Text(a['name'] ?? '', style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, color: AppColors.primaryDark))]),
                  )).toList()),
              ],

              // الموقع
              if (hasLocation) ...[
                const SizedBox(height: 24),
                const Text('الموقع', style: AppText.heading3),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SizedBox(
                    height: 200,
                    child: FlutterMap(
                      options: MapOptions(initialCenter: LatLng(lat!, lng!), initialZoom: 14, interactionOptions: const InteractionOptions(flags: InteractiveFlag.none)),
                      children: [
                        TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', userAgentPackageName: 'com.hajez.app'),
                        MarkerLayer(markers: [
                          Marker(point: LatLng(lat, lng), width: 40, height: 40, child: const Icon(Icons.location_pin, color: AppColors.primary, size: 40)),
                        ]),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: OutlinedButton.icon(
                    onPressed: _openMaps,
                    icon: const Icon(Icons.map_outlined, size: 18),
                    label: const Text('Google Maps', style: TextStyle(fontFamily: 'Cairo')),
                    style: OutlinedButton.styleFrom(foregroundColor: AppColors.primary, side: const BorderSide(color: AppColors.primary)),
                  )),
                  const SizedBox(width: 10),
                  Expanded(child: OutlinedButton.icon(
                    onPressed: _openWaze,
                    icon: const Icon(Icons.navigation_outlined, size: 18),
                    label: const Text('Waze', style: TextStyle(fontFamily: 'Cairo')),
                    style: OutlinedButton.styleFrom(foregroundColor: Colors.blue, side: const BorderSide(color: Colors.blue)),
                  )),
                ]),
              ],

              if (reviews.isNotEmpty) ...[
                const SizedBox(height: 24),
                Row(children: [
                  const Text('التقييمات', style: AppText.heading3),
                  const SizedBox(width: 8),
                  Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: AppColors.star.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.star_rounded, size: 14, color: AppColors.star), const SizedBox(width: 3), Text(avgRating.toStringAsFixed(1), style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, color: AppColors.dark)), Text(' (${reviews.length})', style: const TextStyle(fontFamily: 'Cairo', color: AppColors.grey, fontSize: 12))])),
                ]),
                const SizedBox(height: 12),
                ...reviews.take(3).map((r) => Container(
                  margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(14)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      CircleAvatar(backgroundColor: AppColors.primary.withOpacity(0.1), radius: 18, child: Text((r['user']?['name'] ?? 'م')[0], style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold))),
                      const SizedBox(width: 10),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(r['user']?['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Cairo', fontSize: 13)),
                        Row(children: List.generate(5, (i) => Icon(Icons.star_rounded, size: 12, color: i < (r['rating'] ?? 0) ? AppColors.star : AppColors.greyMedium))),
                      ])),
                    ]),
                    if (r['comment'] != null) ...[const SizedBox(height: 8), Text(r['comment'], style: AppText.body.copyWith(height: 1.5))],
                  ]),
                )),
              ],
              const SizedBox(height: 100),
            ]),
          ),
        ),
      ]),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        decoration: BoxDecoration(color: AppColors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 16, offset: const Offset(0, -4))]),
        child: Row(children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
            const Text('السعر لليلة', style: AppText.small),
            Text('${_farm!['price_per_night']} د.أ', style: AppText.price),
          ]),
          const SizedBox(width: 16),
          Expanded(child: ElevatedButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BookingScreen(farm: _farm!))), child: const Text('احجز الآن'))),
          if (_farm!['whatsapp'] != null) ...[
            const SizedBox(width: 10),
            Container(
              decoration: BoxDecoration(color: const Color(0xFF25D366), borderRadius: BorderRadius.circular(14)),
              child: IconButton(icon: const Icon(Icons.chat, color: AppColors.white), onPressed: _openWhatsApp),
            ),
          ],
        ]),
      ),
    );
  }

  Widget _stat(IconData icon, String label, Color color) => Row(mainAxisSize: MainAxisSize.min, children: [
    Icon(icon, size: 16, color: color), const SizedBox(width: 4),
    Text(label, style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, color: AppColors.darkSecondary)),
  ]);
}
