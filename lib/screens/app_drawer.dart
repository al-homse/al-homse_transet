import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // مكتبة التخزين المحلي لمسح بيانات الجلسة عند الخروج
import 'my_trips_screen.dart';
import 'my_bookings_screen.dart';
import 'profile_screen.dart';
import 'login_screen.dart';
import 'welcome_screen.dart'; // استيراد شاشة الترحيب
import 'trip.dart'; // الشاشة الرئيسة للرحلات

class AppDrawer extends StatelessWidget {
  final String userName;
  final String userPhone;

  const AppDrawer({
    Key? key,
    required this.userName,
    required this.userPhone,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(
              userName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            accountEmail: Text(
              userPhone,
              style: const TextStyle(color: Colors.white70),
            ),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 40, color: Colors.blue),
            ),
            decoration: BoxDecoration(
              color: Colors.blue[900],
            ),
          ),
          
          // 0. الصفحة الرئيسية (الرجوع لشاشة الترحيب)
          ListTile(
            leading: const Icon(Icons.home, color: Colors.blue),
            title: const Text('الصفحة الرئيسية'),
            onTap: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const WelcomeScreen(),
                ),
                (route) => false,
              );
            },
          ),

          // 1. رحلاتي
          ListTile(
            leading: const Icon(Icons.directions_bus, color: Colors.blue),
            title: const Text('رحلاتي'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => MyTripsScreen(userPhone: userPhone),
                ),
              );
            },
          ),

          // 2. حجوزاتي
          ListTile(
            leading: const Icon(Icons.bookmark, color: Colors.blue),
            title: const Text('حجوزاتي'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => MyBookingsScreen(userPhone: userPhone, userName: userName),
                ),
              );
            },
          ),

          // 3. حسابي / الملف الشخصي
          ListTile(
            leading: const Icon(Icons.person, color: Colors.blue),
            title: const Text('حسابي وملفي الشخصي'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfileScreen(userName: userName, userPhone: userPhone),
                ),
              );
            },
          ),

          const Divider(),

          // 4. تسجيل الخروج
          ListTile(
            leading: const Icon(Icons.exit_to_app, color: Colors.red),
            title: const Text('تسجيل الخروج', style: TextStyle(color: Colors.red)),
            onTap: () async {
              // مسح بيانات الجلسة المخزنة محلياً عند تسجيل الخروج
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();

              // العودة إلى شاشة الترحيب وحذف الصفحات السابقة من الذاكرة
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WelcomeScreen(),
                  ),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
    );
  }
}