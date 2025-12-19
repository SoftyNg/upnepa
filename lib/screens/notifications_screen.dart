import 'package:flutter/material.dart';
import 'package:upnepa/constants/app_colors.dart';
import 'package:upnepa/services/transactions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final TransactionService _transactionService = TransactionService();
  late Future<List<dynamic>> _notificationsFuture;
  String userEmail = "";
  List<dynamic> _notifications = [];

  @override
  void initState() {
    super.initState();
    _loadUserEmail();
  }

  Future<void> _loadUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString('user_data');
    if (userDataString != null) {
      final userData = jsonDecode(userDataString);
      userEmail = userData['email'] ?? "";
      await _fetchNotifications();
    }
  }

  Future<void> _fetchNotifications() async {
    try {
      final fetched = await _transactionService.fetchNotifications(userEmail);
      setState(() {
        _notifications = fetched;
        _notificationsFuture = Future.value(_notifications);
      });
    } catch (e) {
      setState(() {
        _notificationsFuture = Future.error(e);
      });
    }
  }

  Future<void> _markAsRead(int notificationId) async {
    try {
      await _transactionService.markNotificationAsRead(notificationId);
      // Remove the read notification from the list
      setState(() {
        _notifications.removeWhere((item) => item['id'] == notificationId);
        _notificationsFuture = Future.value(_notifications);
      });
    } catch (e) {
      // Optional: show error message
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to mark as read")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Notifications",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _notificationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                "No notifications yet",
                style: TextStyle(color: Colors.black54),
              ),
            );
          }

          final notifications = snapshot.data!;
          return ListView.separated(
            itemCount: notifications.length,
            separatorBuilder: (_, __) => const SizedBox(height: 6),
            itemBuilder: (context, index) {
              final item = notifications[index];
              return InkWell(
                onTap: () async {
                  // Mark notification as read
                  if (item['id'] != null) {
                    await _markAsRead(item['id']);
                  }
                  // Show the message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(item['message'] ?? "")),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(14),
                  color: item["highlight"] == true
                      ? AppColors.primaryGreen.withOpacity(0.1)
                      : Colors.white,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        backgroundColor: AppColors.primaryGreen.withOpacity(
                          0.1,
                        ),
                        child: const Icon(
                          Icons.bolt,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item["title"] ?? "",
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item["message"] ?? "",
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
