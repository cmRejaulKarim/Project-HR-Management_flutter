import 'package:flutter/material.dart';
import 'package:hr_management/employee/employee_profile.dart';
import 'package:hr_management/entity/employee.dart';
import 'package:hr_management/service/auth_service.dart';

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

  String get photoUrl {
    final photo = profile.photo;

    if (photo != null && photo.isNotEmpty) {
      return 'http://localhost:8085/images/employee/$photo';
    }

    return 'http://localhost:8085/images/employee/default_profile.png';
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text(
              '${profile.name ?? 'No Name'} - (${role})',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            accountEmail: Text('${profile.email ?? 'No Email'}'),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              backgroundImage: NetworkImage(photoUrl),
            ),
            decoration: const BoxDecoration(color: Colors.greenAccent),
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
          _navItem(context, 'Admin Dashboard', '/adminProfile'),
          // ✅ Changed to _navItemWithProfile (uses push)
          _navItemWithProfile(context, 'View Profile'),
          _navItem(context, 'View All Employees', '/viewAllEmp'),
          _navItem(context, 'Department Employees', '/EmpByDept'),
          _navItem(context, 'Holidays', '/viewHoliday'),
          _navItem(context, 'Yearly Sal Report', '/getYearSal'),
          _logout(context, 'Logout', '/logout'),
        ];
      case 'DEPARTMENT_HEAD':
        return [
          _navItem(context, 'Dept Head Dashboard', '/deptHeadProfile'),
          // ✅ Changed to _navItemWithProfile (uses push)
          _navItemWithProfile(context, 'View Profile'),
          _navItem(context, 'Leave Request', '/dLeave'),
          _navItem(context, 'All Employees', '/deptEmp'),
          _navItem(context, 'Dept Attendance', '/dAttend'),
          _navItem(context, 'Holidays', '/viewHoliday'),
          _logout(context, 'Logout', '/logout'),
        ];
      case 'ACCOUNTANT':
        return [
          _navItem(context, 'Accountant Dashboard', '/accountantProfile'),
          // ✅ Changed to _navItemWithProfile (uses push)
          _navItemWithProfile(context, 'View Profile'),
          _navItem(context, 'Holiday Management', '/addHoliday'),
          _navItem(context, 'Holidays', '/viewHoliday'),
          _navItem(context, 'Advance Salary Requests', '/advance'),
          _navItem(context, 'View Monthly Salary', '/createSal'),
          _logout(context, 'Logout', '/logout'),
        ];
      default:
        return [const ListTile(title: Text('No Role Found'))];
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

  Widget _navItemWithProfile(BuildContext context, String title) {
    return ListTile(
      title: Text(title),
      onTap: () {
        // Close the drawer before navigating
        Navigator.pop(context);

        // Use push to layer the profile screen on top of the dashboard.
        // This makes the AppBar of EmployeeDashboard automatically include a back button.
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EmployeeDashboard(profile: profile),
          ),
        );
      },
    );
  }

  Widget _logout(BuildContext context, String title, String route) {
    return ListTile(
      title: Text(title),
      onTap: () async {
        if (route == '/logout') {
          await authService.logout();
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil('/login', (route) => false);
        } else {
          Navigator.pushNamed(context, route);
        }
      },
    );
  }
}