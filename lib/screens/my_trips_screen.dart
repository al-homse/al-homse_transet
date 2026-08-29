import 'package:flutter/material.dart';
import 'app_drawer.dart';

class MyTripsScreen extends StatelessWidget {
  final String userPhone;

  const MyTripsScreen({Key? key, required this.userPhone}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('رحلاتي', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue[900],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: AppDrawer(userName: 'عادل', userPhone: userPhone), // سيتم ربطه بالداتا الحقيقية لاحقاً
      body: Container(
        color: Colors.grey[100],
        child: ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: 3, // مثال تجريبي مؤقت للرحلات
          itemBuilder: (context, index) {
            return Card(
              margin: const EdgeInsets.only(bottom: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: const Icon(Icons.directions_bus, color: Colors.blue, size: 40),
                title: Text('رحلة حمص - دمشق رقم ${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('الموعد: 08:00 صباحاً\nالباص: مرسيدس حديث'),
                isThreeLine: true,
                trailing: const Chip(
                  label: Text('متاحة', style: TextStyle(color: Colors.white)),
                  backgroundColor: Colors.green,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}