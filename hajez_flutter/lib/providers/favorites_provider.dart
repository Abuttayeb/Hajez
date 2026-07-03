import 'package:flutter/foundation.dart';
import '../services/farm_service.dart';

/// حالة المفضلة مركزياً: مجموعة معرفات + تبديل متفائل (Optimistic)
/// القلب يتلون فوراً وإذا فشل الطلب يرجع لوضعه — تجربة سلسة بدون انتظار.
class FavoritesProvider extends ChangeNotifier {
  final Set<int> _ids = {};
  bool _loaded = false;

  bool isFavorite(int farmId) => _ids.contains(farmId);
  bool get isLoaded => _loaded;
  int get count => _ids.length;

  /// تحميل المعرفات مرة واحدة بعد الدخول (استدعِها من الشاشة الرئيسية)
  Future<void> load() async {
    final ids = await FarmService.getFavoriteIds();
    _ids
      ..clear()
      ..addAll(ids);
    _loaded = true;
    notifyListeners();
  }

  /// تبديل متفائل: حدّث الواجهة فوراً ثم أكّد مع السيرفر
  Future<bool> toggle(int farmId) async {
    final wasFavorite = _ids.contains(farmId);
    if (wasFavorite) {
      _ids.remove(farmId);
    } else {
      _ids.add(farmId);
    }
    notifyListeners();

    final res = await FarmService.toggleFavorite(farmId);
    if (res['favorited'] == null) {
      // فشل الطلب — تراجع عن التغيير
      if (wasFavorite) {
        _ids.add(farmId);
      } else {
        _ids.remove(farmId);
      }
      notifyListeners();
      return wasFavorite;
    }
    // مزامنة مع رد السيرفر (مصدر الحقيقة)
    if (res['favorited'] == true) {
      _ids.add(farmId);
    } else {
      _ids.remove(farmId);
    }
    notifyListeners();
    return res['favorited'] == true;
  }

  /// تفريغ عند تسجيل الخروج
  void clear() {
    _ids.clear();
    _loaded = false;
    notifyListeners();
  }
}
