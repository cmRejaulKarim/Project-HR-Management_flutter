import 'package:flutter/material.dart';
import 'package:hr_management/service/authservice.dart';

class Sidebar extends StatelessWidget {
  final String role;
  final AuthService authService;

  const Sidebar({
    Key? key,
    required this.role,
    required this.authService,
  }) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Text(
              'HRMS',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
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
          _navItem(context, 'Leave Request', '/leave'),
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
          ListTile(title: Text('No Role Found')),
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
          Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
        } else {
          Navigator.pushNamed(context, route);
        }
      },
    );
  }

}
