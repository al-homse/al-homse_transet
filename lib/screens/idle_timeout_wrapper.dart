import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api_service.dart'; // بدلاً من استيراده بطريقة خاطئة
import 'welcome_screen.dart';

class IdleTimeoutWrapper extends StatefulWidget {
  final Widget child;
  // تحديد مدة الخمول (مثلاً 5 دقائق)
  final Duration timeoutDuration;

  const IdleTimeoutWrapper({
    Key? key,
    required this.child,
    this.timeoutDuration = const Duration(minutes: 60),
  }) : super(key: key);

  @override
  State<IdleTimeoutWrapper> createState() => _IdleTimeoutWrapperState();
}

class _IdleTimeoutWrapperState extends State<IdleTimeoutWrapper> {
  Timer? _idleTimer;

  @override
  void initState() {
    super.initState();
    _resetTimer();
  }

  @override
  void dispose() {
    _idleTimer?.cancel();
    super.dispose();
  }

  // إعادة ضبط المؤقت مع أي تفاعل للمستخدم
  void _resetTimer() {
    _idleTimer?.cancel();
    _idleTimer = Timer(widget.timeoutDuration, _handleIdleTimeout);
  }

  // الدالة التي يتم تنفيذها عند انتهاء الوقت (خمول المستخدم)
  Future<void> _handleIdleTimeout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      String? phone = prefs.getString('userPhone');

      // إذا كان المستخدم مسجلاً دخوله بالفعل، نقوم بتسجيل خروجه تلقائياً
      if (isLoggedIn && phone != null && phone != 'غير مسجل') {
        await ApiService.logoutCustomer(phoneNumber: phone);
      }

      await prefs.clear();

      if (mounted) {
        // تنبيه المستخدم أن جلسته انتهت بسبب عدم النشاط
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم تسجيل الخروج تلقائياً بسبب عدم النشاط لفترة طويلة.'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 4),
          ),
        );

        // العودة لشاشة الترحيب وتصفح الستاك
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const WelcomeScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      print('خطأ في معالجة خمول المستخدم: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // استخدام Listener لمراقبة أي نقرة أو حركة لمس في الشاشة
    return Listener(
      onPointerDown: (_) => _resetTimer(),
      onPointerMove: (_) => _resetTimer(),
      child: widget.child,
    );
  }
}