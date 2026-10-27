import 'package:flutter/material.dart';
import 'package:frontend_dilaundry/config/app_colors.dart';
import 'package:frontend_dilaundry/config/app_constants.dart';
import 'package:frontend_dilaundry/config/app_session.dart';
import 'package:frontend_dilaundry/pages/auth/login_page.dart';
import 'package:frontend_dilaundry/pages/dashboard_page.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appname,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.light(
          primary: AppColors.primary,
          secondary: Colors.greenAccent[400]!,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0.5,
        ),
        textTheme: GoogleFonts.latoTextTheme(),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: const WidgetStatePropertyAll(AppColors.primary),
            foregroundColor: const WidgetStatePropertyAll(Colors.white),
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
            ),
            padding: const WidgetStatePropertyAll(
              EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            textStyle: const WidgetStatePropertyAll(TextStyle(fontSize: 15)),
          ),
        ),
      ),
      home: const SessionGatePage(),
    );
  }
}

/// Memeriksa sesi tersimpan saat aplikasi dibuka. Bila ada pengguna dan
/// token, langsung masuk ke dasbor. Bila tidak, tampilkan halaman masuk.
class SessionGatePage extends StatefulWidget {
  const SessionGatePage({super.key});

  @override
  State<SessionGatePage> createState() => _SessionGatePageState();
}

class _SessionGatePageState extends State<SessionGatePage> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    final user = await AppSession.getUser();
    final token = await AppSession.getBearerToken();
    if (!mounted) return;
    if (user != null && token != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => DashboardPage(user: user)),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.local_laundry_service, size: 64, color: Colors.green),
            SizedBox(height: 16),
            Text(
              AppConstants.appname,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
            ),
            SizedBox(height: 16),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
