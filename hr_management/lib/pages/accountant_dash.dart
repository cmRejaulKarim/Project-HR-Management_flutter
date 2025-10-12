import 'package:flutter/material.dart';
import 'package:hr_management/entity/employee.dart';
import 'package:hr_management/pages/sidebar.dart';
import 'package:hr_management/service/authservice.dart';

class AccountantDash extends StatelessWidget {
  final String role;
  final Employee profile;
  const AccountantDash({super.key, required this.role, required this.profile});

  @override
  Widget build(BuildContext context) {
    final _authService = AuthService();
    return Scaffold(
      appBar: AppBar(title: Text("Dashboard")),
      drawer: Sidebar(role: role,profile: profile, authService: _authService),
      body: Center(child: Text('Welcome, Accountant!')),
    );
  }
}
