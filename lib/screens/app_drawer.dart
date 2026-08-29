import 'package:flutter/material.dart';
import 'trip.dart';
import 'my_trips_screen.dart'; // شاشة رحلاتي
import 'booking_screen.dart';  // شاشة الحجز (تم تعديل الاسم بدون s زراِئدة)
import 'profile_screen.dart'; // شاشة حسابي
import 'main_screen.dart';    // الشاشة الرئيسية

class AppDrawer extends StatelessWidget {
  final String userName;
  final String userPhone;

  // إزالة كلمة const من الكونستركتور لأنه يستقبل متغيرات غير ثابتة
  const AppDrawer({super.key, required this.userName, required this.userPhone});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(
              userName.isEmpty ? 'زائر' : userName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            // استخدام accountEmail بدلاً من accountNumber الوهمية لعرض رقم الهاتف أو تفاصيل إضافية
            accountEmail: Text(userPhone),
            decoration: const BoxDecoration(color: Colors.blue),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: Colors.blue),
            ),
          ),
          
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('الرئيسية'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const MainScreen(isLoggedIn: true)),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.bookmark_add),
            title: const Text('حجز مقعد'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => BookingScreen(userName: userName, userPhone: userPhone)),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.list_alt),
            title: const Text('رحلاتي الحجوزات'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => MyTripsScreen(userPhone: userPhone)),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('حسابي'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ProfileScreen(userName: userName, userPhone: userPhone)),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.exit_toapp, color: Colors.red),
            title: const Text('تسجيل الخروج', style: TextStyle(color: Colors.red)),
            onTap: () {
              // العودة لصفحة البداية أو تسجيل الدخول
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
          ),
        ],
      ),
    );
  }
}