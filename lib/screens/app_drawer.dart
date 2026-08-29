import 'package:flutter/material.dart';
import 'trip.dart';
import 'my_trips_screen.dart'; // شاشة رحلاتي
import 'bookings_screen.dart'; // شاشة الحجوزات
import 'profile_screen.dart'; // شاشة حسابي
import 'main_screen.dart'; // الشاشة الرئيسية

class AppDrawer extends StatelessWidget {
  final String userName;
  final String userPhone;

  const AppDrawer({Key? key, required this.userName, required this.userPhone}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(userName.isEmpty ? 'زائر' : userName, style: const TextStyle(fontWeight: FontWeight.bold)),
            accountNumber: null,
            decoration: BoxDecoration(color: Colors.blue[900]),
            otherAccountsPictures: const [
              CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.person, color: Colors.blue))
            ],
            // نعرض الهاتف ضمن الـ subtitle أو تحت الاسم
            currentAccountPicture: const SizedBox.shrink(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text('الهاتف: $userPhone', style: const TextStyle(color: Colors.grey, fontSize: 13)),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.person, color: Colors.blue),
            title: const Text('حسابي'),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.directions_bus, color: Colors.blue),
            title: const Text('رحلاتي'),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const TripScreen(isLoggedIn: true)));
            },
          ),
          ListTile(
            leading: const Icon(Icons.bookmark, color: Colors.blue),
            title: const Text('الحجوزات'),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const BookingsScreen()));
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('تسجيل الخروج', style: TextStyle(color: Colors.red)),
            onTap: () {
              // مسح بيانات الدخول والعودة للشاشة الرئيسية بدون أزرار الدخول
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const MainScreen(isLoggedIn: false)),
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}