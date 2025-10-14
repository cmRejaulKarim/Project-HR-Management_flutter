import 'package:flutter/material.dart';
import 'package:hr_management/pages/advance_request_list_page.dart';
import 'package:hr_management/pages/holiday_add_screen.dart';
import 'package:hr_management/pages/holiday_view_only.dart';
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
        '/advance': (context) => AdvanceRequestListPage(),
        '/addHoliday': (context) => HolidayScreen(),
        '/viewHoliday': (context) => HolidayViewOnly(),
        '/dLeave': (context) => DepartmentLeaveViewPage(),


      },
    );
  }
}
