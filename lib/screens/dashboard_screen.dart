import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:upnepa/constants/app_colors.dart';
import 'package:upnepa/screens/fund_wallet_screen.dart';
import 'package:upnepa/screens/buy_power_screen.dart';
import 'package:upnepa/screens/profile_screen.dart';
import 'package:upnepa/services/transactions.dart';
import 'package:intl/intl.dart';
import 'package:upnepa/screens/transaction_history.dart';
import 'package:upnepa/screens/notifications_screen.dart'; // ✅ added import

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _showBalance = true;
  int _selectedIndex = 0;

  String firstName = "";
  String lastName = "";
  String email = "";
  int userId = 0;
  double walletBalance = 0.0;
  bool isLoading = true;
  List<dynamic> transactions = [];
  List<dynamic> notifications = []; // ✅ Added notifications list
  final TransactionService _transactionService = TransactionService();

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
        setState(() {
          firstName = userData['first_name'] ?? "";
          lastName = userData['last_name'] ?? "";
          email = userData['email'] ?? "";
          userId = int.tryParse(userData['id']?.toString() ?? "0") ?? 0;
        });

        if (userId > 0 && email.isNotEmpty) {
          await Future.wait([
            _getWalletBalance(),
            _getTransactions(),
            _fetchNotifications(), // ✅ Fetch notifications
          ]);
        }
      }
    } catch (e) {
      // handle error if needed
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _getWalletBalance() async {
    try {
      if (userId > 0) {
        final balance = await _transactionService.getWalletBalance(userId);
        setState(() => walletBalance = balance);
      }
    } catch (e) {
      // handle error if needed
    }
  }

  Future<void> _getTransactions() async {
    try {
      final txns = await _transactionService.getTransactions(email);
      setState(() => transactions = txns);
    } catch (e) {
      // handle error if needed
    }
  }

  // ✅ Fetch notifications
  Future<void> _fetchNotifications() async {
    try {
      final fetched = await _transactionService.fetchNotifications(email);
      setState(() => notifications = fetched);
    } catch (e) {
      // handle error if needed
    }
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _dashboardBody(),
          const BuyPowerScreen(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: AppColors.primaryGreen,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.flash_on), label: 'Buy'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _dashboardBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getGreeting(),
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    isLoading
                        ? const Text(
                            'Loading...',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : Text(
                            "$firstName $lastName",
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ],
                ),
              ),
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.notifications_none_outlined,
                      color: Colors.black,
                    ),
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NotificationsScreen(),
                        ),
                      );
                      _fetchNotifications(); // Refresh after returning
                    },
                  ),
                  if (notifications.isNotEmpty)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Center(
                          child: Text(
                            notifications.length.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          _walletCard(),
          const SizedBox(height: 16),
          _spentAndUnits(),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent transactions',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TransactionHistoryScreen(),
                    ),
                  );
                },
                child: const Text(
                  'See all',
                  style: TextStyle(
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _transactionsList(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _walletCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Wallet balance', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _showBalance
                    ? '₦${walletBalance.toStringAsFixed(0)}'
                    : '••••••',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: Icon(
                  _showBalance
                      ? Icons.visibility_off_outlined
                      : Icons.visibility,
                  color: Colors.grey,
                ),
                onPressed: () => setState(() => _showBalance = !_showBalance),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FundWalletScreen(
                          paymentUrl: "https://paystack.shop/pay/0va83vev7e",
                        ),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.account_balance_wallet,
                    color: Color(0xFF013D32),
                  ),
                  label: const Text(
                    'Fund wallet',
                    style: TextStyle(
                      color: Color(0xFF013D32),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF1F2F6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _onItemTapped(1),
                  icon: const Icon(Icons.flash_on, color: Colors.white),
                  label: const Text(
                    'Buy electricity',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _spentAndUnits() {
    return Row(
      children: [
        Expanded(
          child: FutureBuilder<Map<String, dynamic>>(
            future: _transactionService.getTotalSpent(email),
            builder: (context, snapshot) {
              double totalSpentAmount = 0.0;
              if (snapshot.hasData) {
                totalSpentAmount =
                    double.tryParse(snapshot.data!['total'].toString()) ?? 0.0;
              }
              return _infoCard(
                icon: Icons.money_off,
                iconColor: Colors.red,
                label: 'Spent',
                value: NumberFormat.currency(
                  locale: 'en_NG',
                  symbol: '₦',
                ).format(totalSpentAmount),
              );
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: FutureBuilder<Map<String, dynamic>>(
            future: _transactionService.getTotalUnits(email),
            builder: (context, snapshot) {
              double totalUnitsPurchased = 0.0;

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return const Text(
                  "Error loading units",
                  style: TextStyle(color: Colors.red),
                );
              }

              if (snapshot.hasData) {
                final data = snapshot.data!;
                if (data['status'] == true && data['total'] != null) {
                  totalUnitsPurchased =
                      double.tryParse(data['total'].toString()) ?? 0.0;
                }
              }

              return _infoCard(
                icon: Icons.bolt,
                iconColor: Colors.green,
                label: 'Units',
                value: '${totalUnitsPurchased.toStringAsFixed(1)}Kwh',
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _infoCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor),
          const SizedBox(height: 8),
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _transactionsList() {
    if (transactions.isEmpty) {
      return Column(
        children: [
          const SizedBox(height: 40),
          Center(
            child: Column(
              children: [
                Image.asset(
                  'assets/images/no_transactions.png',
                  width: 60,
                  height: 60,
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
                  "Once you start paying your electricity bills,\nyour recent activity will show up here",
                  style: TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      );
    }

    return Column(
      children: transactions.map((txn) {
        if (txn == null) return const SizedBox.shrink();

        String createdAt = txn['created_at'] ?? "";
        String formattedDate = "";
        if (createdAt.isNotEmpty) {
          try {
            DateTime parsedDate = DateTime.parse(createdAt);
            formattedDate = DateFormat('dd MMM yyyy').format(parsedDate);
          } catch (e) {
            formattedDate = createdAt;
          }
        }

        return _transactionTile(
          txn['disco_name'] ?? "Abuja",
          txn['meter_number'] ?? "",
          "",
          txn['token'] ?? "",
          "₦${txn['total_amount'] ?? 0}",
          formattedDate,
        );
      }).toList(),
    );
  }

  Widget _transactionTile(
    String company,
    String meter,
    String location,
    String ref,
    String amount,
    String date,
  ) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.white,
          backgroundImage: AssetImage(
            'assets/images/${company.toLowerCase()}.png',
          ),
        ),
        title: Text('$meter • $location'),
        subtitle: Text(ref),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(amount, style: const TextStyle(color: Colors.green)),
            Text(date, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
