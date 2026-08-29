import 'package:flutter/material.dart';
import 'app_drawer.dart';

class ProfileScreen extends StatelessWidget {
  final String userName;
  final String userPhone;

  const ProfileScreen({Key? key, required this.userName, required this.userPhone}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ملفي الشخصي', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue[900],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: AppDrawer(userName: userName, userPhone: userPhone),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.blue,
                child: Icon(Icons.person, size: 60, color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),
            Text(userName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(userPhone, style: const TextStyle(fontSize: 16, color: Colors.grey)),
            const Divider(height: 40),
            ListTile(
              leading: const Icon(Icons.star, color: Colors.amber),
              title: const Text('الفئة المفضلة'),
              trailing: const Text('VIP', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            ListTile(
              leading: const Icon(Icons.security, color: Colors.blue),
              title: const Text('حالة الحساب'),
              trailing: const Text('نشط ومفعل', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}