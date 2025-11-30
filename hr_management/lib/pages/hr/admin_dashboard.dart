import 'package:flutter/material.dart';
import 'package:hr_management/entity/employee.dart';
import 'package:hr_management/pages/sidebar.dart';
import 'package:hr_management/service/auth_service.dart';

class AdminDashboard extends StatelessWidget {
  final String role;
  final Employee profile;

  const AdminDashboard({super.key, required this.role, required this.profile});

  // Helper to determine the appropriate greeting and emoji based on the current time.
  (String greeting, String emoji) _getGreeting() {
    final now = DateTime.now();
    final hour = now.hour;

    if (hour >= 5 && hour < 12) {
      return ('Good Morning', '☀️');
    } else if (hour >= 12 && hour < 17) {
      return ('Good Afternoon', '🌤️');
    } else if (hour >= 17 && hour < 21) {
      return ('Good Evening', '🌙');
    } else {
      return ('Good Night', '😴');
    }
  }

  // Widget to build the stylish greeting card.
  Widget _buildGreetingCard(BuildContext context) {
    final (greeting, emoji) = _getGreeting();
    // Using a cohesive color scheme, similar to the light green in the image
    final Color accentColor = Colors.green.shade700;
    final Color lightAccent = Colors.green.shade100;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 24.0), // Margin below the card
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Placeholder for the HRMS logo/icon
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: lightAccent,
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Text(
                'HRMS',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: accentColor,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    // Display the greeting, profile name, and emoji
                    '$greeting, ${profile.name} $emoji',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Have a productive day ahead!',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final _authService = AuthService();
    final Color primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Admin Dashboard",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      drawer: Sidebar(role: role, profile: profile, authService: _authService),
      // Changed to ListView to ensure scrollability and stacking of widgets
      body: ListView(
        padding: const EdgeInsets.all(20.0),
        children: [
          // Display the new greeting card at the top
          _buildGreetingCard(context),

          const Padding(
            padding: EdgeInsets.only(top: 8.0, bottom: 12.0),
            child: Text(
              "Quick Access & Analytics",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),

          Row(
            children: [
              Expanded(
                child: _buildDashboardCard(
                  icon: Icons.people,
                  title: 'All Employees',
                  value: '150',
                  onTap: () {},
                ),
              ),
              Expanded(
                child: _buildDashboardCard(
                  icon: Icons.hourglass_empty,
                  title: 'Pending Leaves',
                  value: '5',
                  onTap: () {},
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _buildDashboardCard(
                  icon: Icons.check_circle,
                  title: 'Approved Leaves',
                  value: '20',
                  onTap: () {},
                ),
              ),
              Expanded(
                child: _buildDashboardCard(
                  icon: Icons.attach_money,
                  title: 'Salary Report',
                  value: 'View',
                  onTap: () {},
                ),
              ),
            ],
          ),
        ],
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
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 36, color: Colors.indigo.shade700),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo.shade900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
