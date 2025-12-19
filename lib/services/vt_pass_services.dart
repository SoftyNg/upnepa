import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart'; // <-- import your Config class

class VtPassService {
  static final String _baseUrl = Config.vtPassBaseUrl;
  static final String _publicKey = Config.vtPassPublicKey;
  static final String _secretKey = Config.vtPassSecretKey;
  static final String _apiKey = Config.vtPassApiKey;

  /// ✅ Headers for VTPass API
  static Map<String, String> _authHeaders() {
    return {
      'Content-Type': 'application/json',
      'api-key': _apiKey,
      'public-key': _publicKey,
      'secret-key': _secretKey,
    };
  }

  /// ✅ Verify meter number
  static Future<Map<String, dynamic>> verifyMeter({
    required String disco,
    required String meterNumber,
    required String meterType,
  }) async {
    final url = Uri.parse('$_baseUrl/merchant-verify');
    final body = jsonEncode({
      'billersCode': meterNumber,
      'serviceID': disco,
      'type': meterType,
    });

    final response = await http.post(url, headers: _authHeaders(), body: body);
    print('✅ VERIFY METER raw response: ${response.body}');

    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      } else {
        return {'status': 'error', 'message': decoded.toString()};
      }
    } catch (_) {
      return {'status': 'error', 'message': response.body};
    }
  }

  /// ✅ Buy electricity
  static Future<Map<String, dynamic>> buyElectricity({
    required String disco,
    required String meterNumber,
    required String meterType,
    required String phone,
    required String amount,
  }) async {
    final url = Uri.parse('$_baseUrl/pay');
    final body = jsonEncode({
      'request_id': DateTime.now().millisecondsSinceEpoch.toString(),
      'serviceID': disco,
      'billersCode': meterNumber,
      'variation_code': meterType,
      'amount': amount,
      'phone': phone,
    });

    final response = await http.post(url, headers: _authHeaders(), body: body);
    print('✅ BUY ELECTRICITY raw response: ${response.body}');

    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      } else {
        return {'status': 'error', 'message': decoded.toString()};
      }
    } catch (_) {
      return {'status': 'error', 'message': response.body};
    }
  }
}
