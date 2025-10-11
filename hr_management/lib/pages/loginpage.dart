import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hr_management/employee/employee_profile.dart';
import 'package:hr_management/pages/accountant_dash.dart';
import 'package:hr_management/pages/adminpage.dart';
import 'package:hr_management/pages/department_page.dart';
import 'package:hr_management/pages/dept_head_dashboard.dart';
import 'package:hr_management/pages/registrationpage.dart';
import 'package:hr_management/service/authservice.dart';
import 'package:hr_management/service/employee_service.dart';

class LoginPage extends StatelessWidget {
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();

  // Note: storage is declared but not used in the provided methods
  final storage = new FlutterSecureStorage();
  AuthService authService = AuthService();
  EmployeeService employeeService = EmployeeService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16.00),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: email,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
            ),

            SizedBox(height: 20.0),

            TextField(
              controller: password,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.password),
              ),
              obscureText: true,
            ),

            SizedBox(height: 20.0),

            ElevatedButton(
              onPressed: () {
                loginUser(context);
              },
              child: Text(
                "Login",
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.w800,
                  color: Colors.white, // Changed to white for better contrast
                ),
              ),

              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                // Removed deprecated 'foregroundColor: Colors.grey,' property
              ),
            ),

            SizedBox(height: 20.0),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/registration'
                );
              },
              child: Text(
                'Registration',
                style: TextStyle(
                  color: Colors.purple,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> loginUser(BuildContext context) async {
    try {
      final response = await authService.login(email.text, password.text);

      print(response);

      final role = await authService.getUserRole();
      print(role);

      if (role == 'ADMIN') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AdminPage()),
        );
      } else if (role == 'ACCOUNTANT') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AccountantDash()),
        );
      } else if (role == 'DEPARTMENT_HEAD') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => DeptHeadDashboard()),
        );
      } else if (role == 'EMPLOYEE') {
        // profile is now correctly of type Employee?
        final profile = await employeeService.getEmployeeProfile();

        if (profile != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              // No type error here, as profile is Employee
              builder: (context) => EmployeeDashboard(profile: profile),
            ),
          );
        }
      } else {
        print('Invalid role');
      }
    } catch (e) {
      print('Error logging in: $e');
    }
  }
}
