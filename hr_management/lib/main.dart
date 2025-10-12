import 'package:flutter/material.dart';
import 'package:hr_management/pages/loginpage.dart';
import 'package:hr_management/pages/department_page.dart';
import 'package:hr_management/pages/registrationpage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HR Management',
      debugShowCheckedModeBanner: false,

      // Initial screen
      initialRoute: '/login',

      // Named routes
      routes: {
        '/login': (context) => LoginPage(),
        '/registration': (context) => Registration(),
        '/departments': (context) => DepartmentPage(),
      },
    );
  }
}
