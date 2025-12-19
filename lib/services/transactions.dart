import 'dart:convert';
import 'package:http/http.dart' as http;

class TransactionService {
  final String baseUrl =
      "https://realestatearena.com.ng"; // change to your server URL

  /// Credit a user's wallet
  Future<Map<String, dynamic>> creditWallet({
    required int userId,
    required double amount,
    String type = "credit",
    String description = "Wallet credited",
  }) async {
    final url = Uri.parse("$baseUrl/transactions/credit.php");

    final response = await http.post(
      url,
      body: {
        "user_id": userId.toString(),
        "amount": amount.toString(),
        "type": type,
        "description": description,
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Failed to credit wallet");
    }
  }

  /// Debit a user's wallet
  Future<Map<String, dynamic>> debitWallet({
    required int userId,
    required double amount,
    String type = "debit",
    String description = "Wallet debited",
  }) async {
    final url = Uri.parse("$baseUrl/transactions/debit.php");

    final response = await http.post(
      url,
      body: {
        "user_id": userId.toString(),
        "amount": amount.toString(),
        "type": type,
        "description": description,
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Failed to debit wallet");
    }
  }

  /// Fetch transaction history
  Future<List<dynamic>> getTransactions(String email) async {
    final url = Uri.parse("$baseUrl/history.php?email=$email");

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Failed to fetch transactions");
    }
  }

  /// Fetch wallet balance
  Future<double> getWalletBalance(int userId) async {
    final url = Uri.parse("$baseUrl/get_wallet_balance.php");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode({"user_id": userId}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data["status"] == "success") {
        return double.tryParse(data["balance"].toString()) ?? 0.0;
      } else {
        throw Exception(data["message"] ?? "Failed to get wallet balance");
      }
    } else {
      throw Exception("Failed to fetch wallet balance");
    }
  }

  /// Calculate total amount spent for a user
  Future<Map<String, dynamic>> getTotalSpent(String email) async {
    final url = Uri.parse("$baseUrl/total_spent.php?email=$email");

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return json.decode(response.body); // returns Map
    } else {
      throw Exception("Failed to fetch total spent");
    }
  }

  /// Calculate total units purchased for a user
  Future<Map<String, dynamic>> getTotalUnits(String email) async {
    final url = Uri.parse("$baseUrl/total_units.php?email=$email");

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return json.decode(response.body); // returns Map
    } else {
      throw Exception("Failed to fetch total units");
    }
  }

  /// Fetch saved meters details for a user
  Future<List<dynamic>> fetchMetersDetails(String email) async {
    final url = Uri.parse("$baseUrl/fetch_meters_details.php?email=$email");

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data["meters"] ?? []; // return only the meters list
    } else {
      throw Exception("Failed to fetch meters details");
    }
  }

  /// Delete a saved meter for a user
  Future<Map<String, dynamic>> deleteMeter({
    required String email,
    required String meterNumber,
  }) async {
    final url = Uri.parse("$baseUrl/delete_meter.php");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "email": email,
        "meter_number": meterNumber,
      }),
    );

    if (response.statusCode == 200) {
      return json
          .decode(response.body); // { "status": "success", "message": "..." }
    } else {
      throw Exception("Failed to delete meter");
    }
  }

  /// Save a new meter for a user
  Future<Map<String, dynamic>> saveMeter({
    required String email,
    required String meterNumber,
    required String meterType,
    String? customerName,
  }) async {
    final url = Uri.parse("$baseUrl/save_meter.php");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "email": email,
        "meter_number": meterNumber,
        "meter_type": meterType,
        "customer_name": customerName ?? "",
      }),
    );

    if (response.statusCode == 200) {
      return json
          .decode(response.body); // { "status": "success", "message": "..." }
    } else {
      throw Exception("Failed to save meter");
    }
  }

  /// ✅ Fetch notifications for a user
  Future<List<dynamic>> fetchNotifications(String email) async {
    final url = Uri.parse("$baseUrl/fetch_notifications.php?email=$email");

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data["notifications"] ?? [];
    } else {
      throw Exception("Failed to fetch notifications");
    }
  }

  /// ✅ Mark a notification as read
  Future<Map<String, dynamic>> markNotificationAsRead(
      int notificationId) async {
    final url = Uri.parse("$baseUrl/mark_notification_read.php");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode({"id": notificationId}),
    );

    if (response.statusCode == 200) {
      return json
          .decode(response.body); // { "status": "success", "message": "..." }
    } else {
      throw Exception("Failed to mark notification as read");
    }
  }
}
