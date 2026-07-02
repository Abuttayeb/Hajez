import 'dart:io';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

/// استثناء موحّد برسائل عربية واضحة للمستخدم النهائي
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, {this.statusCode});
  @override
  String toString() => message;
}

/// عميل HTTP مركزي (Singleton) مبني على Dio:
/// - حقن توكن المصادقة تلقائياً في كل طلب
/// - مهلات اتصال معقولة (بدل الانتظار اللانهائي)
/// - تنظيف الجلسة تلقائياً عند 401 (انتهاء التوكن)
/// - رسائل أخطاء عربية مفهومة بدل crash
class ApiClient {
  static final ApiClient _instance = ApiClient._();
  static ApiClient get instance => _instance;

  late final Dio dio;

  ApiClient._() {
    dio = Dio(BaseOptions(
      baseUrl: BASE_URL,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 20),
      sendTimeout: const Duration(seconds: 20),
      headers: {'Accept': 'application/json'},
      // 4xx تُعاد كاستجابة عادية (الشاشات تفحص success/message بنفسها)
      // 5xx فقط تعتبر خطأ سيرفر
      validateStatus: (status) => status != null && status < 500,
    ));

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token');
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onResponse: (response, handler) async {
        // انتهاء الجلسة: نظّف البيانات المحلية تلقائياً
        if (response.statusCode == 401) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove('token');
          await prefs.remove('role');
          await prefs.remove('user');
        }
        handler.next(response);
      },
    ));
  }

  /// تحويل أخطاء Dio/الشبكة لرسائل عربية واضحة
  ApiException _mapError(Object error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return ApiException('انتهت مهلة الاتصال، تحقق من سرعة الإنترنت وحاول مجدداً');
        case DioExceptionType.connectionError:
          return ApiException('تعذر الاتصال بالخادم، تحقق من اتصالك بالإنترنت');
        case DioExceptionType.badResponse:
          return ApiException('حدث خطأ في الخادم، حاول لاحقاً',
              statusCode: error.response?.statusCode);
        case DioExceptionType.cancel:
          return ApiException('تم إلغاء الطلب');
        default:
          if (error.error is SocketException) {
            return ApiException('لا يوجد اتصال بالإنترنت');
          }
          return ApiException('حدث خطأ غير متوقع، حاول مجدداً');
      }
    }
    return ApiException('حدث خطأ غير متوقع، حاول مجدداً');
  }

  Future<dynamic> get(String path, {Map<String, dynamic>? query}) async {
    try {
      final res = await dio.get(path, queryParameters: query);
      return res.data;
    } catch (e) {
      throw _mapError(e);
    }
  }

  Future<dynamic> post(String path, {Object? data}) async {
    try {
      final res = await dio.post(path, data: data);
      return res.data;
    } catch (e) {
      throw _mapError(e);
    }
  }

  Future<dynamic> put(String path, {Object? data}) async {
    try {
      final res = await dio.put(path, data: data);
      return res.data;
    } catch (e) {
      throw _mapError(e);
    }
  }

  Future<dynamic> delete(String path, {Object? data}) async {
    try {
      final res = await dio.delete(path, data: data);
      return res.data;
    } catch (e) {
      throw _mapError(e);
    }
  }

  /// رفع ملفات multipart (صور المزارع)
  Future<dynamic> uploadFile(
    String path, {
    required File file,
    required String fileField,
    Map<String, String> fields = const {},
  }) async {
    try {
      final form = FormData.fromMap({
        ...fields,
        fileField: await MultipartFile.fromFile(file.path),
      });
      final res = await dio.post(path, data: form);
      return res.data;
    } catch (e) {
      throw _mapError(e);
    }
  }
}
