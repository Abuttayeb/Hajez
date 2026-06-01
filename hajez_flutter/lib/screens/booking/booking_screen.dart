import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../utils/app_theme.dart';
import '../../services/farm_service.dart';

class BookingScreen extends StatefulWidget {
  final Map<String, dynamic> farm;
  const BookingScreen({super.key, required this.farm});
  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime? _checkIn, _checkOut;
  int _guests = 2;
  String _paymentMethod = 'cash';
  String _notes = '';
  bool _loading = false;
  bool _checking = false;
  Map<String, dynamic>? _availability;

  void _onDaySelected(DateTime selected, _) {
    setState(() {
      if (_checkIn == null || (_checkIn != null && _checkOut != null)) {
        _checkIn = selected; _checkOut = null; _availability = null;
      } else if (selected.isAfter(_checkIn!)) {
        _checkOut = selected; _checkAvailability();
      } else {
        _checkIn = selected; _checkOut = null; _availability = null;
      }
    });
  }

  void _checkAvailability() async {
    if (_checkIn == null || _checkOut == null) return;
    setState(() => _checking = true);
    try {
      final res = await FarmService.checkAvailability(widget.farm['id'], DateFormat('yyyy-MM-dd').format(_checkIn!), DateFormat('yyyy-MM-dd').format(_checkOut!));
      setState(() => _availability = res);
    } catch (_) {}
    setState(() => _checking = false);
  }

  void _book() async {
    if (_checkIn == null || _checkOut == null) { _showError('اختر تواريخ الحجز'); return; }
    if (_availability?['available'] == false) { _showError('المزرعة غير متاحة في هذه الأيام'); return; }
    setState(() => _loading = true);
    try {
      final res = await FarmService.createBooking(
        farmId: widget.farm['id'],
        checkIn: DateFormat('yyyy-MM-dd').format(_checkIn!),
        checkOut: DateFormat('yyyy-MM-dd').format(_checkOut!),
        guests: _guests, paymentMethod: _paymentMethod,
        notes: _notes.isNotEmpty ? _notes : null,
      );
      if (res['booking'] != null) {
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('تم الحجز بنجاح! ✅', style: TextStyle(fontFamily: 'Cairo')), backgroundColor: AppColors.success, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))));
        }
      } else { _showError(res['message'] ?? 'حدث خطأ'); }
    } catch (_) { _showError('تعذر الاتصال'); }
    setState(() => _loading = false);
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg, style: const TextStyle(fontFamily: 'Cairo')), backgroundColor: AppColors.error, behavior: SnackBarBehavior.floating));
  }

  @override
  Widget build(BuildContext context) {
    final nights = (_checkIn != null && _checkOut != null) ? _checkOut!.difference(_checkIn!).inDays : 0;
    final price = double.tryParse(widget.farm['price_per_night'].toString()) ?? 0.0;
    final total = nights * price;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text('حجز ${widget.farm['name']}')),
      body: SingleChildScrollView(
        child: Column(children: [
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(20)),
            child: TableCalendar(
              firstDay: DateTime.now(), lastDay: DateTime.now().add(const Duration(days: 365)),
              focusedDay: _checkIn ?? DateTime.now(),
              selectedDayPredicate: (day) => isSameDay(day, _checkIn) || isSameDay(day, _checkOut),
              rangeStartDay: _checkIn, rangeEndDay: _checkOut,
              rangeSelectionMode: RangeSelectionMode.toggledOn,
              onDaySelected: _onDaySelected,
              locale: 'ar',
              calendarStyle: CalendarStyle(
                rangeHighlightColor: AppColors.primary.withOpacity(0.15),
                rangeStartDecoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                rangeEndDecoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                selectedDecoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                todayDecoration: BoxDecoration(color: AppColors.primaryLight.withOpacity(0.5), shape: BoxShape.circle),
                outsideDaysVisible: false,
                defaultTextStyle: const TextStyle(fontFamily: 'Cairo'),
                weekendTextStyle: const TextStyle(fontFamily: 'Cairo', color: AppColors.error),
              ),
              headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true, titleTextStyle: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
          if (_checking) const Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: LinearProgressIndicator(color: AppColors.primary)),
          if (_availability != null)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: _availability!['available'] == true ? AppColors.success.withOpacity(0.08) : AppColors.error.withOpacity(0.08), borderRadius: BorderRadius.circular(12)),
              child: Row(children: [
                Icon(_availability!['available'] == true ? Icons.check_circle : Icons.cancel, color: _availability!['available'] == true ? AppColors.success : AppColors.error, size: 18),
                const SizedBox(width: 8),
                Text(_availability!['available'] == true ? 'متاح ✓ — $nights ليالٍ — المجموع: ${_availability!['total_price']} د.أ' : 'غير متاح في هذه الأيام',
                  style: TextStyle(color: _availability!['available'] == true ? AppColors.success : AppColors.error, fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
              ]),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(16)),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  const Row(children: [Icon(Icons.people_outline, color: AppColors.primary), SizedBox(width: 8), Text('عدد الأشخاص', style: AppText.heading3)]),
                  Row(children: [
                    IconButton(onPressed: () { if (_guests > 1) setState(() => _guests--); }, icon: const Icon(Icons.remove_circle_outline, color: AppColors.primary)),
                    Text('$_guests', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
                    IconButton(onPressed: () {
                      final capacity = int.tryParse(widget.farm['capacity'].toString()) ?? 100;
                      if (_guests < capacity) setState(() => _guests++);
                    }, icon: const Icon(Icons.add_circle_outline, color: AppColors.primary)),
                  ]),
                ]),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(16)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Row(children: [Icon(Icons.payment_outlined, color: AppColors.primary), SizedBox(width: 8), Text('طريقة الدفع', style: AppText.heading3)]),
                  const SizedBox(height: 12),
                  ...[
                    {'value': 'cash', 'label': 'كاش عند الوصول', 'icon': Icons.money},
                    {'value': 'cliq', 'label': 'CliQ', 'icon': Icons.phone_android},
                    {'value': 'efawateer', 'label': 'eFAWATEERcom', 'icon': Icons.receipt_long_outlined},
                  ].map((p) => GestureDetector(
                    onTap: () => setState(() => _paymentMethod = p['value'] as String),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: _paymentMethod == p['value'] ? AppColors.primary.withOpacity(0.06) : AppColors.greyLight, borderRadius: BorderRadius.circular(12), border: Border.all(color: _paymentMethod == p['value'] ? AppColors.primary : Colors.transparent, width: 1.5)),
                      child: Row(children: [
                        Icon(p['icon'] as IconData, color: _paymentMethod == p['value'] ? AppColors.primary : AppColors.grey, size: 20),
                        const SizedBox(width: 10),
                        Text(p['label'] as String, style: TextStyle(fontFamily: 'Cairo', color: _paymentMethod == p['value'] ? AppColors.primary : AppColors.dark, fontWeight: FontWeight.w500)),
                        const Spacer(),
                        if (_paymentMethod == p['value']) const Icon(Icons.check_circle, color: AppColors.primary, size: 18),
                      ]),
                    ),
                  )),
                ]),
              ),
              const SizedBox(height: 12),
              TextField(maxLines: 3, onChanged: (v) => _notes = v,
                decoration: const InputDecoration(labelText: 'ملاحظات (اختياري)', hintText: 'أي طلبات خاصة...', prefixIcon: Icon(Icons.note_outlined, color: AppColors.primary))),
              const SizedBox(height: 24),
              if (_checkIn != null && _checkOut != null)
                Container(
                  padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: AppColors.primaryDark.withOpacity(0.05), borderRadius: BorderRadius.circular(16)),
                  child: Column(children: [
                    _row('الوصول', DateFormat('dd/MM/yyyy').format(_checkIn!)),
                    _row('المغادرة', DateFormat('dd/MM/yyyy').format(_checkOut!)),
                    _row('عدد الليالي', '$nights ليالٍ'),
                    _row('عدد الأشخاص', '$_guests أشخاص'),
                    const Divider(),
                    _row('المجموع', '${total.toStringAsFixed(0)} د.أ', bold: true),
                  ]),
                ),
              const SizedBox(height: 20),
              _loading ? const Center(child: CircularProgressIndicator(color: AppColors.primary)) : ElevatedButton(onPressed: _book, child: const Text('تأكيد الحجز')),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _row(String label, String value, {bool bold = false}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: const TextStyle(fontFamily: 'Cairo', color: AppColors.grey)),
      Text(value, style: TextStyle(fontFamily: 'Cairo', fontWeight: bold ? FontWeight.bold : FontWeight.normal, color: bold ? AppColors.primary : AppColors.dark)),
    ]),
  );
}
