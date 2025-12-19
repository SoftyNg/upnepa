// lib/config.dart
class Config {
  // VT Pass configuration
  static const String vtPassPublicKey = 'YOUR_VT_PASS_PUBLIC_KEY';
  static const String vtPassSecretKey = 'YOUR_VT_PASS_SECRET_KEY';
  static const String vtPassApiKey = 'YOUR_VT_PASS_API_KEY';
  static const String vtPassBaseUrl = 'https://api.vtpass.com';

  // Paystack configuration
  static const String paystackPublicKey = 'YOUR_PAYSTACK_PUBLIC_KEY';
  static const String paystackBackendUrl =
      'https://realestatearena.com.ng/lightman';

  /// Optional: validate at startup (debug only)
  static void init() {
    assert(vtPassPublicKey.isNotEmpty, 'VT Pass Public Key missing');
    assert(vtPassSecretKey.isNotEmpty, 'VT Pass Secret Key missing');
    assert(vtPassApiKey.isNotEmpty, 'VT Pass API Key missing');
    assert(vtPassBaseUrl.isNotEmpty, 'VT Pass Base URL missing');
    assert(paystackPublicKey.isNotEmpty, 'Paystack Public Key missing');
  }
}
