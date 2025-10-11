import 'package:flutter/material.dart';

class DeptHeadDashboard extends StatelessWidget {
  const DeptHeadDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dept Head Dashboard'),
        backgroundColor: const Color(0xFFF8F9FA),
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
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text(
                'Logout',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                Navigator.pushNamed(context, '/logout');
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 1, // Use 2 for side-by-side on tablets
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 2.5,
          children: const [
            DashboardCard(
              title: 'Upcoming Holidays',
              content: ['Sep 5 - Eid-e Milad-un-Nabi (Sm)*'],
              icon: Icons.calendar_today,
            ),
            DashboardCard(
              title: 'Employee Attendance',
              content: ['Present Today: 45', 'On Leave: 3'],
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
                  Text(title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      )),
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
