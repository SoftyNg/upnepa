import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'paystack_payment_screen.dart';
import 'summary_page.dart';

class ReviewOrderScreen extends StatefulWidget {
  final String discoName;
  final String discoCode;
  final String meterNumber;
  final String meterType;
  final String customerName;
  final String meterName;
  final String address;
  final String customerAddress;
  final double electricityAmount; // ✅ this is the units amount
  final double serviceCharge;
  final String phone;

  const ReviewOrderScreen({
    super.key,
    required this.discoName,
    required this.discoCode,
    required this.meterNumber,
    required this.meterType,
    required this.customerName,
    required this.customerAddress,
    required this.electricityAmount,
    required this.serviceCharge,
    required this.meterName,
    required this.address,
    required this.phone,
  });

  @override
  State<ReviewOrderScreen> createState() => _ReviewOrderScreenState();
}

class _ReviewOrderScreenState extends State<ReviewOrderScreen> {
  late TextEditingController phoneController;
  String userEmail = "";

  @override
  void initState() {
    super.initState();
    phoneController = TextEditingController(text: widget.phone);
    _getUserDetails();
  }

  Future<void> _getUserDetails() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString('user_data');

      if (userDataString != null) {
        final userData = jsonDecode(userDataString);

        setState(() {
          userEmail = userData['email']?.toString() ?? '';

          // Update phone if it's empty or if we have a better value from stored data
          if (phoneController.text.isEmpty) {
            var phoneValue = userData['phone'];
            if (phoneValue != null) {
              phoneController.text = phoneValue.toString().replaceAll('.0', '');
            }
          }
        });
      }
    } catch (e) {
      print('Error fetching user details: $e');
    }
  }

  @override
  void dispose() {
    phoneController.dispose();
    super.dispose();
  }

  Future<void> _onPayPressed() async {
    if (userEmail.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No logged in user found"),
        ),
      );
      return;
    }

    final total = widget.electricityAmount + widget.serviceCharge; // ✅ total
    final enteredPhone = phoneController.text.trim();

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentPaystackScreen(
          meterNumber: widget.meterNumber,
          meterType: widget.meterType,
          disco: widget.discoCode,
          amount: total, // ✅ Paystack charge
          unitsAmount: widget.electricityAmount, // ✅ send to PHP for VTpass
          phone: enteredPhone,
          email: userEmail,
        ),
      ),
    );

    if (result != null && result is Map<String, dynamic>) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => SummaryPage(
            token: result["token"] ?? "N/A",
            transaction: result["transaction"] ?? {},
            units: result["units"]?.toString() ?? "N/A",
            amount: total.toStringAsFixed(2),
            meterNumber: widget.meterNumber,
            discoName: widget.discoName,
            meterType: widget.meterType,
            customerName: widget.customerName,
          ),
        ),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.electricityAmount + widget.serviceCharge;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F9),
      appBar: AppBar(
        title: const Text("Review your order"),
        backgroundColor: Colors.green,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // 💰 Total Amount Display
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  children: [
                    const Text(
                      "Total Payable",
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "₦${total.toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),

              // 📋 Order Details Card
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildRow("Disco", widget.discoName),
                      _buildRow("Meter Number", widget.meterNumber),
                      _buildRow("Meter Type", widget.meterType),
                      _buildRow("Customer Name", widget.customerName),
                      _buildRow("Address", widget.customerAddress),

                      // 📱 Editable Phone Field
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: TextFormField(
                          controller: phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            labelText: "Phone",
                            prefixIcon: const Icon(Icons.phone, size: 20),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),

                      const Divider(),
                      _buildRow(
                        "Electricity Amount",
                        "₦${widget.electricityAmount.toStringAsFixed(2)}",
                      ),
                      _buildRow(
                        "Service Charge",
                        "₦${widget.serviceCharge.toStringAsFixed(2)}",
                      ),
                      const Divider(),
                      _buildRow(
                        "Total",
                        "₦${total.toStringAsFixed(2)}",
                        isBold: true,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // 🟢 Pay Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: _onPayPressed,
                  child: const Text(
                    "Choose payment method",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
