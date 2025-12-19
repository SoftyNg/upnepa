import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:upnepa/services/transactions.dart';
import 'package:upnepa/screens/buy_power_screen.dart';
import 'package:upnepa/screens/saved_meters_details.dart'; // ✅ correct import

class SavedMetersScreen extends StatefulWidget {
  const SavedMetersScreen({super.key});

  @override
  State<SavedMetersScreen> createState() => _SavedMetersScreenState();
}

class _SavedMetersScreenState extends State<SavedMetersScreen> {
  final TransactionService _transactionService = TransactionService();
  List<dynamic> meters = [];
  bool isLoading = true;
  String email = "";

  @override
  void initState() {
    super.initState();
    _getUserEmailAndFetchMeters();
  }

  Future<void> _getUserEmailAndFetchMeters() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString('user_data');

      if (userDataString != null) {
        final userData = jsonDecode(userDataString);
        email = userData['email'] ?? "";

        if (email.isNotEmpty) {
          await _fetchMeters();
        }
      }
    } catch (e) {
      debugPrint("Error fetching saved meters: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _fetchMeters() async {
    try {
      final fetchedMeters = await _transactionService.fetchMetersDetails(email);
      setState(() => meters = fetchedMeters);
    } catch (e) {
      debugPrint("Error fetching meters: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F6FA),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Saved meters",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : meters.isEmpty
          ? _emptyState()
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: meters.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final meter = meters[index];
                return _meterCard(
                  name: meter['customer_name'] ?? "Unknown",
                  meterNumber: meter['meter_number'] ?? "",
                  disco: meter['disco_name'] ?? "",
                  meter: meter,
                );
              },
            ),
    );
  }

  Widget _meterCard({
    required String name,
    required String meterNumber,
    required String disco,
    required Map<String, dynamic> meter,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          name,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        subtitle: Text(
          "Meter number: $meterNumber",
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.white,
              child: Text(
                disco.toUpperCase(),
                style: TextStyle(
                  color: Colors.blue[900],
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SavedMeterDetailsScreen(
                customerName: meter['customer_name'] ?? "",
                serviceAddress: meter['service_address'] ?? "",
                meterNumber: meter['meter_number'] ?? "",
                meterType: meter['meter_type'] ?? "",
                displayName: meter['meter_name'] ?? "Meter",
                //userEmail: email, // ✅ added here
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.download, size: 40, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            const Text(
              "No saved meters yet",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Save a meter after your next payment for\nfaster checkouts next time.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00C853),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BuyPowerScreen(),
                    ),
                  );
                },
                child: const Text(
                  "Buy electricity",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
