import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hr_management/employee/employee_profile.dart';
import 'package:hr_management/pages/accountant_dash.dart';
import 'package:hr_management/pages/adminpage.dart';
import 'package:hr_management/pages/department_page.dart';
import 'package:hr_management/pages/dept_head_dash.dart';
import 'package:hr_management/pages/registrationpage.dart';
import 'package:hr_management/service/authservice.dart';
import 'package:hr_management/service/employee_service.dart';

class LoginPage extends StatelessWidget {
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();

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
                  color: Colors.black,
                ),
              ),

              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.grey,
              ),
            ),

            SizedBox(height: 20.0),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Registration()),
                );
              },
              child: Text(
                'Registration',
                style: TextStyle(
                  color: Colors.purple,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),SizedBox(height: 20.0),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DepartmentPage()),
                );
              },
              child: Text(
                'Departments',
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
          MaterialPageRoute(builder: (context) => DeptHeadDash()),
        );
      } else if (role == 'EMPLOYEE') {
        final profile = await employeeService.getEmployeeProfile();

        if(profile != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => EmployeeProfile(profile: profile)),
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
