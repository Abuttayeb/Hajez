import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import 'auth_service.dart';

class FarmService {
  static Future<Map<String, String>> get _authHeaders async {
    final token = await AuthService.getToken();
    return {'Content-Type': 'application/json', 'Accept': 'application/json', if (token != null) 'Authorization': 'Bearer $token'};
  }

  static Future<Map<String, dynamic>> getFarms({String? search, String? city, String? type, bool? hasPool, double? minPrice, double? maxPrice, int? capacity}) async {
    String url = '$BASE_URL/farms?';
    if (search != null && search.isNotEmpty) url += 'search=$search&';
    if (city != null && city.isNotEmpty) url += 'city=$city&';
    if (type != null) url += 'type=$type&';
    if (hasPool == true) url += 'has_pool=1&';
    if (minPrice != null) url += 'min_price=$minPrice&';
    if (maxPrice != null) url += 'max_price=$maxPrice&';
    if (capacity != null) url += 'capacity=$capacity&';
    final res = await http.get(Uri.parse(url), headers: {'Accept': 'application/json'});
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> getFarm(int id) async {
    final res = await http.get(Uri.parse('$BASE_URL/farms/$id'), headers: {'Accept': 'application/json'});
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> checkAvailability(int farmId, String checkIn, String checkOut) async {
    final res = await http.get(Uri.parse('$BASE_URL/farms/$farmId/availability?check_in=$checkIn&check_out=$checkOut'), headers: {'Accept': 'application/json'});
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> createBooking({required int farmId, required String checkIn, required String checkOut, required int guests, String paymentMethod = 'cash', String? notes}) async {
    final headers = await _authHeaders;
    final res = await http.post(Uri.parse('$BASE_URL/bookings'), headers: headers,
      body: jsonEncode({'farm_id': farmId, 'check_in': checkIn, 'check_out': checkOut, 'guests': guests, 'payment_method': paymentMethod, 'notes': notes}));
    return jsonDecode(res.body);
  }

  static Future<List<dynamic>> getMyBookings() async {
    final headers = await _authHeaders;
    final res = await http.get(Uri.parse('$BASE_URL/my-bookings'), headers: headers);
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> getBooking(int id) async {
    final headers = await _authHeaders;
    final res = await http.get(Uri.parse('$BASE_URL/my-bookings/$id'), headers: headers);
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> cancelBooking(int id, {String? reason}) async {
    final headers = await _authHeaders;
    final res = await http.post(Uri.parse('$BASE_URL/my-bookings/$id/cancel'), headers: headers, body: jsonEncode({'reason': reason}));
    return jsonDecode(res.body);
  }

  static Future<List<dynamic>> getMyFarms() async {
    final headers = await _authHeaders;
    final res = await http.get(Uri.parse('$BASE_URL/my-farms'), headers: headers);
    return jsonDecode(res.body);
  }

  static Future<List<dynamic>> getOwnerBookings() async {
    final headers = await _authHeaders;
    final res = await http.get(Uri.parse('$BASE_URL/owner/bookings'), headers: headers);
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> createFarm(Map<String, dynamic> data) async {
    final headers = await _authHeaders;
    final res = await http.post(Uri.parse('$BASE_URL/farms'), headers: headers, body: jsonEncode(data));
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> updateFarm(int id, Map<String, dynamic> data) async {
    final headers = await _authHeaders;
    final res = await http.put(Uri.parse('$BASE_URL/farms/$id'), headers: headers, body: jsonEncode(data));
    return jsonDecode(res.body);
  }

  static Future<void> deleteFarm(int id) async {
    final headers = await _authHeaders;
    await http.delete(Uri.parse('$BASE_URL/farms/$id'), headers: headers);
  }

  static Future<Map<String, dynamic>> uploadFarmImage({required int farmId, required File imageFile, bool isCover = false}) async {
    final token = await AuthService.getToken();
    final request = http.MultipartRequest('POST', Uri.parse('$BASE_URL/farms/$farmId/images'));
    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Accept'] = 'application/json';
    request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
    request.fields['is_cover'] = isCover ? '1' : '0';
    request.fields['category'] = 'general';
    final streamed = await request.send();
    final res = await http.Response.fromStream(streamed);
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> updateBookingStatus(int id, String status) async {
    final headers = await _authHeaders;
    final res = await http.put(Uri.parse('$BASE_URL/owner/bookings/$id/status'), headers: headers, body: jsonEncode({'status': status}));
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> addReview({required int bookingId, required int rating, String? comment}) async {
    final headers = await _authHeaders;
    final res = await http.post(Uri.parse('$BASE_URL/reviews'), headers: headers, body: jsonEncode({'booking_id': bookingId, 'rating': rating, 'comment': comment}));
    return jsonDecode(res.body);
  }

  static Future<List<dynamic>> getFarmReviews(int farmId) async {
    final res = await http.get(Uri.parse('$BASE_URL/farms/$farmId/reviews'), headers: {'Accept': 'application/json'});
    return jsonDecode(res.body);
  }
}
