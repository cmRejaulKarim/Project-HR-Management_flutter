import 'package:flutter/material.dart';
import 'package:hr_management/pages/leave_Request_submit.dart';
import 'package:hr_management/pages/loginpage.dart';
import 'package:hr_management/pages/department_page.dart';
import 'package:hr_management/pages/registrationpage.dart';
import 'package:hr_management/pages/view_leave_request.dart';

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
        //view leave page
        '/dLeave': (context) => DepartmentLeaveViewPage(),


      },
    );
  }
}
