import 'package:flutter/material.dart';

class ManageTripsScreen extends StatelessWidget {
  const ManageTripsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة الرحلات', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue[900],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              // نافذة أو صفحة إضافة رحلة جديدة
            },
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text('إضافة رحلة جديدة', style: TextStyle(fontSize: 16, color: Colors.white)),
          ),
          const SizedBox(height: 20),
          const Text('الرحلات الحالية:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          // مثال لرحلة مدرجة
          Card(
            child: ListTile(
              leading: const Icon(Icons.directions_bus, color: Colors.blue),
              title: const Text('حمص - دمشق'),
              subtitle: const Text('الموعد: 08:00 صباحاً | المقاعد المتاحة: 12'),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {},
              ),
            ),
          ),
        ],
      ),
    );
  }
}