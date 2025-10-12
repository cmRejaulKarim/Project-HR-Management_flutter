import 'package:flutter/material.dart';
import 'package:hr_management/pages/sidebar.dart';
import 'package:hr_management/service/authservice.dart';

class AdminDashboard extends StatelessWidget {
  final String role;
  const AdminDashboard({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    final _authService = AuthService();
    return Scaffold(
      appBar: AppBar(title: Text("Dashboard")),
      drawer: Sidebar(role: role, authService: _authService),
      body: Center(child: Text('Welcome, Admin!')),
    );
  }
}
