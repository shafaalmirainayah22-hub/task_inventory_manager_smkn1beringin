import 'package:flutter/material.dart';
import 'models/item_model.dart';
import 'screen/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await UserStore.loadUsers();

  runApp(const TaskInventoryApp());
}

class TaskInventoryApp extends StatelessWidget {
  const TaskInventoryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Task & Inventory Manager',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Arial',
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xffe937bc),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xffe937bc),
          foregroundColor: Color(0xff25243a),
          elevation: 0,
        ),
      ),
      home: const LoginScreen(),
    );
  }
}