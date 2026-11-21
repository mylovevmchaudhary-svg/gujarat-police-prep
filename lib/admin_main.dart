import 'package:flutter/material.dart';
import 'admin/admin_dashboard_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const GujaratPoliceAdminApp());
}

class GujaratPoliceAdminApp extends StatelessWidget {
  const GujaratPoliceAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gujarat Police Master Admin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: const Color(0xFF0D253F),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0D253F),
          primary: const Color(0xFF0D253F),
          secondary: const Color(0xFFFFC107),
        ),
        scaffoldBackgroundColor: const Color(0xFFF0F4F8),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0D253F),
          foregroundColor: Colors.white,
          elevation: 2,
        ),
      ),
      home: const AdminDashboardScreen(),
    );
  }
}
