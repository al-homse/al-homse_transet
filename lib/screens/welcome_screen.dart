import 'package:flutter/material.dart';
import 'trip.dart';      // استيراد شاشة مواعيد الرحلات الحقيقية
import 'login_screen.dart';     // استيراد شاشة تسجيل الدخول الحقيقية
import 'register_screen.dart';  // استيراد شاشة إنشاء الحساب الحقيقية
import 'app_drawer.dart';       // استيراد القائمة الجانبية

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ربط القائمة الجانبية بالشاشة مع بيانات الزائر/المستخدم الافتراضية
      drawer: const AppDrawer(
        userName: 'زائر',
        userPhone: 'غير مسجل',
      ),
      body: Stack(
        children: [
          // 1. طبقة الصورة الخلفية (تغطي الشاشة بالكامل)
          SizedBox.expand(
            child: Image.asset(
              'assets/images/logo.png', // تأكد من مسار الصورة لديك
              fit: BoxFit.cover, // لتغطية الشاشة بالكامل دون تشوه
            ),
          ),

          // 2. طبقة تعتيم (Overlay) فوق الصورة لكي تظهر النصوص والأزرار بوضوح
          Container(
            color: Colors.black.withOpacity(0.5), // درجة التعتيم
          ),

          // 3. زر سحب أو إظهار القائمة الجانبية في أعلى الشاشة (اختياري لسهولة الاستخدام)
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

          // 4. المحتويات والنصوص والأزرار في المقدمة
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
                  const Text(
                    'خدمات الحجز والنقل ',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  const Spacer(),

                  // زر استعراض الرحلات (ينقل مباشرة إلى شاشة TripScreen لعرض مواعيد الرحلات)
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
                          builder: (context) =>  TripScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'استعراض الرحلات والحجز',
                      style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // زر تسجيل الدخول (مربوط بشاشة LoginScreen الحقيقية)
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
                        MaterialPageRoute(builder: (context) =>  LoginScreen()),
                      );
                    },
                    child: const Text(
                      'تسجيل الدخول',
                      style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // زر إنشاء حساب (مربوط بشاشة RegisterScreen الحقيقية)
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