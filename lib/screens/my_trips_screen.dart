import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../api_service.dart'; 
import 'login_screen.dart';

class MyTripsScreen extends StatefulWidget {
  const MyTripsScreen({Key? key}) : super(key: key);

  @override
  State<MyTripsScreen> createState() => _MyTripsScreenState();
}

class _MyTripsScreenState extends State<MyTripsScreen> {
  bool _isLoading = true;
  bool _isLoggedIn = false;
  String _customerPhone = '';
  List<dynamic> _userTrips = [];

  @override
  void initState() {
    super.initState();
    _checkUserAndFetchTrips();
  }

  Future<void> _checkUserAndFetchTrips() async {
    final prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    String phone = prefs.getString('phone_number') ?? prefs.getString('userPhone') ?? '';

    if (!isLoggedIn || phone.isEmpty) {
      setState(() {
        _isLoggedIn = false;
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoggedIn = true;
      _customerPhone = phone;
    });

    await _fetchCustomerTrips(phone);
  }

  Future<void> _fetchCustomerTrips(String phone) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiService.webAppUrl}?action=getCustomerBookings&phone_number=$phone'),
      );

      if (response.statusCode == 200 || response.statusCode == 302) {
        final decoded = jsonDecode(response.body);
        if (decoded is List) {
          setState(() {
            _userTrips = decoded;
            _isLoading = false;
          });
        } else if (decoded is Map && decoded.containsKey('bookings')) {
          setState(() {
            _userTrips = decoded['bookings'];
            _isLoading = false;
          });
        } else {
          setState(() {
            _userTrips = [];
            _isLoading = false;
          });
        }
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print('خطأ في جلب رحلات المستخدم: $e');
      setState(() => _isLoading = false);
    }
  }

  // دالة ذكية لحساب حالة الرحلة تلقائياً بناءً على الوقت والتاريخ وعمود M (وقت الانتهاء)
  String _calculateDynamicStatus(Map<String, dynamic> trip) {
    String originalStatus = trip['booking_status'] ?? 'Confirmed';
    if (originalStatus.toLowerCase() == 'cancelled' || originalStatus == 'ملغاة') {
      return 'ملغاة';
    }

    try {
      String dateStr = trip['trip_date'] ?? '';
      String departureStr = trip['departure_time'] ?? '';
      String arrivalStr = trip['arrival_time'] ?? ''; // وقت الانتهاء من العمود M

      if (dateStr.isEmpty || departureStr.isEmpty) return 'جارية';

      DateTime now = DateTime.now();
      
      // تحليل التاريخ (نفترض صيغة يطابقها الشيت مثل YYYY-MM-DD أو دمجها)
      // سنقوم بمحاولة تحليل التاريخ بمرونة
      DateTime? tripDate = DateTime.tryParse(dateStr);
      if (tripDate == null) return 'جارية';

      // دمج تاريخ الرحلة مع وقت الانطلاق ووقت الوصول للمقارنة الدقيقة
      DateTime startDateTime = _parseDateTimeCombined(tripDate, departureStr);
      DateTime endDateTime = arrivalStr.isNotEmpty 
          ? _parseDateTimeCombined(tripDate, arrivalStr) 
          : startDateTime.add(const Duration(hours: 3)); // افتراض مدة 3 ساعات إذا لم يُحدد عمود M بدقة

      if (now.isBefore(startDateTime)) {
        return 'لم تبدأ بعد';
      } else if (now.isAfter(startDateTime) && now.isBefore(endDateTime)) {
        return 'جارية';
      } else {
        return 'منتهية';
      }
    } catch (e) {
      return 'جارية';
    }
  }

  DateTime _parseDateTimeCombined(DateTime datePart, String timeStr) {
    try {
      // معالجة صيغ مثل "08:00 AM"
      bool isPM = timeStr.toUpperCase().contains('PM');
      bool isAM = timeStr.toUpperCase().contains('AM');
      
      String cleanTime = timeStr.replaceAll(RegExp(r'[^0-9:]'), '');
      List<String> parts = cleanTime.split(':');
      int hour = parts.isNotEmpty ? int.parse(parts[0]) : 0;
      int minute = parts.length > 1 ? int.parse(parts[1]) : 0;

      if (isPM && hour < 12) hour += 12;
      if (isAM && hour == 12) hour = 0;

      return DateTime(datePart.year, datePart.month, datePart.day, hour, minute);
    } catch (e) {
      return datePart;
    }
  }

  // تحديد لون حالة الرحلة (مع إضافة اللون الأزرق لـ "لم تبدأ بعد")
  Color _getStatusColor(String status) {
    switch (status.trim()) {
      case 'منتهية':
      case 'Completed':
        return Colors.green;
      case 'جارية':
      case 'Ongoing':
        return Colors.amber[800]!;
      case 'لم تبدأ بعد':
        return Colors.blue; // اللون المطلوب للرحلات التي لم تبدأ
      case 'ملغاة':
      case 'Cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('سجل رحلاتي', style: TextStyle(color: Colors.white, fontSize: 18)),
        centerTitle: true,
        backgroundColor: Colors.blue[900],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : !_isLoggedIn
              ? _buildGuestView() 
              : _buildUserTripsView(), 
    );
  }

  Widget _buildGuestView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.account_circle_outlined, size: 80, color: Colors.blue[900]),
            const SizedBox(height: 20),
            const Text(
              'يرجى تسجيل الدخول لعرض قائمة الرحلات',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 25),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[900],
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
              child: const Text('تسجيل الدخول', style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserTripsView() {
    if (_userTrips.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.receipt_long_outlined, size: 70, color: Colors.grey),
            const SizedBox(height: 15),
            const Text(
              'لا توجد رحلات مسجلة في سجلك حتى الآن',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _userTrips.length,
      itemBuilder: (context, index) {
        final trip = _userTrips[index];
        
        String tripId = trip['trip_id'] ?? trip['id'] ?? '---';
        String routeLine = trip['route'] ?? trip['line'] ?? 'حمص - دمشق';
        String date = trip['trip_date'] ?? '---';
        String time = trip['departure_time'] ?? '---';
        String arrivalTime = trip['arrival_time'] ?? '---'; // وقت الانتهاء من عمود M

        // حساب الحالة ديناميكياً (لم تبدأ بعد، جارية، منتهية، ملغاة)
        String status = _calculateDynamicStatus(trip);
        Color statusColor = _getStatusColor(status);

        return Card(
          elevation: 3,
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'معرف الرحلة: $tripId',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.blue[900]),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: statusColor),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 20),
                Row(
                  children: [
                    const Icon(Icons.alt_route, size: 18, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text('الخط: $routeLine', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                        const SizedBox(width: 6),
                        Text('التاريخ: $date', style: const TextStyle(fontSize: 13, color: Colors.grey)),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 16, color: Colors.grey),
                        const SizedBox(width: 6),
                        Text('الانطلاق: $time', style: const TextStyle(fontSize: 13, color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.timer_off_outlined, size: 16, color: Colors.grey),
                    const SizedBox(width: 6),
                    Text('الوصول (الانتهاء): $arrivalTime', style: const TextStyle(fontSize: 13, color: Colors.grey)),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}