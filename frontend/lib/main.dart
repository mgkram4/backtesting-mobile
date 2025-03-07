import 'package:flutter/material.dart';

import 'auth/login.dart';
import 'auth/register.dart';
import 'screens/charts.dart';
import 'screens/dashboard.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stock Backtesting App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/login',
      routes: {
        '/': (context) => const DashboardScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/charts': (context) => const ChartsScreen(),
        // '/fetch_prices': (context) => const FetchPricesScreen(),
        // '/settings': (context) => const SettingsScreen(),
        // '/watchlist': (context) => const WatchListScreen(),
      },
    );
  }
}
