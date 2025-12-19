import 'package:flutter/material.dart';
import 'package:upnepa/screens/splash_screen.dart';
import 'package:upnepa/constants/app_colors.dart';
import 'config.dart';

// Deep linking imports
import 'package:app_links/app_links.dart';
import 'dart:async';
import 'package:upnepa/screens/update_password_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize config after dotenv loads
  Config.init();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  late final AppLinks _appLinks;
  StreamSubscription<Uri>? _sub;

  @override
  void initState() {
    super.initState();
    _setupDeepLinking();
  }

  void _setupDeepLinking() {
    _appLinks = AppLinks();

    // Handle cold start (app opened via deep link)
    _appLinks.getInitialLink().then((Uri? uri) {
      if (uri != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _navigateIfResetLink(uri);
        });
      }
    });

    // Handle warm start (app already running)
    _sub = _appLinks.uriLinkStream.listen(
      (Uri? uri) {
        _navigateIfResetLink(uri);
      },
      onError: (err) {
        debugPrint("Failed to parse incoming link: $err");
      },
    );
  }

  void _navigateIfResetLink(Uri? uri) {
    if (uri != null && uri.scheme == "upnepa" && uri.host == "reset") {
      final token = uri.queryParameters['token'];
      final email = uri.queryParameters['email'];

      if (token != null && email != null) {
        // Use navigatorKey for safe global navigation
        _navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (_) => UpdatePasswordScreen(email: email, token: token),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey, // ✅ Global navigator key
      title: 'upnepa App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.darkGreen),
        useMaterial3: true,
      ),
      home: const SplashScreen(), // ✅ Normal splash if no deep link
    );
  }
}
