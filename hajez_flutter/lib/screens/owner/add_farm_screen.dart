import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';
import '../../services/farm_service.dart';

class AddFarmScreen extends StatefulWidget {
  final Map<String, dynamic>? farm;
  const AddFarmScreen({super.key, this.farm});
  @override
  State<AddFarmScreen> createState() => _AddFarmScreenState();
}

class _AddFarmScreenState extends State<AddFarmScreen> {
  final _pageCtrl = PageController();
  int _step = 0;
  bool _loading = false;

  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _whatsappCtrl = TextEditingController();
  final _rulesCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _priceWeekendCtrl = TextEditingController();
  final _capacityCtrl = TextEditingController();
  String _city = 'عمان';
  String _type = 'farm';
  bool _hasPool = false;
  TimeOfDay _checkIn = const TimeOfDay(hour: 14, minute: 0);
  TimeOfDay _checkOut = const TimeOfDay(hour: 12, minute: 0);

  final List<String> _cities = ['عمان','إربد','الزرقاء','السلط','الكرك','العقبة','جرش','عجلون','مادبا','البحر الميت'];
  final List<Map<String,String>> _types = [{'value':'farm','label':'مزرعة'},{'value':'chalet','label':'شاليه'},{'value':'villa','label':'فيلا'},{'value':'resort','label':'منتجع'}];

  bool get _isEdit => widget.farm != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      _nameCtrl.text = widget.farm!['name'] ?? '';
      _descCtrl.text = widget.farm!['description'] ?? '';
      _city = widget.farm!['city'] ?? 'عمان';
      _addressCtrl.text = widget.farm!['address'] ?? '';
      _priceCtrl.text = '${widget.farm!['price_per_night'] ?? ''}';
      _capacityCtrl.text = '${widget.farm!['capacity'] ?? ''}';
      _type = widget.farm!['type'] ?? 'farm';
      _hasPool = widget.farm!['has_pool'] ?? false;
      _whatsappCtrl.text = widget.farm!['whatsapp'] ?? '';
      _rulesCtrl.text = widget.farm!['rules'] ?? '';
    }
  }

  void _save() async {
    setState(() => _loading = true);
    try {
      final data = {
        'name': _nameCtrl.text.trim(), 'description': _descCtrl.text.trim(),
        'city': _city, 'address': _addressCtrl.text.trim(),
        'price_per_night': double.tryParse(_priceCtrl.text) ?? 0,
        'price_per_night_weekend': _priceWeekendCtrl.text.isNotEmpty ? double.tryParse(_priceWeekendCtrl.text) : null,
        'capacity': int.tryParse(_capacityCtrl.text) ?? 0,
        'type': _type, 'has_pool': _hasPool,
        'whatsapp': _whatsappCtrl.text.trim(), 'rules': _rulesCtrl.text.trim(),
        'check_in_time': '${_checkIn.hour.toString().padLeft(2,'0')}:${_checkIn.minute.toString().padLeft(2,'0')}',
        'check_out_time': '${_checkOut.hour.toString().padLeft(2,'0')}:${_checkOut.minute.toString().padLeft(2,'0')}',
      };
      Map<String,dynamic> res;
      if (_isEdit) { res = await FarmService.updateFarm(widget.farm!['id'], data); }
      else { res = await FarmService.createFarm(data); }
      if (res['farm'] != null) {
        if (mounted) { Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_isEdit ? 'تم التحديث ✅' : 'تمت الإضافة ✅', style: const TextStyle(fontFamily: 'Cairo')), backgroundColor: AppColors.success)); }
      } else { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'] ?? 'خطأ', style: const TextStyle(fontFamily: 'Cairo')), backgroundColor: AppColors.error)); }
    } catch (_) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تعذر الاتصال', style: TextStyle(fontFamily: 'Cairo')), backgroundColor: AppColors.error)); }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_isEdit ? 'تعديل المزرعة' : 'إضافة مزرعة'),
        bottom: PreferredSize(preferredSize: const Size.fromHeight(6),
          child: LinearProgressIndicator(value: (_step + 1) / 3, backgroundColor: AppColors.greyLight, color: AppColors.primary)),
      ),
      body: PageView(controller: _pageCtrl, physics: const NeverScrollableScrollPhysics(), children: [_step1(), _step2(), _step3()]),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
        child: Row(children: [
          if (_step > 0) Expanded(child: OutlinedButton(onPressed: () { setState(() => _step--); _pageCtrl.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut); }, child: const Text('رجوع'))),
          if (_step > 0) const SizedBox(width: 12),
          Expanded(child: _step < 2
              ? ElevatedButton(onPressed: () { setState(() => _step++); _pageCtrl.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut); }, child: const Text('التالي'))
              : _loading ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : ElevatedButton(onPressed: _save, child: Text(_isEdit ? 'حفظ التعديلات' : 'إضافة المزرعة'))),
        ]),
      ),
    );
  }

  Widget _step1() => SingleChildScrollView(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const Text('المعلومات الأساسية', style: AppText.heading2), const SizedBox(height: 20),
    _field(_nameCtrl, 'اسم المزرعة', Icons.home_work_outlined),
    const SizedBox(height: 14),
    TextFormField(controller: _descCtrl, maxLines: 4, decoration: const InputDecoration(labelText: 'وصف المزرعة', prefixIcon: Icon(Icons.description_outlined, color: AppColors.primary))),
    const SizedBox(height: 14),
    _dropdown('المدينة', _city, _cities, (v) => setState(() => _city = v!)),
    const SizedBox(height: 14),
    _field(_addressCtrl, 'العنوان التفصيلي', Icons.location_on_outlined),
    const SizedBox(height: 14),
    _field(_whatsappCtrl, 'رقم واتساب (اختياري)', Icons.chat_outlined),
  ]));

  Widget _step2() => SingleChildScrollView(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const Text('التفاصيل والأسعار', style: AppText.heading2), const SizedBox(height: 20),
    const Text('نوع المكان', style: AppText.heading3), const SizedBox(height: 10),
    Wrap(spacing: 10, children: _types.map((t) => GestureDetector(
      onTap: () => setState(() => _type = t['value']!),
      child: AnimatedContainer(duration: const Duration(milliseconds: 200), padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(color: _type == t['value'] ? AppColors.primary : AppColors.greyLight, borderRadius: BorderRadius.circular(25)),
        child: Text(t['label']!, style: TextStyle(color: _type == t['value'] ? AppColors.white : AppColors.dark, fontFamily: 'Cairo'))),
    )).toList()),
    const SizedBox(height: 16),
    Row(children: [Expanded(child: _field(_priceCtrl, 'السعر/ليلة (د.أ)', Icons.attach_money, isNumber: true)), const SizedBox(width: 12), Expanded(child: _field(_priceWeekendCtrl, 'سعر الويكند', Icons.weekend, isNumber: true))]),
    const SizedBox(height: 14),
    _field(_capacityCtrl, 'السعة (عدد الأشخاص)', Icons.people_outline, isNumber: true),
    const SizedBox(height: 14),
    Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(14)),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const Row(children: [Icon(Icons.pool, color: AppColors.primary), SizedBox(width: 8), Text('يوجد مسبح', style: AppText.body)]),
        Switch(value: _hasPool, onChanged: (v) => setState(() => _hasPool = v), activeColor: AppColors.primary),
      ])),
    const SizedBox(height: 14),
    Row(children: [Expanded(child: _timePicker('وقت الدخول', _checkIn, (t) => setState(() => _checkIn = t))), const SizedBox(width: 12), Expanded(child: _timePicker('وقت الخروج', _checkOut, (t) => setState(() => _checkOut = t)))]),
  ]));

  Widget _step3() => SingleChildScrollView(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const Text('القواعد والمرافق', style: AppText.heading2), const SizedBox(height: 20),
    TextFormField(controller: _rulesCtrl, maxLines: 4, decoration: const InputDecoration(labelText: 'قواعد المزرعة (اختياري)', hintText: 'مثال: عائلات فقط، ممنوع التدخين...', prefixIcon: Icon(Icons.rule, color: AppColors.primary))),
    const SizedBox(height: 16),
    const Text('يمكنك إضافة المرافق بعد إنشاء المزرعة', style: AppText.bodyGrey),
  ]));

  Widget _field(TextEditingController ctrl, String label, IconData icon, {bool isNumber = false}) => TextFormField(
    controller: ctrl, keyboardType: isNumber ? TextInputType.number : TextInputType.text,
    decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon, color: AppColors.primary)));

  Widget _dropdown(String label, String value, List<String> items, Function(String?) onChanged) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    decoration: BoxDecoration(color: AppColors.greyLight, borderRadius: BorderRadius.circular(14)),
    child: DropdownButtonHideUnderline(child: DropdownButton<String>(value: value, isExpanded: true,
      items: items.map((i) => DropdownMenuItem(value: i, child: Text(i, style: const TextStyle(fontFamily: 'Cairo')))).toList(),
      onChanged: onChanged)));

  Widget _timePicker(String label, TimeOfDay time, Function(TimeOfDay) onChanged) => GestureDetector(
    onTap: () async { final t = await showTimePicker(context: context, initialTime: time); if (t != null) onChanged(t); },
    child: Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: AppColors.greyLight, borderRadius: BorderRadius.circular(14)),
      child: Row(children: [const Icon(Icons.access_time, color: AppColors.primary, size: 18), const SizedBox(width: 8),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: AppText.small),
          Text('${time.hour.toString().padLeft(2,'0')}:${time.minute.toString().padLeft(2,'0')}', style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
        ])])));
}
