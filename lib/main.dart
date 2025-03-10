import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/welcome_screen.dart';
import 'screens/home_screen.dart';
import 'providers/auth_provider.dart';
import 'services/database_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // 重新启用这行

  // 初始化数据库连接
  final dbService = DatabaseService();
  await dbService.initialize();
  print('Database initialized'); // 调试输出

  // 初始化 SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  print('SharedPreferences initialized'); // 调试输出

  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthProvider(prefs),
      child: const MyApp(),
    ),
  );
}

// With Flutter, you create user interfaces by combining "widgets"
// You'll learn all about them (and much more) throughout this course!
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Every custom widget must have a build() method
  // It tells Flutter, which widgets make up your custom widget
  // Again: You'll learn all about that throughout the course!
  @override
  Widget build(BuildContext context) {
    // Below, a bunch of built-in widgets are used (provided by Flutter)
    // They will be explained in the next sections
    // In this course, you will, of course, not just use them a lot but
    // also learn about many other widgets!
    return MaterialApp(
      title: 'WarmSage',
      theme: ThemeData(useMaterial3: true, primarySwatch: Colors.blue),
      home: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          print('Auth state: ${auth.isLoggedIn}'); // 调试输出
          return auth.isLoggedIn ? const HomeScreen() : const WelcomeScreen();
          // return HomeScreen();
        },
      ),
    );
  }
}
