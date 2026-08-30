import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // رابط Google Apps Script الخاص بك
  static const String webAppUrl =
      'https://script.google.com/macros/s/AKfycbz3C32OPJ5g4oL3YtgH-_Hf1Gsd2bJK_XQYS9q8ioT-NksT-erzlORkfMByA6yUyupf/exec';

  // =================================================================
  // 1. دالة لجلب الرحلات من جدول Trips
  // =================================================================
  static Future<List<dynamic>> fetchTrips() async {
    try {
      final response = await http.get(
        Uri.parse('$webAppUrl?action=getTrips'),
      );

      if (response.statusCode == 200 || response.statusCode == 302) {
        final decoded = jsonDecode(response.body);

        if (decoded is List) {
          return decoded;
        } else if (decoded is Map && decoded.containsKey('trips')) {
          return decoded['trips'];
        }
        return [];
      } else {
        throw Exception('رمز الاستجابة غير متوقع: ${response.statusCode}');
      }
    } catch (e) {
      print('خطأ في جلب البيانات: $e');
      rethrow; 
    }
  }

  // =================================================================
  // 2. دالة لإرسال حجز جديد إلى جدول Bookings
  // =================================================================
  static Future<bool> bookTrip({
    required String tripId,
    required String phoneNumber,
    required String passengerName,
    required String seatNumber,
    required String ticketClass,
    required String ticketPrice,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(webAppUrl),
        headers: {'Content-Type': 'text/plain;charset=UTF-8'},
        body: jsonEncode({
          'action': 'addBooking',
          'trip_id': tripId,
          'phone_number': phoneNumber,
          'passenger_name': passengerName,
          'seat_number': seatNumber,
          'ticket_class': ticketClass,
          'ticket_price': ticketPrice,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 302) {
        final data = jsonDecode(response.body);
        return data['status'] == 'success' || data['result'] == 'success';
      }
      return false;
    } catch (e) {
      print('خطأ في عملية الحجز: $e');
      return false;
    }
  }

  // =================================================================
  // 3. دالة تسجيل دخول الزبون (بالاسم الثلاثي، رقم الهاتف، وكلمة المرور)
  // =================================================================
  static Future<Map<String, dynamic>> loginCustomer({
    required String passengerName,
    required String phoneNumber,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(webAppUrl),
        headers: {'Content-Type': 'text/plain;charset=UTF-8'},
        body: jsonEncode({
          'action': 'login', // يتطابق مع الـ action في سكربت جوجل الجديد
          'passenger_name': passengerName,
          'phone_number': phoneNumber,
          'password': password,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 302) {
        return jsonDecode(response.body); // يعيد الخريطة كاملة (status, message, etc)
      }
      return {"status": "error", "message": "خطأ في الاتصال بالخادم (${response.statusCode})"};
    } catch (e) {
      print('خطأ في تسجيل الدخول: $e');
      return {"status": "error", "message": e.toString()};
    }
  }

  // =================================================================
  // 4. دالة إنشاء حساب جديد وإضافته لجدول Customer
  // =================================================================
  static Future<Map<String, dynamic>> registerCustomer({
    required String passengerName,
    required String phoneNumber,
    required String password,
    required String preferredClass,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(webAppUrl),
        headers: {'Content-Type': 'text/plain;charset=UTF-8'},
        body: jsonEncode({
          'action': 'register', // يتطابق مع الـ action في سكربت جوجل الجديد
          'passenger_name': passengerName,
          'phone_number': phoneNumber,
          'password': password,
          'preferred_class': preferredClass,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 302) {
        return jsonDecode(response.body); // يعيد النتيجة مع حالة الوجود (exists) أو النجاح (success)
      }
      return {"status": "error", "message": "خطأ في الاتصال بالخادم (${response.statusCode})"};
    } catch (e) {
      print('خطأ في إنشاء الحساب: $e');
      return {"status": "error", "message": e.toString()};
    }
  }

  // =================================================================
  // 5. دالة تسجيل الخروج لتحديث حالة المستخدم إلى Offline و LoggedOut في الشيت
  // =================================================================
  static Future<Map<String, dynamic>> logoutCustomer({
    required String phoneNumber,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(webAppUrl),
        headers: {'Content-Type': 'text/plain;charset=UTF-8'},
        body: jsonEncode({
          'action': 'logout', // الإجراء الخاص بتسجيل الخروج في السكربت
          'phone_number': phoneNumber,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 302) {
        return jsonDecode(response.body);
      }
      return {"status": "error", "message": "خطأ في الاتصال بالخادم (${response.statusCode})"};
    } catch (e) {
      print('خطأ في تسجيل الخروج: $e');
      return {"status": "error", "message": e.toString()};
    }
  }
}