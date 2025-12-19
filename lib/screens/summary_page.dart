import 'package:flutter/material.dart';

class SummaryPage extends StatelessWidget {
  final String token;
  final dynamic transaction; // can be Map or String
  final String units;
  final String amount;
  final String meterNumber;
  final String discoName;
  final String meterType;
  final String customerName;

  const SummaryPage({
    super.key,
    required this.token,
    required this.transaction,
    required this.units,
    required this.amount,
    required this.meterNumber,
    required this.discoName,
    required this.meterType,
    required this.customerName,
  });

  @override
  Widget build(BuildContext context) {
    // ✅ Safely extract transaction fields
    String transactionId = "N/A";
    String status = "N/A";
    String date = "N/A";

    if (transaction is Map) {
      // Handle any type of map safely
      final tx = transaction.cast<String, dynamic>();
      transactionId = tx["transactionId"]?.toString() ?? "N/A";
      status = tx["status"]?.toString() ?? "N/A";
      date = tx["date"]?.toString() ?? "N/A";
    } else if (transaction is String && transaction.isNotEmpty) {
      transactionId = transaction;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F9),
      appBar: AppBar(
        title: const Text("Transaction Summary"),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: ListView(
              children: [
                const Text(
                  "Electricity Purchase Successful 🎉",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 20),
                _buildRow("Customer Name", customerName),
                _buildRow("Meter Number", meterNumber),
                _buildRow("Meter Type", meterType),
                _buildRow("Disco", discoName),
                _buildRow("Amount", "₦$amount"),
                _buildRow("Units", units.isNotEmpty ? units : "N/A"),
                _buildRow("Token", token.isNotEmpty ? token : "N/A"),
                const Divider(height: 32),
                const Text(
                  "Transaction Details",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                _buildRow("Transaction ID", transactionId),
                _buildRow("Status", status),
                _buildRow("Date", date),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () {
            // ✅ Pop back to dashboard (first route)
            Navigator.popUntil(context, (route) => route.isFirst);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            "Done",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
