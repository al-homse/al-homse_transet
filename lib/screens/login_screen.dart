import 'package:flutter/material.dart';
import 'register_screen.dart';
import 'admin_dashboard.dart';
import '../api_service.dart';
import 'trip.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  void _handleLogin() async {
    String inputUser = _phoneController.text.trim();
    String inputPass = _passwordController.text.trim();

    if (inputUser.isEmpty || inputPass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء إدخال البيانات المطلوبة')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. التحقق من الأدمن
      if (inputUser == 'admin' && inputPass == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AdminDashboard()),
        );
        return;
      }

      // 2. التحقق الحقيقي من جدول Customer في جوجل شيت (يعيد true إذا وُجد، أو false إذا لم يوجد)
      bool loginSuccess = await ApiService.loginCustomer(
        identifier: inputUser, 
        password: inputPass,
      );

      if (loginSuccess) {
        // حالة ناجحة حقيقية وتم تمرير حالة تسجيل الدخول بنجاح
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم تسجيل دخولك بنجاح!')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const TripScreen(isLoggedIn: true),
          ),
        );
      } else {
        // حالة خاطئة / غير مسجل (تتم محاكاة الـ False وإظهار تنبيه التسجيل)
        _showNotRegisteredDialog();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء الاتصال: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showNotRegisteredDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حساب غير مسجل', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('حساب حضرتكم غير مسجل على خوادمنا، يرجى إنشاء حساب جديد.'),
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
                MaterialPageRoute(builder: (context) => const RegisterScreen()),
              );
            },
            child: const Text('إنشاء حساب', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          Container(color: Colors.black.withOpacity(0.65)),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.92),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'تسجيل الدخول',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blue[900]),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        labelText: 'رقم الهاتف أو اسم المستخدم',
                        prefixIcon: const Icon(Icons.person),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'كلمة المرور (رقم الهاتف)',
                        prefixIcon: const Icon(Icons.lock),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 25),
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[900],
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: _handleLogin,
                            child: const Text('دخول', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                    const SizedBox(height: 15),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const RegisterScreen()),
                        );
                      },
                      child: Text('ليس لديك حساب؟ إنشاء حساب جديد', style: TextStyle(color: Colors.blue[800])),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}