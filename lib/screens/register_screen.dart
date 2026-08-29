import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // مكتبة التخزين المحلي
import '../api_service.dart'; // استيراد خدمة الـ API
import 'welcome_screen.dart'; // الانتقال لشاشة الترحيب الرئيسية عند النجاح
import 'app_drawer.dart'; // استيراد القائمة الجانبية

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _preferredClass = 'VIP'; // الفئة المفضلة الافتراضية
  bool _isLoading = false;

  // دالة حفظ بيانات الجلسة محلياً بعد التسجيل الناجح
  Future<void> _saveUserSession(String name, String phone) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('userName', name);
    await prefs.setString('userPhone', phone);
  }

  void _handleRegister() async {
    String name = _nameController.text.trim();
    String phone = _phoneController.text.trim();
    String password = _passwordController.text.trim();

    if (name.isEmpty || phone.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء إكمال جميع الحقول المطلوبة')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // إرسال البيانات الحقيقية إلى جدول Customer عبر الـ ApiService الجديد
      Map<String, dynamic> response = await ApiService.registerCustomer(
        passengerName: name,
        phoneNumber: phone,
        password: password,
        preferredClass: _preferredClass,
      );

      String status = response['status'] ?? '';
      String message = response['message'] ?? 'حدث خطأ ما';

      if (status == 'success') {
        // << حفظ بيانات الجلسة محلياً لضمان ظهور الاسم في الترحيب والقائمة >>
        await _saveUserSession(name, phone);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم إنشاء الحساب وتسجيل الدخول بنجاح!')),
        );
        
        // الانتقال لشاشة الترحيب الرئيسية وحذف شاشات الدخول والتسجيل من التراكم
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const WelcomeScreen(),
          ),
          (route) => false,
        );
      } else if (status == 'exists') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('رقم الهاتف مسجل مسبقاً'), backgroundColor: Colors.red),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.orange),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ في الاتصال: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إنشاء حساب جديد', style: TextStyle(color: Colors.white, fontSize: 18)),
        centerTitle: true,
        backgroundColor: Colors.blue[900],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      // إضافة القائمة الجانبية مع تمرير البيانات الحالية من الحقول
      drawer: AppDrawer(
        userName: _nameController.text.isEmpty ? 'زائر' : _nameController.text,
        userPhone: _phoneController.text.isEmpty ? '+963 ...' : _phoneController.text,
      ),
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
                      'انضم إلى Alhomse Transit',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue[900]),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'الاسم الثلاثي',
                        prefixIcon: const Icon(Icons.person),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: 'رقم الهاتف',
                        prefixIcon: const Icon(Icons.phone),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'كلمة المرور',
                        prefixIcon: const Icon(Icons.lock),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 15),
                    // حقل اختيار الفئة المفضلة ليتطابق مع جدول شيت Customer
                    DropdownButtonFormField<String>(
                      value: _preferredClass,
                      items: ['VIP', 'Standard', 'Economy']
                          .map((cls) => DropdownMenuItem(value: cls, child: Text(cls)))
                          .toList(),
                      onChanged: (val) => setState(() => _preferredClass = val!),
                      decoration: InputDecoration(
                        labelText: 'الفئة المفضلة',
                        prefixIcon: const Icon(Icons.star),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 25),
                    
                    // زر إتمام التسجيل والربط بالحقيقي
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[900],
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: _handleRegister,
                            child: const Text('تسجيل الحساب', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
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