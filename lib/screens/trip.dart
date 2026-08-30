import 'package:flutter/material.dart';
import 'login_screen.dart';   
import 'booking_screen.dart'; 
import '../api_service.dart';
import 'app_drawer.dart'; // استيراد القائمة الجانبية

class TripScreen extends StatefulWidget {
  final String? routeName; 
  final bool isLoggedIn; // متغير لحفظ حالة تسجيل الدخول القادمة من الخارج

  const TripScreen({Key? key, this.routeName, this.isLoggedIn = false}) : super(key: key);

  @override
  State<TripScreen> createState() => _TripScreenState();
}

class _TripScreenState extends State<TripScreen> {
  late Future<List<dynamic>> _tripsFuture;

  @override
  void initState() {
    super.initState();
    _loadTrips();
  }

  // دالة لجلب الرحلات وإتاحة إمكانية التحديث اليدوي
  void _loadTrips() {
    setState(() {
      _tripsFuture = ApiService.fetchTrips();
    });
  }

  @override
  Widget build(BuildContext context) {
    // الاعتماد على الحالة الحقيقية المُستقبلة بدلاً من القيمة الثابتة
    bool isLoggedIn = widget.isLoggedIn;

    return FutureBuilder<List<dynamic>>(
      future: _tripsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: Colors.blueGrey[900],
            appBar: AppBar(
              title: const Text('جاري التحميل...', style: TextStyle(color: Colors.white, fontSize: 18)),
              backgroundColor: Colors.blue[900],
              iconTheme: const IconThemeData(color: Colors.white),
            ),
            drawer: const AppDrawer(userName: 'زائر', userPhone: 'غير مسجل'),
            body: const Center(child: CircularProgressIndicator(color: Colors.white)),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            backgroundColor: Colors.blueGrey[900],
            appBar: AppBar(
              title: const Text('خطأ في الاتصال', style: TextStyle(color: Colors.white, fontSize: 18)),
              backgroundColor: Colors.blue[900],
              iconTheme: const IconThemeData(color: Colors.white),
            ),
            drawer: const AppDrawer(userName: 'زائر', userPhone: 'غير مسجل'),
            body: Center(child: Text('حدث خطأ: ${snapshot.error}', style: const TextStyle(color: Colors.white))),
          );
        }

        List<dynamic> allTrips = snapshot.data ?? [];

        // الحالة الأولى: قائمة الخطوط
        if (widget.routeName == null) {
          List<String> availableRoutes = allTrips
              .map((trip) => trip['route']?.toString() ?? '')
              .where((route) => route.isNotEmpty)
              .toSet()
              .toList();

          if (availableRoutes.isEmpty) {
            availableRoutes = ['دمشق ➔ حمص', 'حمص ➔ دمشق'];
          }

          return Scaffold(
            backgroundColor: Colors.blueGrey[900],
            appBar: AppBar(
              title: const Text('الحجوزات - Alhomse Transet', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18)),
              centerTitle: true,
              backgroundColor: Colors.blue[900],
              elevation: 0,
              iconTheme: const IconThemeData(color: Colors.white),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  tooltip: 'تحديث البيانات',
                  onPressed: _loadTrips,
                ),
              ],
            ),
            // إضافة القائمة الجانبية مع تمرير البيانات الافتراضية
            drawer: const AppDrawer(userName: 'زائر', userPhone: 'غير مسجل'),
            body: Stack(
              children: [
                SizedBox.expand(
                  child: Image.asset(
                    'assets/images/farewell.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(color: Colors.blueGrey[900]);
                    },
                  ),
                ),
                Container(color: Colors.black.withOpacity(0.5)),

                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'أهلاً بك في نظام الحجوزات',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'اختر خط الرحلة المناسب لك وانطلق بكل راحة',
                              style: TextStyle(fontSize: 14, color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'خطوط السفر المتاحة:',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.amberAccent),
                      ),
                      const SizedBox(height: 15),

                      Expanded(
                        child: ListView.builder(
                          itemCount: availableRoutes.length,
                          itemBuilder: (context, index) {
                            final route = availableRoutes[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 15),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.95),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                leading: const Icon(Icons.directions_bus, color: Colors.blueAccent, size: 30),
                                title: Text(
                                  route,
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                                ),
                                subtitle: const Text('الانطلاق من الكراج الشمالي', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => TripScreen(
                                        routeName: route,
                                        isLoggedIn: isLoggedIn,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        // الحالة الثانية: جدول المواعيد للخط المحدد
        List<dynamic> filteredTrips = allTrips
            .where((trip) => trip['route']?.toString() == widget.routeName)
            .toList();

        return Scaffold(
          backgroundColor: Colors.blueGrey[900],
          appBar: AppBar(
            title: Text('مواعيد: ${widget.routeName}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16)),
            centerTitle: true,
            backgroundColor: Colors.blue[900],
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'تحديث المواعيد',
                onPressed: _loadTrips,
              ),
            ],
          ),
          drawer: const AppDrawer(userName: 'زائر', userPhone: 'غير مسجل'),
          body: Stack(
            children: [
              SizedBox.expand(
                child: Image.asset(
                  'assets/images/farewell.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(color: Colors.blueGrey[900]);
                  },
                ),
              ),
              Container(color: Colors.black.withOpacity(0.5)),

              filteredTrips.isEmpty
                  ? const Center(
                      child: Text(
                        'لا توجد رحلات متاحة لهذا الخط حالياً',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: filteredTrips.length,
                      itemBuilder: (context, index) {
                        final trip = filteredTrips[index];
                        
                        String tripId = trip['trip_id']?.toString() ?? 'TRP-001';
                        
                        // معالجة التاريخ بفعالية
                        String rawDate = trip['trip_date']?.toString() ?? '';
                        String tripDate = rawDate.contains('T') ? rawDate.split('T')[0] : rawDate;

                        // معالجة وقت الانطلاق بفعالية
                        String departureTime = trip['departure_time']?.toString() ?? 'غير محدد';
                        if (departureTime.contains('T')) {
                          try {
                            DateTime parsedTime = DateTime.parse(departureTime);
                            departureTime = "${parsedTime.hour.toString().padLeft(2, '0')}:${parsedTime.minute.toString().padLeft(2, '0')}";
                          } catch (_) {}
                        }

                        String vehicleId = trip['vehicle_id']?.toString() ?? trip['bus_number']?.toString() ?? 'باص';
                        int availableSeats = int.tryParse(trip['available_seats']?.toString() ?? '0') ?? 0;
                        int totalSeats = int.tryParse(trip['total_seats']?.toString() ?? '14') ?? 14; 
                        String price = trip['standard_price']?.toString() ?? '0';
                        bool isFull = availableSeats <= 0;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 15),
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.95),
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // عرض التاريخ
                                  Row(
                                    children: [
                                      const Icon(Icons.calendar_today, color: Colors.blueAccent, size: 16),
                                      const SizedBox(width: 6),
                                      Text(
                                        'التاريخ: $tripDate',
                                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  // عرض وقت الانطلاق
                                  Row(
                                    children: [
                                      const Icon(Icons.access_time_filled_rounded, color: Colors.blueAccent, size: 16),
                                      const SizedBox(width: 6),
                                      Text(
                                        'الوقت: $departureTime',
                                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'المركبة: $vehicleId',
                                    style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    isFull ? 'الرحلة ممتلئة' : 'المقاعد المتاحة: $availableSeats',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: isFull ? Colors.red : Colors.green[700],
                                    ),
                                  ),
                                ],
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isFull ? Colors.grey : Colors.blue[800],
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                ),
                                onPressed: isFull
                                    ? null
                                    : () {
                                        if (!isLoggedIn) {
                                          showDialog(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: const Text('تنبيه للمتابعة', style: TextStyle(fontWeight: FontWeight.bold)),
                                              content: const Text('يرجى تسجيل الدخول أو إنشاء حساب للمتابعة نحو حجز المقاعد.'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Navigator.pop(context),
                                                  child: const Text('إلغاء', style: TextStyle(color: Colors.grey)),
                                                ),
                                                ElevatedButton(
                                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[900]),
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                                                    );
                                                  },
                                                  child: const Text('تسجيل الدخول', style: TextStyle(color: Colors.white)),
                                                ),
                                              ],
                                            ),
                                          );
                                        } else {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => BookingScreen(
                                                tripId: tripId,
                                                tripTime: "$tripDate - $departureTime",
                                                busNumber: vehicleId,
                                                price: price,
                                                availableSeats: availableSeats,
                                                totalSeats: totalSeats,
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                child: Text(
                                  isFull ? 'ممتلئ' : 'حجز',
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ],
          ),
        );
      },
    );
  }
}