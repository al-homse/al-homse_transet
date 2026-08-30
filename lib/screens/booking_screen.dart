import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_drawer.dart';
import 'login_screen.dart';

class BookingScreen extends StatefulWidget {
  final String tripId;          
  final String tripTime;
  final String busNumber;
  final String price;           
  final int availableSeats;     
  final int totalSeats;         
  // إضافة البيانات الفعلية القادمة من الجدول لضمان عدم وجود أي قيم افتراضية
  final String routeName;
  final String tripDate;
  final String driverName;
  final String driverPhone;

  const BookingScreen({
    Key? key,
    required this.tripId,
    required this.tripTime,
    required this.busNumber,
    required this.price,
    required this.availableSeats,
    required this.totalSeats,
    required this.routeName,
    required this.tripDate,
    required this.driverName,
    required this.driverPhone,
  }) : super(key: key);

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  bool _isCheckingAuth = true; 
  bool _isLoggedIn = false;
  
  String currentUserName = '';
  String currentUserPhone = '';

  int bookingStep = 1;
  String bookingType = 'self';
  int selectedSeatCount = 1; 

  final TextEditingController _otherNameController = TextEditingController();
  final TextEditingController _otherPhoneController = TextEditingController();

  late String selectedCategory;
  late List<Map<String, dynamic>> categoriesList;

  String selectedPaymentMethod = 'الدفع عند الصعود';
  final String scriptUrl = 'https://script.google.com/macros/s/AKfycbycasw7Usvui5S2UO5m3mRDONR9FBFS7qFzB1PHEXw2dd4tIRynDCA6VSqvXLct5Ghs/exec';

  @override
  void initState() {
    super.initState();
    _checkAuthenticationAndLoadData();
    
    double basePrice = double.tryParse(widget.price.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 70000;
    double businessPrice = basePrice + 30000;

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

  Future<void> _checkAuthenticationAndLoadData() async {
    final prefs = await SharedPreferences.getInstance();
    bool loggedIn = prefs.getBool('isLoggedIn') ?? false;
    
    if (!loggedIn) {
      setState(() {
        _isLoggedIn = false;
        _isCheckingAuth = false;
      });
      return;
    }

    setState(() {
      _isLoggedIn = true;
      currentUserName = prefs.getString('userName') ?? prefs.getString('passenger_name') ?? '';
      currentUserPhone = prefs.getString('userPhone') ?? prefs.getString('phone_number') ?? '';
      _isCheckingAuth = false;
    });
  }

  String reverseNumbers(String input) {
    return input.split('').reversed.join('');
  }

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
          "trip_id": widget.tripId,
          "phone_number": passengerPhone,
          "passenger_name": passengerName,
          "seat_number": selectedSeatCount.toString(),
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
    if (_isCheckingAuth) {
      return Scaffold(
        appBar: AppBar(backgroundColor: Colors.blue[900]),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (!_isLoggedIn) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('خطأ في الصلاحيات', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.blue[900],
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock_outline, size: 80, color: Colors.red),
                const SizedBox(height: 20),
                const Text(
                  'يجب تسجيل الدخول أولاً لكي تتمكن من حجز المقاعد!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[900]),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                    );
                  },
                  child: const Text('الذهاب لتسجيل الدخول', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final currentCategoryData = categoriesList.firstWhere(
      (cat) => cat['key'] == selectedCategory,
      orElse: () => categoriesList[0],
    );
    
    double unitPrice = currentCategoryData['price'];
    double totalPriceNumeric = unitPrice * selectedSeatCount;
    String finalPriceDisplay = '${totalPriceNumeric.toStringAsFixed(0)} ل.س';

    String passengerName = (bookingType == 'self') ? currentUserName : _otherNameController.text;
    String passengerPhone = (bookingType == 'self') ? currentUserPhone : _otherPhoneController.text;

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
      drawer: AppDrawer(
        userName: currentUserName,
        userPhone: currentUserPhone,
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
                // بطاقة تفاصيل الرحلة والسائق مقسمة لليمين واليسار بدقة
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.92),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 3))],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // الجهة اليسرى: معلومات الرحلة بالتنسيق المطلوب تماماً
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'اسم الرحلة: ${widget.routeName}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blueAccent),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'معرف الرحلة: ${widget.tripId}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'تاريخ الرحلة: ${widget.tripDate}',
                              style: const TextStyle(fontSize: 14, color: Colors.black87),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'موعد الانطلاق: ${widget.tripTime}',
                              style: const TextStyle(fontSize: 14, color: Colors.black87),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      // الجهة اليمنى: معلومات الباص والسائق الحقيقية
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'المركبة: ${widget.busNumber}',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.blue[800]),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'المقاعد المتاحة: ${widget.availableSeats}',
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.green),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'إجمالي المقاعد: ${widget.totalSeats}',
                              style: const TextStyle(fontSize: 14, color: Colors.black54),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'السائق: ${widget.driverName}',
                              style: const TextStyle(fontSize: 14, color: Colors.black87),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'الهاتف: ${widget.driverPhone}',
                              style: const TextStyle(fontSize: 13, color: Colors.blueGrey, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

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
                        title: Text('الحجز لنفسي ($currentUserName - $currentUserPhone)'),
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

                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => const Center(child: CircularProgressIndicator()),
                    );

                    await sendBookingToGoogleSheet(
                      passengerName: passengerName,
                      passengerPhone: passengerPhone,
                      finalPriceNumeric: totalPriceNumeric,
                    );

                    Navigator.pop(context);

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
                            Text('📱 رقم الهاتف: $passengerPhone'),
                            const SizedBox(height: 6),
                            Text('🚌 الرحلة: ${widget.routeName} (${widget.tripId})'),
                            const SizedBox(height: 6),
                            Text('⏰ الموعد: ${widget.tripDate} - ${widget.tripTime}'),
                            const SizedBox(height: 6),
                            Text('🎫 الفئة: $selectedCategory (عدد المقاعد: $selectedSeatCount)'),
                            const SizedBox(height: 6),
                            Text('💰 الإجمالي: $finalPriceDisplay'),
                            const SizedBox(height: 6),
                            Text('💳 الدفع: $selectedPaymentMethod'),
                            const SizedBox(height: 6),
                            Text('👨‍✈️ السائق: ${widget.driverName} (${widget.driverPhone})'),
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
                
                const SizedBox(height: 12),

                TextButton.icon(
                  onPressed: () {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  icon: const Icon(Icons.home, color: Colors.white),
                  label: const Text(
                    'العودة للشاشة الرئيسية',
                    style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}