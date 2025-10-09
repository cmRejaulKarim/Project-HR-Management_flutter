import 'package:flutter/material.dart';
import 'package:hr_management/pages/loginpage.dart';
import 'package:hr_management/service/authservice.dart';

class EmployeeProfile extends StatelessWidget {
  final Map<String, dynamic> profile;
  final AuthService _authService = AuthService();

  EmployeeProfile({Key? key, required this.profile}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String baseurl = "http://localhost:8085/images/employee/";

    final String? photo = profile['photo'];

    final String? photoUrl = (photo != null && photo.isNotEmpty)
        ? "$baseurl$photo"
        : null;

    return Scaffold(
      appBar: AppBar(
        title: Text('Employee Profile'),
        backgroundColor: Colors.grey,
        centerTitle: true,
        elevation: 4,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: Colors.grey),
              accountName: Text(
                profile['name'] ?? 'Unknown User',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              accountEmail: Text(
                profile['email'] ?? 'N/A',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              currentAccountPicture: CircleAvatar(
                backgroundImage: (photoUrl != null)
                    ? NetworkImage(photoUrl)
                    : const AssetImage('assets/images/user.png')
                          as ImageProvider,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: Text('My Profile'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: Text('Edit Profile'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            const Divider(),

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

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (photoUrl != null)
              Center(
                child: CircleAvatar(
                  radius: 80,
                  backgroundImage: NetworkImage(photoUrl),
                ),
              ),
            const SizedBox(height: 20),
            Text(
              profile['name'] ?? 'Unknown User',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              profile['email'] ?? 'N/A',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            _buildProfileItem(Icons.home, 'Address', profile['address']),
            _buildProfileItem(Icons.person, 'Gender', profile['gender']),
            _buildProfileItem(Icons.cake, 'Date of Birth', profile['dateOfBirth']),
            _buildProfileItem(Icons.apartment, 'Department', profile['department']?.toString()),
            _buildProfileItem(Icons.work, 'Designation', profile['designation']?.toString()),
            _buildProfileItem(Icons.date_range, 'Joining Date', profile['joiningDate']),
            _buildProfileItem(Icons.phone, 'Phone', profile['phone']),
            _buildProfileItem(Icons.monetization_on, 'Basic Salary', profile['basicSalary']?.toString()),
          ],
        ),
      ),
    );
  }
}

Widget _buildProfileItem(IconData icon, String title, String? value) {
  return ListTile(
    leading: Icon(icon),
    title: Text(title),
    subtitle: Text(value ?? 'N/A'),
  );
}
