import 'package:flutter/material.dart';
import 'app_drawer.dart';

class MyBookingsScreen extends StatelessWidget {
  final String userPhone;
  final String userName;

  const MyBookingsScreen({Key? key, required this.userPhone, required this.userName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('حجوزاتي السابقة', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue[900],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: AppDrawer(userName: userName, userPhone: userPhone),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('معرف الرحلة: TRP-001', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue)),
                  const Divider(),
                  Text('👤 اسم الراكب: $userName'),
                  const SizedBox(height: 5),
                  Text('📱 الهاتف: $userPhone'),
                  const SizedBox(height: 5),
                  const Text('🎫 الفئة: VIP (رجال أعمال)'),
                  const SizedBox(height: 5),
                  const Text('💰 السعر الإجمالي: 100,000 ل.س'),
                  const SizedBox(height: 5),
                  const Text('💳 حالة الدفع: الدفع عند الصعود', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}