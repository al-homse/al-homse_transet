import 'package:flutter/material.dart';

class ViewBookingsScreen extends StatelessWidget {
  const ViewBookingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('سجل الحجوزات والركاب', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue[900],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 3, // مثال تجريبي لعدد الحجوزات
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blue[100],
                child: Text('${index + 1}'),
              ),
              title: Text('اسم الراكب التجريبي ${index + 1}'),
              subtitle: const Text('خط: حمص - دمشق | المقعد: رقم 5\nالهاتف: 0912345678'),
              isThreeLine: true,
              trailing: const Icon(Icons.check_circle, color: Colors.green),
            ),
          );
        },
      ),
    );
  }
}