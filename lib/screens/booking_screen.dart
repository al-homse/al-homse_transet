import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BookingScreen extends StatefulWidget {
  final String tripId;          // معرف الرحلة الفعلي (مثل TRP-001)
  final String tripTime;
  final String busNumber;
  final String price;           // السعر القادم من قاعدة البيانات
  final int availableSeats;     // المقاعد المتاحة ديناميكياً من الجدول
  final int totalSeats;         // إجمالي المقاعد للرحلة

  const BookingScreen({
    Key? key,
    required this.tripId,
    required this.tripTime,
    required this.busNumber,
    required this.price,
    required this.availableSeats,
    required this.totalSeats,
  }) : super(key: key);

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  int bookingStep = 1;
  String bookingType = 'self';
  int selectedSeatCount = 1; // عدد المقاعد المطلوب حجزها

  final TextEditingController _otherNameController = TextEditingController();
  final TextEditingController _otherPhoneController = TextEditingController();

  // بيانات المستخدم الحقيقية للحساب الشخصي
  final String myName = 'عادل'; 
  final String myPhone = '+963 999 000 111';

  late String selectedCategory;
  late List<Map<String, dynamic>> categoriesList;

  final String driverName = 'أبو أحمد الحمصي';
  final String driverPhone = '+963 933 123 456';

  // رابط النشر الخاص بالسكريبت الخاص بك
  final String scriptUrl = 'https://script.google.com/macros/s/AKfycbycasw7Usvui5S2UO5m3mRDONR9FBFS7qFzB1PHEXw2dd4tIRynDCA6VSqvXLct5Ghs/exec';

  @override
  void initState() {
    super.initState();
    
    // تنظيف وتحويل السعر القادم من قاعدة البيانات
    double basePrice = double.tryParse(widget.price.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 70000;
    double businessPrice = basePrice + 30000;

    // تجهيز قائمة الفئات ديناميكياً
    categoriesList = [
      {
        'key': 'Standard',
        'name': 'Standard (عادي)',
        'price': basePrice,
        'display': 'Standard (عادي) - ${basePrice.toStringAsFixed(0)} ل.س',
      },
      {
        'key': 'VIP',
        'name': 'VIP (رجال أعمال)',
        'price': businessPrice,
        'display': 'VIP (رجال أعمال) - ${businessPrice.toStringAsFixed(0)} ل.س',
      },
    ];

    selectedCategory = categoriesList[0]['key'];
  }

  String reverseNumbers(String input) {
    return input.split('').reversed.join('');
  }

  // دالة إرسال الحجز إلى جوجل شيت
  Future<void> sendBookingToGoogleSheet({
    required String passengerName,
    required String passengerPhone,
    required double finalPriceNumeric,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(scriptUrl),
        body: jsonEncode({
          "action": "addBooking",
          "trip_id": widget.tripId, // تم ربطه بالـ trip_id الفعلي الصحيح
          "phone_number": passengerPhone,
          "passenger_name": passengerName,
          "seat_number": selectedSeatCount.toString(), // عدد المقاعد المحجوزة
          "ticket_class": selectedCategory,
          "ticket_price": '${finalPriceNumeric.toStringAsFixed(0)} ل.س',
          "payment_status": selectedPaymentMethod,
        }),
      );

      if (response.statusCode == 200) {
        print("تم إرسال الحجز بنجاح إلى جدول البيانات!");
      } else {
        print("فشل الإرسال: ${response.statusCode}");
      }
    } catch (e) {
      print("حدث خطأ أثناء الاتصال: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentCategoryData = categoriesList.firstWhere(
      (cat) => cat['key'] == selectedCategory,
      orElse: () => categoriesList[0],
    );
    
    // حساب السعر الإجمالي (سعر الفئة × عدد المقاعد المختارة)
    double unitPrice = currentCategoryData['price'];
    double totalPriceNumeric = unitPrice * selectedSeatCount;
    String finalPriceDisplay = '${totalPriceNumeric.toStringAsFixed(0)} ل.س';

    String passengerName = (bookingType == 'self') ? myName : _otherNameController.text;
    String passengerPhone = (bookingType == 'self') ? myPhone : _otherPhoneController.text;

    // التأكد من أن عدد المقاعد المتاحة لا يقل عن 1 لتفادي أخطاء القائمة المنسدلة
    int maxAvailableSeats = widget.availableSeats > 0 ? widget.availableSeats : 1;
    if (selectedSeatCount > maxAvailableSeats) {
      selectedSeatCount = maxAvailableSeats;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.tripId}: تأكيد حجز', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18)),
        centerTitle: true,
        backgroundColor: Colors.blue[900],
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
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

          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. معلومات الرحلة الأساسية الديناميكية
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.92),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 3))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('موعد الرحلة: ${widget.tripTime}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text('المركبة: ${widget.busNumber}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.blue[800])),
                        ],
                      ),
                      const Divider(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('إجمالي المقاعد: ${reverseNumbers(widget.totalSeats.toString())}', style: const TextStyle(fontSize: 14)),
                          Text('المقاعد المتاحة: ${reverseNumbers(widget.availableSeats.toString())}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.green)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('السائق: $driverName', style: const TextStyle(fontSize: 14)),
                          Text('الهاتف: ${reverseNumbers(driverPhone)}', style: const TextStyle(fontSize: 14, color: Colors.blueGrey, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 2. خطوة اختيار لمن الحجز
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.92),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('لمن يتم حجز هذا المقعد؟', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      RadioListTile<String>(
                        title: Text('الحجز لنفسي ($myName - $myPhone)'),
                        value: 'self',
                        groupValue: bookingType,
                        onChanged: (value) {
                          setState(() {
                            bookingType = value!;
                            bookingStep = 1;
                          });
                        },
                      ),
                      RadioListTile<String>(
                        title: const Text('الحجز لشخص آخر'),
                        value: 'other',
                        groupValue: bookingType,
                        onChanged: (value) {
                          setState(() {
                            bookingType = value!;
                            bookingStep = 2;
                          });
                        },
                      ),
                      if (bookingType == 'other') ...[
                        const SizedBox(height: 10),
                        TextField(
                          controller: _otherNameController,
                          decoration: InputDecoration(
                            labelText: 'اسم الراكب الثلاثي',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            prefixIcon: const Icon(Icons.person),
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _otherPhoneController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            labelText: 'رقم هاتف الراكب',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            prefixIcon: const Icon(Icons.phone),
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 3. القائمة المنسدلة لعدد المقاعد المطلوبة
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.92),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('عدد المقاعد المطلوبة للحجز:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 8),
                      DropdownButton<int>(
                        value: selectedSeatCount,
                        isExpanded: true,
                        items: List.generate(maxAvailableSeats, (index) => index + 1).map((int value) {
                          return DropdownMenuItem<int>(
                            value: value,
                            child: Text('$value مقعد'),
                          );
                        }).toList(),
                        onChanged: (int? newValue) {
                          setState(() {
                            selectedSeatCount = newValue!;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 4. القائمة المنسدلة للفئات والأسعار
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.92),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('اختر فئة الحجز:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      DropdownButton<String>(
                        value: selectedCategory,
                        isExpanded: true,
                        items: categoriesList.map((cat) {
                          return DropdownMenuItem<String>(
                            value: cat['key'],
                            child: Text(cat['display']),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedCategory = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 5),
                      Text('إجمالي السعر ($selectedSeatCount مقعد): $finalPriceDisplay', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.blue[900])),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 5. خيارات الدفع
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.92),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('طريقة الدفع:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      RadioListTile<String>(
                        title: const Text('الدفع عند الصعود للباص'),
                        value: 'الدفع عند الصعود',
                        groupValue: selectedPaymentMethod,
                        onChanged: (value) {
                          setState(() {
                            selectedPaymentMethod = value!;
                          });
                        },
                      ),
                      RadioListTile<String>(
                        title: const Text('الدفع الآن (إلكتروني / تحويل)'),
                        value: 'الدفع الآن',
                        groupValue: selectedPaymentMethod,
                        onChanged: (value) {
                          setState(() {
                            selectedPaymentMethod = value!;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // 6. زر تأكيد الحجز النهائي
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[900],
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    if (bookingType == 'other' && (_otherNameController.text.isEmpty || _otherPhoneController.text.isEmpty)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('الرجاء إدخال اسم ورقم هاتف الراكب أولاً!')),
                      );
                      return;
                    }

                    // مؤشر تحميل أثناء الإرسال
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => const Center(child: CircularProgressIndicator()),
                    );

                    // إرسال البيانات لجوجل شيت مع الـ trip_id الحقيقي
                    await sendBookingToGoogleSheet(
                      passengerName: passengerName,
                      passengerPhone: passengerPhone,
                      finalPriceNumeric: totalPriceNumeric,
                    );

                    // إغلاق مؤشر التحميل
                    Navigator.pop(context);

                    // إظهار نافذة تفاصيل الحجز
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.green),
                            SizedBox(width: 8),
                            Text('تفاصيل الحجز الكاملة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                          ],
                        ),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('👤 اسم الراكب: $passengerName'),
                            const SizedBox(height: 6),
                            Text('📱 رقم الهاتف: ${reverseNumbers(passengerPhone)}'),
                            const SizedBox(height: 6),
                            Text('🚌 الرحلة والـ ID: ${widget.tripId} (${widget.busNumber})'),
                            const SizedBox(height: 6),
                            Text('⏰ الموعد: ${widget.tripTime}'),
                            const SizedBox(height: 6),
                            Text('🎫 الفئة: $selectedCategory (عدد المقاعد: $selectedSeatCount)'),
                            const SizedBox(height: 6),
                            Text('💰 الإجمالي: $finalPriceDisplay'),
                            const SizedBox(height: 6),
                            Text('💳 الدفع: $selectedPaymentMethod'),
                            const SizedBox(height: 6),
                            Text('👨‍✈️ السائق: $driverName (${reverseNumbers(driverPhone)})'),
                            const Divider(height: 20),
                            const Text('تم تسجيل الحجز بنجاح في النظام وخصم المقاعد. رافقتكم السلامة!', style: TextStyle(color: Colors.grey, fontSize: 13)),
                          ],
                        ),
                        actions: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[900]),
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.pop(context);
                            },
                            child: const Text('موافق', style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    );
                  },
                  child: const Text(
                    'تأكيد الحجز النهائي',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String selectedPaymentMethod = 'الدفع عند الصعود';
}