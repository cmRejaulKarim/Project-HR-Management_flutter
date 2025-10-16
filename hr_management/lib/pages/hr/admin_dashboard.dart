import 'package:flutter/material.dart';
import 'package:hr_management/entity/employee.dart';
import 'package:hr_management/pages/sidebar.dart';
import 'package:hr_management/service/auth_service.dart';

class AdminDashboard extends StatelessWidget {
  final String role;
  final Employee profile;

  const AdminDashboard({super.key, required this.role, required this.profile});

  @override
  Widget build(BuildContext context) {
    final _authService = AuthService();

    return Scaffold(
      appBar: AppBar(title: Text("Admin Dashboard")),
      drawer: Sidebar(role: role, profile: profile, authService: _authService),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2, // 2 columns
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildDashboardCard(
              icon: Icons.people,
              title: 'All Employees',
              value: '150', // Replace with dynamic value
              onTap: () {
                // Navigate to employee list page
              },
            ),
            _buildDashboardCard(
              icon: Icons.hourglass_empty,
              title: 'Pending Leave Requests',
              value: '5', // Replace with dynamic value
              onTap: () {
                // Navigate to pending leave requests page
              },
            ),
            _buildDashboardCard(
              icon: Icons.check_circle,
              title: 'Approved Leaves',
              value: '20', // Replace with dynamic value
              onTap: () {
                // Navigate to approved leaves page
              },
            ),
            _buildDashboardCard(
              icon: Icons.attach_money,
              title: 'Monthly Salary Report',
              value: 'View',
              onTap: () {
                // Navigate to salary report page
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard({
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: Colors.blue),
              const SizedBox(height: 16),
              Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}
