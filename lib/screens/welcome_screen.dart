import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'trip.dart';      
import 'login_screen.dart';     
import 'register_screen.dart';  
import 'app_drawer.dart';       

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool _isLoggedIn = false;
  String _userName = 'زائر';
  String _userPhone = 'غير مسجل';
  bool _isLoading = true; // لمعرفة حالة التحقق أول ما تفتح الصفحة

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  // دالة فحص الذاكرة المحلية
  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    bool loggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (loggedIn) {
      // إذا كان مسجلاً، نجلب بياناته لنعرضها بالقائمة أو نحدث الحالة
      setState(() {
        _isLoggedIn = true;
        _userName = prefs.getString('userName') ?? 'مستخدم';
        _userPhone = prefs.getString('userPhone') ?? '';
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoggedIn = false;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // أثناء فحص البيانات لعرض واجهة نظيفة بدون وميض
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      drawer: AppDrawer(
        userName: _userName,
        userPhone: _userPhone,
      ),
      body: Stack(
        children: [
          SizedBox.expand(
            child: Image.asset(
              'assets/images/logo.png',
              fit: BoxFit.cover,
            ),
          ),
          Container(
            color: Colors.black.withOpacity(0.5),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: Align(
                alignment: Alignment.topLeft,
                child: Builder(
                  builder: (context) => IconButton(
                    icon: const Icon(Icons.menu, color: Colors.white, size: 28),
                    onPressed: () {
                      Scaffold.of(context).openDrawer();
                    },
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Spacer(),
                  const Text(
                    'Alhomse Transet',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(blurRadius: 10, color: Colors.black, offset: Offset(0, 2))
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _isLoggedIn ? 'أهلاً بك مجدداً، $_userName' : 'خدمات الحجز والنقل',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const Spacer(),
                  
                  // زر استعراض الرحلات (يظهر دائماً)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 55),
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TripScreen(isLoggedIn: true),
                        ),
                      );
                    },
                    child: Text(
                      _isLoggedIn ? 'الدخول إلى الرحلات والحجوزات' : 'استعراض الرحلات والحجز',
                      style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  
                  const SizedBox(height: 15),

                  // إذا كان مسجلاً دخوله، سنخفي أزرار تسجيل الدخول وإنشاء حساب تماماً!
                  if (!_isLoggedIn) ...[
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 55),
                        side: const BorderSide(color: Colors.white, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginScreen()),
                        );
                      },
                      child: const Text(
                        'تسجيل الدخول',
                        style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const RegisterScreen()),
                        );
                      },
                      child: const Text(
                        'ليس لديك حساب؟ انشئ حساباً جديداً',
                        style: TextStyle(fontSize: 15, color: Colors.white70),
                      ),
                    ),
                  ],

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}