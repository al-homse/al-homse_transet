import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'register_screen.dart';
import 'admin_dashboard.dart';
import '../api_service.dart';
import 'welcome_screen.dart';
import 'app_drawer.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _saveUserSession(String name, String phone, String customerId, String totalTrips, String preferredClass) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('customer_status', 'LoggedIn');
    await prefs.setString('userName', name);
    await prefs.setString('passenger_name', name);
    await prefs.setString('userPhone', phone);
    await prefs.setString('phone_number', phone);
    await prefs.setString('customer_id', customerId);
    await prefs.setString('total_trips', totalTrips);
    await prefs.setString('preferred_class', preferredClass);
  }

  void _handleLogin() async {
    String inputName = _nameController.text.trim();
    String inputPhone = _phoneController.text.trim();
    String inputPass = _passwordController.text.trim();

    if (inputName.isEmpty || inputPhone.isEmpty || inputPass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء إدخال جميع البيانات المطلوبة (الاسم الثلاثي، الهاتف، كلمة المرور)')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (inputName == 'admin' && inputPhone == 'admin' && inputPass == 'admin') {
        await _saveUserSession(inputName, inputPhone, 'ADMIN-ID', '0', 'Admin');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AdminDashboard()),
        );
        return;
      }

      Map<String, dynamic> response = await ApiService.loginCustomer(
        passengerName: inputName,
        phoneNumber: inputPhone,
        password: inputPass,
      );

      String status = response['status'] ?? '';
      String message = response['message'] ?? 'حدث خطأ ما';

      if (status == 'success') {
        String customerId = response['customer_id'] ?? response['id'] ?? '---';
        String totalTrips = response['total_trips']?.toString() ?? '0';
        String preferredClass = response['preferred_class'] ?? 'VIP';

        await _saveUserSession(inputName, inputPhone, customerId, totalTrips, preferredClass);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const WelcomeScreen(),
          ),
          (route) => false,
        );
      } else if (status == 'wrong_credentials') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red),
        );
      } else if (status == 'not_found') {
        _showNotRegisteredDialog();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.orange),
        );
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
        content: const Text('الاسم المدخل غير مسجل على خوادمنا، يرجى إنشاء حساب جديد.'),
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
      appBar: AppBar(
        title: const Text('تسجيل الدخول', style: TextStyle(color: Colors.white, fontSize: 18)),
        centerTitle: true,
        backgroundColor: Colors.blue[900],
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
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
                      'تسجيل الدخول',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blue[900]),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _nameController,
                      keyboardType: TextInputType.text,
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