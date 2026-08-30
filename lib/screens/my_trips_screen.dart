import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../api_service.dart'; // تأكد من مسار الـ ApiService لديك
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

  // التحقق من حالة تسجيل الدخول وجلب الرحلات الخاصة برقم الهاتف المخزن
  Future<void> _checkUserAndFetchTrips() async {
    final prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    String phone = prefs.getString('phone_number') ?? prefs.getString('userPhone') ?? '';

    // إذا كان الحساب زائر أو لا يوجد رقم هاتف مسجل
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

    // جلب الرحلات الخاصة بهذا الرقم من الـ API
    await _fetchCustomerTrips(phone);
  }

  Future<void> _fetchCustomerTrips(String phone) async {
    try {
      // استدعاء جلب الرحلات أو الحجوزات الخاصة بالمستخدم من الـ WebApp
      // (يمكنك تعديل أو إضافة دالة في ApiService أو استدعاء الرابط مباشرة بناءً على تصميم الشيت لديك)
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
            _userTrips = []; // لا توجد رحلات وهمية أو افتراضية
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

  // تحديد لون حالة الرحلة بحسب المطلوب
  Color _getStatusColor(String status) {
    switch (status.trim().toLowerCase()) {
      case 'مكتملة':
      case 'completed':
        return Colors.green;
      case 'جارية':
      case 'ongoing':
      case 'active':
        return Colors.amber[800]!;
      case 'ملغاة':
      case 'cancelled':
        return Colors.red;
      case 'فائتة':
      case 'missed':
        return Colors.black;
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
              ? _buildGuestView() // 1. حالة الزائر
              : _buildUserTripsView(), // 2. حالة المستخدم المسجل
    );
  }

  // واجهة الزائر (عندما لا يكون مسجلاً)
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

  // واجهة قائمة الرحلات للمستخدم المسجل (بدون أي بيانات تجريبية)
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
        
        // مفاتيح البيانات القادمة من الشيت (تأكد من مطابقتها لأعمدة جدول الحجوزات لديك)
        String tripId = trip['trip_id'] ?? trip['id'] ?? '---';
        String routeLine = trip['route'] ?? trip['line'] ?? 'حمص - دمشق';
        String date = trip['date'] ?? trip['trip_date'] ?? '---';
        String time = trip['time'] ?? trip['departure_time'] ?? '---';
        String status = trip['status'] ?? 'جارية'; // الحالة الافتراضية أو القادمة من السيرفر

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
                // الصف العلوي: معرف الرحلة وحالة الرحلة الملونة
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
                // الخط / الاتجاه
                Row(
                  children: [
                    const Icon(Icons.alt_route, size: 18, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text('الخط: $routeLine', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  ],
                ),
                const SizedBox(height: 8),
                // تاريخ وموعد الانطلاق
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
              ],
            ),
          ),
        );
      },
    );
  }
}