import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hr_management/pages/employee/employee_profile.dart';
import 'package:hr_management/pages/hr/accountant_dash.dart';
import 'package:hr_management/pages/hr/admin_dashboard.dart';
import 'package:hr_management/pages/department_page.dart';
import 'package:hr_management/pages/dept/dept_head_dashboard.dart';
import 'package:hr_management/pages/registrationpage.dart';
import 'package:hr_management/service/auth_service.dart';
import 'package:hr_management/service/employee_service.dart';

class LoginPage extends StatelessWidget {
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();

  final storage = new FlutterSecureStorage();
  AuthService authService = AuthService();
  EmployeeService employeeService = EmployeeService();

  // Define a deep, rich color for the theme accents
  final Color deepPrimary = Colors.indigo.shade800;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 1. Darker background for "deep color" effect
      backgroundColor: Colors.blueGrey.shade900,
      body: Center(
        // Use SingleChildScrollView to prevent overflow when keyboard is visible
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 450, // Max width for the card on large screens
            ),
            child: Card(
              // 2. Card view with elevation and rounded corners
              color: Colors.white,
              elevation: 10,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // --- Title Section ---
                    Icon(
                      Icons.lock_open,
                      size: 60,
                      color: deepPrimary,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Welcome to HRMS',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: deepPrimary,
                      ),
                    ),
                    const SizedBox(height: 30),

                    // --- Email Input ---
                    TextField(
                      controller: email,
                      // Styled Inputs
                      decoration: InputDecoration(
                        labelText: 'Email',
                        hintText: 'Enter your work email',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(color: deepPrimary, width: 2.0),
                        ),
                        prefixIcon: Icon(Icons.email, color: deepPrimary),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),

                    const SizedBox(height: 20.0),

                    // --- Password Input ---
                    TextField(
                      controller: password,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        hintText: 'Enter your password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(color: deepPrimary, width: 2.0),
                        ),
                        prefixIcon: Icon(Icons.lock, color: deepPrimary),
                      ),
                      obscureText: true,
                    ),

                    const SizedBox(height: 30.0),

                    // --- Login Button ---
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          loginUser(context);
                        },
                        style: ElevatedButton.styleFrom(
                          // Use the deep color for the button background
                          backgroundColor: deepPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 15.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          elevation: 5,
                        ),
                        child: const Text(
                          "Login",
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20.0),

                    // --- Registration Link ---
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/registration');
                      },
                      child: Text(
                        'New user? Register Here',
                        style: TextStyle(
                          color: deepPrimary,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                          decorationColor: deepPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> loginUser(BuildContext context) async {
    try {
      final response = await authService.login(email.text, password.text);

      print(response);
      // profile is now correctly of type Employee?
      final profile = await employeeService.getEmployeeProfile();
      final role = await authService.getUserRole();
      print(role);

      if (role == 'ADMIN') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                AdminDashboard(role: role!, profile: profile!),
          ),
        );
      } else if (role == 'ACCOUNTANT') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                AccountantDash(role: role!, profile: profile!),
          ),
        );
      } else if (role == 'DEPARTMENT_HEAD') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => DeptHeadDashboard(role: role!, profile: profile!),
          ),
        );
      } else if (role == 'EMPLOYEE') {
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
