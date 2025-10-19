import 'package:flutter/material.dart';
import 'package:hr_management/pages/advance/advance_request_list_page.dart';
import 'package:hr_management/pages/attendance/attendance_by_dept.dart';
import 'package:hr_management/pages/dept/dept_emp.dart';
import 'package:hr_management/pages/employee/all_employees_screen.dart';
import 'package:hr_management/pages/employee/employee_by_department_page.dart';
import 'package:hr_management/pages/holiday/holiday_add_screen.dart';
import 'package:hr_management/pages/holiday/holiday_view_only.dart';
import 'package:hr_management/pages/home_page.dart';
import 'package:hr_management/pages/leave/all_approved_leaves.dart';
import 'package:hr_management/pages/leave/dept_head_leaves.dart';
import 'package:hr_management/pages/loginpage.dart';
import 'package:hr_management/pages/department_page.dart';
import 'package:hr_management/pages/registrationpage.dart';
import 'package:hr_management/pages/leave/view_leave_request.dart';

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
      initialRoute: '/home',

      // Named routes
      routes: {
        '/login': (context) => LoginPage(),
        '/registration': (context) => Registration(),
        '/departments': (context) => DepartmentPage(),
        '/advance': (context) => AdvanceRequestListPage(),
        '/addHoliday': (context) => HolidayScreen(),
        '/viewHoliday': (context) => HolidayViewOnly(),
        '/dLeave': (context) => DepartmentLeaveViewPage(),
        '/dAttend': (context) => AttendanceByDept(),
        '/deptEmp': (context) => DepartmentEmployees(),
        '/deptGroup': (context) => EmployeeByDepartmentPage(),
        '/allEmp': (context) => AllEmployeesScreen(),
        '/home': (context) => HomePage(),
        '/approvedLeaves': (context) => ApprovedLeavesPage(),
        '/deptLeaves': (context) => DeptHeadLeavesPage(),


      },
    );
  }
}
