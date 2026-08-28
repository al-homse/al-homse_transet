import 'package:flutter/material.dart';

class ManualBookingScreen extends StatefulWidget {
  const ManualBookingScreen({Key? key}) : super(key: key);

  @override
  State<ManualBookingScreen> createState() => _ManualBookingScreenState();
}

class _ManualBookingScreenState extends State<ManualBookingScreen> {
  // مفتاح النموذج للتحقق من الصحة
  final _formKey = GlobalKey<FormState>();

  // المتحكمات لحقول النص
  final TextEditingController _passengerNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  // القيمة الافتراضية لحالة الدفع
  String _selectedPaymentStatus = 'مدفوع';
  
  // خيارات حالات الدفع المتاحة
  final List<String> _paymentOptions = [
    'مدفوع',
    'الدفع عند الصعود',
    'قيد المعالجة',
  ];

  @override
  void dispose() {
    _passengerNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _submitBooking() {
    if (_formKey.currentState!.validate()) {
      // جمع البيانات المدخلة
      final passengerName = _passengerNameController.text;
      final phone = _phoneController.text;
      final paymentStatus = _selectedPaymentStatus;

      // هنا يمكنك إضافة كود الحفظ (إرسالها لـ Google Sheets أو قاعدة البيانات)
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم تسجيل حجز الراكب $passengerName بنجاح ($paymentStatus)'),
          backgroundColor: Colors.green,
        ),
      );

      // تفريغ الحقول بعد الحفظ الناجح
      _formKey.currentState!.reset();
      _passengerNameController.clear();
      _phoneController.clear();
      setState(() {
        _selectedPaymentStatus = 'مدفوع';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إضافة حجز يدوي', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue[900],
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // اسم الراكب
              TextFormField(
                controller: _passengerNameController,
                decoration: const InputDecoration(
                  labelText: 'اسم الراكب الثلاثي',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال اسم الراكب';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // رقم الهاتف
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'رقم الهاتف',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال رقم الهاتف';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // اختيار حالة الدفع (مدفوع / الدفع عند الصعود)
              DropdownButtonFormField<String>(
                value: _selectedPaymentStatus,
                decoration: const InputDecoration(
                  labelText: 'حالة الدفع',
                  prefixIcon: Icon(Icons.payment),
                  border: OutlineInputBorder(),
                ),
                items: _paymentOptions.map((String status) {
                  return DropdownMenuItem<String>(
                    value: status,
                    child: Text(status),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedPaymentStatus = newValue!;
                  });
                },
              ),
              const SizedBox(height: 30),

              // زر حفظ الحجز
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[800],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: _submitBooking,
                child: const Text(
                  'حفظ الحجز اليدوي',
                  style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}