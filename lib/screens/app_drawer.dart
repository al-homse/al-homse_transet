import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'my_trips_screen.dart';
import 'my_bookings_screen.dart';
import 'profile_screen.dart';
import 'login_screen.dart';
import 'welcome_screen.dart';

class AppDrawer extends StatefulWidget {
  final String? userName;
  final String? userPhone;

  const AppDrawer({
    Key? key,
    this.userName,
    this.userPhone,
  }) : super(key: key);

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  late String _userName;
  late String _userPhone;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initUserData();
  }

  Future<void> _initUserData() async {
    // إذا تم تمرير البيانات مباشرة نستخدمها، وإذا لم تُمرر نقرأها من الذاكرة المحلية
    if (widget.userName != null && widget.userPhone != null) {
      setState(() {
        _userName = widget.userName!;
        _userPhone = widget.userPhone!;
        _isLoading = false;
      });
    } else {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _userName = prefs.getString('userName') ?? 'زائر';
        _userPhone = prefs.getString('userPhone') ?? 'غير مسجل';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Drawer(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(
              _userName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            accountEmail: Text(
              _userPhone,
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
          
          // الصفحة الرئيسية
          ListTile(
            leading: const Icon(Icons.home, color: Colors.blue),
            title: const Text('الصفحة الرئيسية'),
            onTap: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const WelcomeScreen()),
                (route) => false,
              );
            },
          ),

          // رحلاتي
          ListTile(
            leading: const Icon(Icons.directions_bus, color: Colors.blue),
            title: const Text('رحلاتي'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => MyTripsScreen(userPhone: _userPhone)),
              );
            },
          ),

          // حجوزاتي
          ListTile(
            leading: const Icon(Icons.bookmark, color: Colors.blue),
            title: const Text('حجوزاتي'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => MyBookingsScreen(userPhone: _userPhone, userName: _userName)),
              );
            },
          ),

          // حسابي وملفي الشخصي
          ListTile(
            leading: const Icon(Icons.person, color: Colors.blue),
            title: const Text('حسابي وملفي الشخصي'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),

          const Divider(),

          // تسجيل الخروج
          ListTile(
            leading: const Icon(Icons.exit_to_app, color: Colors.red),
            title: const Text('تسجيل الخروج', style: TextStyle(color: Colors.red)),
            onTap: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();

              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const WelcomeScreen()),
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