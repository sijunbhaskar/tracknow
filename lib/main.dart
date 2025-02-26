import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pages/login_page.dart';
import 'pages/home_page.dart';
import 'pages/signup_page.dart'; // Added Signup Page

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Widget? initialScreen;

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  // ✅ Check if the user is logged in
  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    String? token =
        prefs.getString('token'); // Store token instead of isLoggedIn

    setState(() {
      initialScreen = (token != null) ? HomePage() : LoginPage();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Passenger Bus Tracking',
      theme: ThemeData(primarySwatch: Colors.blue), // ✅ Default Light Theme
      home: initialScreen ??
          Scaffold(
              body: Center(
                  child:
                      CircularProgressIndicator())), // Show loading indicator
      routes: {
        '/home': (context) => HomePage(),
        '/login': (context) => LoginPage(),
        '/signup': (context) => SignUpPage(),
      },
    );
  }
}
