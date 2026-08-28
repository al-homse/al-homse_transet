import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // رابط Google Apps Script الخاص بك
  static const String webAppUrl =
      'https://script.google.com/macros/s/AKfycbycasw7Usvui5S2UO5m3mRDONR9FBFS7qFzB1PHEXw2dd4tIRynDCA6VSqvXLct5Ghs/exec';

  // =================================================================
  // 1. دالة لجلب الرحلات من جدول Trips
  // =================================================================
  static Future<List<dynamic>> fetchTrips() async {
    try {
      final response = await http.get(
        Uri.parse('$webAppUrl?action=getTrips'),
      );

      // جوجل Apps Script يعيد كود 200 أو 302 عند النجاح
      if (response.statusCode == 200 || response.statusCode == 302) {
        final decoded = jsonDecode(response.body);

        // التأكد من أن النتيجة المرتجعة قائمة List
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
      // إعادة طرح الخطأ ليلتقطه FutureBuilder ويظهره للمستخدم بدلاً من افتراض قائمة فارغة
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
      // إرسال البيانات باسم text/plain لتجاوز قيود CORS في الـ Web
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
}