import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../utils/app_theme.dart';

class FarmCard extends StatelessWidget {
  final Map<String, dynamic> farm;
  final VoidCallback onTap;
  const FarmCard({super.key, required this.farm, required this.onTap});

  String _fixUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    if (url.startsWith('http')) return url;
    return 'https://hajez.esnaad-sa.com$url';
  }

  bool get _isFeatured {
    if (farm['is_featured'] != true) return false;
    final until = farm['featured_until'];
    if (until == null) return true;
    try { return DateTime.parse(until.toString()).isAfter(DateTime.now()); }
    catch (_) { return false; }
  }

  @override
  Widget build(BuildContext context) {
    final reviews = farm['reviews'] as List? ?? [];
    final avgRating = reviews.isEmpty ? 0.0 : reviews.fold<double>(0, (s, r) => s + (r['rating'] ?? 0)) / reviews.length;
    final images = farm['images'] as List? ?? [];
    final rawCover = farm['cover_image'] ?? (images.isNotEmpty ? images[0]['image_path'] : null);
    final coverImage = rawCover != null ? _fixUrl(rawCover.toString()) : null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: _isFeatured ? Border.all(color: const Color(0xFFFFB300), width: 2) : null,
          boxShadow: [
            BoxShadow(
              color: _isFeatured ? const Color(0xFFFFB300).withOpacity(0.25) : AppColors.primary.withOpacity(0.08),
              blurRadius: _isFeatured ? 24 : 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            child: Stack(children: [
              coverImage != null && coverImage.isNotEmpty
                  ? CachedNetworkImage(imageUrl: coverImage, height: 200, width: double.infinity, fit: BoxFit.cover,
                      placeholder: (_, __) => Container(height: 200, color: AppColors.greyLight, child: const Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary))),
                      errorWidget: (_, __, ___) => _placeholder())
                  : _placeholder(),
              Positioned(bottom: 0, left: 0, right: 0,
                child: Container(height: 80, decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [Colors.black.withOpacity(0.5), Colors.transparent])))),

              // شارة مميزة
              if (_isFeatured)
                Positioned(top: 0, left: 0, right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(colors: [Color(0xFFFFB300), Color(0xFFFF6F00)]),
                    ),
                    child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(Icons.star_rounded, color: Colors.white, size: 14),
                      SizedBox(width: 4),
                      Text('مزرعة مميزة', style: TextStyle(color: Colors.white, fontFamily: 'Cairo', fontSize: 12, fontWeight: FontWeight.bold)),
                    ]),
                  )),

              Positioned(top: _isFeatured ? 38 : 12, right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: AppColors.primaryDark.withOpacity(0.85), borderRadius: BorderRadius.circular(20)),
                  child: Text(_typeLabel(farm['type']), style: const TextStyle(color: AppColors.white, fontSize: 11, fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
                )),
              Positioned(top: _isFeatured ? 38 : 12, left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(20)),
                  child: Text('${farm['price_per_night']} د.أ/ليلة', style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 12, fontFamily: 'Cairo')),
                )),
              Positioned(bottom: 12, left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), borderRadius: BorderRadius.circular(20)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.star_rounded, color: AppColors.star, size: 14),
                    const SizedBox(width: 3),
                    Text(avgRating > 0 ? avgRating.toStringAsFixed(1) : 'جديد', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, fontFamily: 'Cairo', color: AppColors.dark)),
                    if (reviews.isNotEmpty) ...[
                      const Text(' · ', style: TextStyle(color: AppColors.grey)),
                      Text('${reviews.length} تقييم', style: const TextStyle(fontSize: 10, fontFamily: 'Cairo', color: AppColors.grey)),
                    ],
                  ]),
                )),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: Text(farm['name'] ?? '', style: AppText.heading3, maxLines: 1, overflow: TextOverflow.ellipsis)),
                if (_isFeatured) const Icon(Icons.verified_rounded, color: Color(0xFFFFB300), size: 18),
              ]),
              const SizedBox(height: 6),
              Row(children: [
                const Icon(Icons.location_on_rounded, size: 14, color: AppColors.primary),
                const SizedBox(width: 3),
                Text(farm['city'] ?? '', style: AppText.small),
                const Spacer(),
                const Icon(Icons.people_outline_rounded, size: 14, color: AppColors.grey),
                const SizedBox(width: 3),
                Text('حتى ${farm['capacity']} شخص', style: AppText.small),
              ]),
              if (farm['has_pool'] == true) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: AppColors.accent.withOpacity(0.5), borderRadius: BorderRadius.circular(20)),
                  child: const Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.pool, size: 12, color: AppColors.primaryDark),
                    SizedBox(width: 4),
                    Text('مسبح', style: TextStyle(fontSize: 11, fontFamily: 'Cairo', color: AppColors.primaryDark, fontWeight: FontWeight.bold)),
                  ]),
                ),
              ],
              if ((farm['amenities'] as List? ?? []).isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(spacing: 6, runSpacing: 4,
                  children: ((farm['amenities'] as List).take(3)).map((a) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: AppColors.greyLight, borderRadius: BorderRadius.circular(20)),
                    child: Text(a['name'] ?? '', style: const TextStyle(fontSize: 11, fontFamily: 'Cairo', color: AppColors.darkSecondary)),
                  )).toList()),
              ],
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _placeholder() => Container(height: 200, width: double.infinity, color: AppColors.greyLight,
    child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.home_work_outlined, size: 50, color: AppColors.grey),
      SizedBox(height: 8),
      Text('لا توجد صورة', style: TextStyle(color: AppColors.grey, fontFamily: 'Cairo')),
    ]));

  String _typeLabel(String? type) {
    switch (type) {
      case 'chalet': return 'شاليه';
      case 'villa': return 'فيلا';
      case 'resort': return 'منتجع';
      default: return 'مزرعة';
    }
  }
}
