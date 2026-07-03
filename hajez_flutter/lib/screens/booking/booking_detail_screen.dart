import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../../utils/app_theme.dart';
import '../../services/farm_service.dart';

class BookingDetailScreen extends StatefulWidget {
  final int bookingId;
  const BookingDetailScreen({super.key, required this.bookingId});
  @override
  State<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  Map<String, dynamic>? _booking;
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  void _load() async {
    setState(() => _loading = true);
    try { final res = await FarmService.getBooking(widget.bookingId); setState(() => _booking = res); } catch (_) {}
    setState(() => _loading = false);
  }

  void _cancel() async {
    final confirm = await showDialog<bool>(context: context, builder: (_) => AlertDialog(
      title: const Text('إلغاء الحجز', style: TextStyle(fontFamily: 'Cairo')),
      content: const Text('هل أنت متأكد؟', style: TextStyle(fontFamily: 'Cairo')),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('لا')),
        TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('نعم', style: TextStyle(color: AppColors.error))),
      ],
    ));
    if (confirm == true) { await FarmService.cancelBooking(widget.bookingId); _load(); }
  }

  void _addReview() {
    int rating = 5;
    int cleanliness = 5, service = 5, value = 5, location = 5;
    final ctrl = TextEditingController();
    showModalBottomSheet(context: context, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => StatefulBuilder(builder: (context, setSheet) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20),
        child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('أضف تقييمك', style: AppText.heading2),
          const SizedBox(height: 16),
          RatingBar.builder(initialRating: 5, minRating: 1, itemCount: 5,
            itemBuilder: (_, __) => const Icon(Icons.star_rounded, color: AppColors.star),
            onRatingUpdate: (r) => rating = r.toInt()),
          const SizedBox(height: 20),
          _subRating('النظافة 🧹', cleanliness, (v) => setSheet(() => cleanliness = v)),
          _subRating('الخدمة 🤝', service, (v) => setSheet(() => service = v)),
          _subRating('القيمة مقابل السعر 💰', value, (v) => setSheet(() => value = v)),
          _subRating('الموقع 📍', location, (v) => setSheet(() => location = v)),
          const SizedBox(height: 16),
          TextField(controller: ctrl, maxLines: 3, decoration: const InputDecoration(labelText: 'تعليقك (اختياري)')),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              await FarmService.addReview(
                bookingId: widget.bookingId, rating: rating, comment: ctrl.text,
                cleanliness: cleanliness, service: service, value: value, location: location,
              );
              if (mounted) { Navigator.pop(context); _load(); }
            },
            child: const Text('إرسال التقييم'),
          ),
          const SizedBox(height: 16),
        ])),
      )),
    );
  }

  /// صف تقييم فرعي: عنوان + 5 نجوم صغيرة
  Widget _subRating(String label, int current, ValueChanged<int> onChanged) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.dark)),
      Row(children: List.generate(5, (i) => GestureDetector(
        onTap: () => onChanged(i + 1),
        child: Icon(i < current ? Icons.star_rounded : Icons.star_border_rounded, color: AppColors.star, size: 24),
      ))),
    ]),
  );

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator(color: AppColors.primary)));
    if (_booking == null) return const Scaffold(body: Center(child: Text('حدث خطأ')));

    final status = _booking!['status'];
    final farm = _booking!['farm'] ?? {};
    final canCancel = ['pending', 'confirmed'].contains(status);
    final canReview = status == 'completed' && _booking!['review'] == null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('تفاصيل الحجز')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(20)),
            child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('#${_booking!['id']}', style: const TextStyle(fontFamily: 'Cairo', color: AppColors.grey, fontSize: 13)),
                _statusBadge(status),
              ]),
              const Divider(height: 24),
              Text(farm['name'] ?? '', style: AppText.heading2, textAlign: TextAlign.center),
              const SizedBox(height: 4),
              Text(farm['city'] ?? '', style: AppText.bodyGrey, textAlign: TextAlign.center),
              const Divider(height: 24),
              _row('تاريخ الوصول', _booking!['check_in'] ?? ''),
              _row('تاريخ المغادرة', _booking!['check_out'] ?? ''),
              _row('عدد الأشخاص', '${_booking!['guests']} أشخاص'),
              _row('طريقة الدفع', _paymentLabel(_booking!['payment_method'])),
              const Divider(height: 20),
              _row('المجموع', '${_booking!['total_price']} د.أ', bold: true),
            ]),
          ),
          if (_booking!['notes'] != null) ...[
            const SizedBox(height: 16),
            Container(width: double.infinity, padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(16)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('الملاحظات', style: AppText.heading3), const SizedBox(height: 8), Text(_booking!['notes'], style: AppText.body)])),
          ],
          const SizedBox(height: 24),
          if (canCancel) OutlinedButton.icon(onPressed: _cancel, icon: const Icon(Icons.cancel_outlined, color: AppColors.error), label: const Text('إلغاء الحجز', style: TextStyle(color: AppColors.error, fontFamily: 'Cairo')), style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.error))),
          if (canReview) ...[const SizedBox(height: 12), ElevatedButton.icon(onPressed: _addReview, icon: const Icon(Icons.star_outline), label: const Text('أضف تقييمك'))],
        ]),
      ),
    );
  }

  Widget _row(String label, String value, {bool bold = false}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: AppText.bodyGrey),
      Text(value, style: TextStyle(fontFamily: 'Cairo', fontWeight: bold ? FontWeight.bold : FontWeight.normal, color: bold ? AppColors.primary : AppColors.dark)),
    ]),
  );

  Widget _statusBadge(String status) {
    final map = {'pending': ['قيد المراجعة', AppColors.warning], 'confirmed': ['مؤكد', AppColors.success], 'cancelled': ['ملغي', AppColors.error], 'completed': ['مكتمل', AppColors.primary]};
    final c = map[status] ?? ['', AppColors.grey];
    return Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5), decoration: BoxDecoration(color: (c[1] as Color).withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
      child: Text(c[0] as String, style: TextStyle(color: c[1] as Color, fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 12)));
  }

  String _paymentLabel(String? method) {
    switch (method) { case 'cliq': return 'CliQ'; case 'efawateer': return 'eFAWATEERcom'; default: return 'كاش عند الوصول'; }
  }
}
