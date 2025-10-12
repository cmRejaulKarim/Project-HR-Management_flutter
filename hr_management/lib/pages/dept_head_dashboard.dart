import 'package:flutter/material.dart';
import 'package:hr_management/pages/loginpage.dart';
import 'package:hr_management/service/authservice.dart';

class DeptHeadDashboard extends StatelessWidget {
  const DeptHeadDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService _authService = AuthService();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dept Head Dashboard'),
        backgroundColor: const Color(0xFF81817D),
        foregroundColor: Colors.blue,
        elevation: 1,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                'Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                Navigator.pushNamed(context, '/empprofile');
              },
            ),
            ListTile(
              leading: const Icon(Icons.assignment),
              title: const Text('View All Attendance'),
              onTap: () {
                Navigator.pushNamed(context, '/attendancebydept');
              },
            ),
            ListTile(
              leading: const Icon(Icons.time_to_leave_outlined),
              title: const Text('Leave Requests'),
              onTap: () {
                Navigator.pushNamed(context, '/leave');
              },
            ),
            const Divider(
              color: Colors.grey,
              thickness: 1,
              indent: 16,
              endIndent: 16,
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () async {
                await _authService.logout();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 1,
          // Use 2 for side-by-side on tablets
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 2.5,
          children: const [
            DashboardCard(
              title: 'Upcoming Holidays',
              content: [''],
              icon: Icons.calendar_today,
            ),
            DashboardCard(
              title: 'Employee Attendance',
              content: [''],
              icon: Icons.people,
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardCard extends StatelessWidget {
  final String title;
  final List<String> content;
  final IconData icon;

  const DashboardCard({
    super.key,
    required this.title,
    required this.content,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 40, color: Colors.blue),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...content.map((line) => Text(line)).toList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
