import 'package:flutter/material.dart';
import 'package:hr_management/entity/employee.dart';
import 'package:hr_management/service/authservice.dart';

class Sidebar extends StatelessWidget {
  final String role;
  final Employee profile;
  final AuthService authService;

  const Sidebar({
    Key? key,
    required this.role,
    required this.profile,
    required this.authService,
  }) : super(key: key);

  // Helper method to construct the photo URL.
  // This uses the logic you provided but ensures a mandatory photo URL is returned.
  String get photoUrl {
    final photo = profile.photo;

    // 1. Check if the employee has a photo file name
    if (photo != null && photo.isNotEmpty) {
      return 'http://localhost:8085/images/employee/$photo';
    }

    // 2. If no photo is available, return a MANDATORY default image URL.
    // NOTE: Ensure a file named 'default_profile.png' exists on your server at this path.
    return 'http://localhost:8085/images/employee/default_profile.png';
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          // 🚀 User Photo, Email, Name (Role) at the top of the Drawer
          UserAccountsDrawerHeader(
            accountName: Text(
              '${profile.name ?? 'No Name'} - (${role})',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            accountEmail: Text(
              '${profile.email ?? 'No Email'}',
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              // Use NetworkImage with the mandatory photoUrl getter
              backgroundImage: NetworkImage(photoUrl),
            ),
            decoration: const BoxDecoration(
              color: Colors.blue,
            ),
          ),
          // -----------------------------------------------------------------

          // Sidebar Navigation Items
          ..._buildSidebarItems(context),
        ],
      ),
    );
  }

  List<Widget> _buildSidebarItems(BuildContext context) {
    switch (role) {
      case 'ADMIN':
        return [
          _navItem(context, 'Admin Dashboard', '/adminprofile'),
          _navItem(context, 'Add Department', '/addDept'),
          _navItem(context, 'View All Employees', '/viewallemp'),
          _navItem(context, 'Department Employees', '/deptEmps'),
          _navItem(context, 'Yearly Sal Report', '/getYearSal'),
          _logout(context, 'Logout', '/logout'),
        ];
      case 'DEPARTMENT_HEAD':
        return [
          _navItem(context, 'Dept Head Dashboard', '/deptheadprofile'),
          _navItem(context, 'Leave Request', '/dLeave'),
          _navItem(context, 'Dept Attendance', '/attendancebydept'),
          _navItem(context, 'Holidays', '/holidayview'),
          _logout(context, 'Logout', '/logout'),
        ];
      case 'ACCOUNTANT':
        return [
          _navItem(context, 'Accountant Dashboard', '/accountantprofile'),
          _navItem(context, 'Add Holiday', '/holidayadd'),
          _navItem(context, 'Advance Salary Requests', '/advsal'),
          _navItem(context, 'Add/Create Salary', '/addsal'),
          _navItem(context, 'View Monthly Salary', '/createsal'),
          _logout(context, 'Logout', '/logout'),
        ];
      default:
        return [
          const ListTile(title: Text('No Role Found')),
        ];
    }
  }

  Widget _navItem(BuildContext context, String title, String route) {
    return ListTile(
      title: Text(title),
      onTap: () {
        Navigator.pushNamed(context, route);
      },
    );
  }


  Widget _logout(BuildContext context, String title, String route) {
    return ListTile(
      title: Text(title),
      onTap: () async {
        if (route == '/logout') {
          // Perform logout logic
          await authService.logout(); // Call your logout function
          // Navigate to the login screen and remove all other routes from the stack
          Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
        } else {
          Navigator.pushNamed(context, route);
        }
      },
    );
  }
}