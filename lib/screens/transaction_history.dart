import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:upnepa/constants/app_colors.dart';
import 'package:upnepa/services/transactions.dart';
import 'package:intl/intl.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  final TransactionService _transactionService = TransactionService();
  List<dynamic> transactions = [];
  String email = "";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _getUserDetails();
  }

  Future<void> _getUserDetails() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString('user_data');

      if (userDataString != null) {
        final userData = jsonDecode(userDataString);
        email = userData['email'] ?? "";

        if (email.isNotEmpty) {
          await _getTransactions();
        }
      }
    } catch (e) {
      // handle error if necessary
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _getTransactions() async {
    try {
      final txns = await _transactionService.getTransactions(email);
      setState(() => transactions = txns);
    } catch (e) {
      // handle error if necessary
    }
  }

  String _formatDate(String createdAt) {
    if (createdAt.isEmpty) return "";
    try {
      final parsed = DateTime.parse(createdAt);
      return DateFormat('dd MMM yyyy').format(parsed);
    } catch (e) {
      return createdAt;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        title: const Text(
          "Transaction History",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.calendar_today_outlined,
              color: Colors.black,
            ),
            onPressed: () {
              // TODO: Add date filter logic
            },
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : transactions.isEmpty
          ? _emptyState()
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: transactions.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final txn = transactions[index];
                return _transactionCard(
                  company: txn['disco_name'] ?? "Unknown",
                  meter: txn['meter_number'] ?? "",
                  ref: txn['token'] ?? "",
                  amount: "₦${txn['total_amount'] ?? 0}",
                  date: _formatDate(txn['created_at'] ?? ""),
                );
              },
            ),
    );
  }

  Widget _transactionCard({
    required String company,
    required String meter,
    required String ref,
    required String amount,
    required String date,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: Colors.white,
            backgroundImage: AssetImage(
              'assets/images/${company.toLowerCase()}.png',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "$meter • $company",
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  ref,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryGreen,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                date,
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/no_transactions.png',
            width: 70,
            height: 70,
          ),
          const SizedBox(height: 16),
          const Text(
            "No transactions yet",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Once you start paying your electricity bills,\nyour history will appear here",
            style: TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
