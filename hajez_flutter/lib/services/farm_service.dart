import 'dart:io';
import 'api_client.dart';

class FarmService {
  static final _api = ApiClient.instance;

  static Future<Map<String, dynamic>> getFarms({String? search, String? city, String? type, bool? hasPool, double? minPrice, double? maxPrice, int? capacity}) async {
    try {
      final query = <String, dynamic>{
        if (search != null && search.isNotEmpty) 'search': search,
        if (city != null && city.isNotEmpty) 'city': city,
        if (type != null) 'type': type,
        if (hasPool == true) 'has_pool': 1,
        if (minPrice != null) 'min_price': minPrice,
        if (maxPrice != null) 'max_price': maxPrice,
        if (capacity != null) 'capacity': capacity,
      };
      final res = await _api.get('/farms', query: query);
      return Map<String, dynamic>.from(res as Map);
    } on ApiException catch (e) {
      return {'success': false, 'message': e.message, 'data': []};
    }
  }

  static Future<Map<String, dynamic>> getFarm(int id) async {
    try {
      final res = await _api.get('/farms/$id');
      return Map<String, dynamic>.from(res as Map);
    } on ApiException catch (e) {
      return {'success': false, 'message': e.message};
    }
  }

  static Future<Map<String, dynamic>> checkAvailability(int farmId, String checkIn, String checkOut) async {
    try {
      final res = await _api.get('/farms/$farmId/availability', query: {'check_in': checkIn, 'check_out': checkOut});
      return Map<String, dynamic>.from(res as Map);
    } on ApiException catch (e) {
      return {'success': false, 'message': e.message};
    }
  }

  static Future<Map<String, dynamic>> createBooking({required int farmId, required String checkIn, required String checkOut, required int guests, String paymentMethod = 'cash', String? notes, String? couponCode}) async {
    try {
      final res = await _api.post('/bookings', data: {
        'farm_id': farmId,
        'check_in': checkIn,
        'check_out': checkOut,
        'guests': guests,
        'payment_method': paymentMethod,
        'notes': notes,
        if (couponCode != null && couponCode.isNotEmpty) 'coupon_code': couponCode,
      });
      return Map<String, dynamic>.from(res as Map);
    } on ApiException catch (e) {
      return {'success': false, 'message': e.message};
    }
  }

  /// التحقق من كوبون خصم قبل الحجز (معاينة الخصم والمجموع النهائي)
  static Future<Map<String, dynamic>> validateCoupon({required String code, required double total}) async {
    try {
      final res = await _api.post('/coupons/validate', data: {'code': code, 'total': total});
      return Map<String, dynamic>.from(res as Map);
    } on ApiException catch (e) {
      return {'valid': false, 'message': e.message, 'discount': 0};
    }
  }

  static Future<List<dynamic>> getMyBookings() async {
    try {
      final res = await _api.get('/my-bookings');
      return res is List ? res : <dynamic>[];
    } on ApiException {
      return <dynamic>[];
    }
  }

  static Future<Map<String, dynamic>> getBooking(int id) async {
    try {
      final res = await _api.get('/my-bookings/$id');
      return Map<String, dynamic>.from(res as Map);
    } on ApiException catch (e) {
      return {'success': false, 'message': e.message};
    }
  }

  static Future<Map<String, dynamic>> cancelBooking(int id, {String? reason}) async {
    try {
      final res = await _api.post('/my-bookings/$id/cancel', data: {'reason': reason});
      return Map<String, dynamic>.from(res as Map);
    } on ApiException catch (e) {
      return {'success': false, 'message': e.message};
    }
  }

  static Future<List<dynamic>> getMyFarms() async {
    try {
      final res = await _api.get('/my-farms');
      return res is List ? res : <dynamic>[];
    } on ApiException {
      return <dynamic>[];
    }
  }

  static Future<List<dynamic>> getOwnerBookings() async {
    try {
      final res = await _api.get('/owner/bookings');
      return res is List ? res : <dynamic>[];
    } on ApiException {
      return <dynamic>[];
    }
  }

  static Future<Map<String, dynamic>> createFarm(Map<String, dynamic> data) async {
    try {
      final res = await _api.post('/farms', data: data);
      return Map<String, dynamic>.from(res as Map);
    } on ApiException catch (e) {
      return {'success': false, 'message': e.message};
    }
  }

  static Future<Map<String, dynamic>> updateFarm(int id, Map<String, dynamic> data) async {
    try {
      final res = await _api.put('/farms/$id', data: data);
      return Map<String, dynamic>.from(res as Map);
    } on ApiException catch (e) {
      return {'success': false, 'message': e.message};
    }
  }

  static Future<void> deleteFarm(int id) async {
    try {
      await _api.delete('/farms/$id');
    } on ApiException {
      // حذف صامت - الشاشة تعيد التحميل وتكتشف النتيجة
    }
  }

  static Future<Map<String, dynamic>> uploadFarmImage({required int farmId, required File imageFile, bool isCover = false}) async {
    try {
      final res = await _api.uploadFile(
        '/farms/$farmId/images',
        file: imageFile,
        fileField: 'image',
        fields: {'is_cover': isCover ? '1' : '0', 'category': 'general'},
      );
      return Map<String, dynamic>.from(res as Map);
    } on ApiException catch (e) {
      return {'success': false, 'message': e.message};
    }
  }

  static Future<Map<String, dynamic>> updateBookingStatus(int id, String status) async {
    try {
      final res = await _api.put('/owner/bookings/$id/status', data: {'status': status});
      return Map<String, dynamic>.from(res as Map);
    } on ApiException catch (e) {
      return {'success': false, 'message': e.message};
    }
  }

  static Future<Map<String, dynamic>> addReview({required int bookingId, required int rating, String? comment}) async {
    try {
      final res = await _api.post('/reviews', data: {'booking_id': bookingId, 'rating': rating, 'comment': comment});
      return Map<String, dynamic>.from(res as Map);
    } on ApiException catch (e) {
      return {'success': false, 'message': e.message};
    }
  }

  static Future<List<dynamic>> getFarmReviews(int farmId) async {
    try {
      final res = await _api.get('/farms/$farmId/reviews');
      return res is List ? res : <dynamic>[];
    } on ApiException {
      return <dynamic>[];
    }
  }
}
