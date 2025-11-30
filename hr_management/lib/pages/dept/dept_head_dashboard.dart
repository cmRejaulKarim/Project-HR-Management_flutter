import 'package:flutter/material.dart';
import 'package:hr_management/pages/employee/employee_profile.dart';
import 'package:hr_management/entity/department.dart';
import 'package:hr_management/entity/employee.dart';
import 'package:hr_management/pages/sidebar.dart';
import 'package:hr_management/service/auth_service.dart';
import 'package:hr_management/service/department_service.dart';

class DeptHeadDashboard extends StatefulWidget {
  final String role;
  final Employee profile;

  const DeptHeadDashboard({
    super.key,
    required this.role,
    required this.profile,
  });

  @override
  State<DeptHeadDashboard> createState() => _DeptHeadDashboardState();
}

class _DeptHeadDashboardState extends State<DeptHeadDashboard> {
  final AuthService _authService = AuthService();
  final DepartmentService _departmentService = DepartmentService();

  String? _departmentName;

  @override
  void initState() {
    super.initState();
    _fetchDepartmentName();
  }

  //Data for Dept Name

  void _fetchDepartmentName() async {
    if (widget.profile.department != null) {
      Department? dept = await _departmentService.getDepartmentById(
        widget.profile.department!.id,
      );
      if (dept != null) {
        setState(() {
          _departmentName = dept.name;
        });
      } else {
        debugPrint('Department not found for ID: ${widget.profile.department}');
      }
    }
  }

  void _navigateToMyProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EmployeeDashboard(profile: widget.profile),
      ),
    );
  }

  //Widget Builder

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Department Head Dashboard"),
        backgroundColor: Colors.blue.shade700,
      ),
      drawer: Sidebar(
        role: widget.role,
        profile: widget.profile,
        authService: _authService,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.account_tree, size: 80, color: Colors.blueGrey),
              const SizedBox(height: 20),
              Text(
                'Welcome, ${widget.profile.name ?? 'Department Head'}!',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'You are the Head of ${_departmentName ?? 'Loading Department...'}',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 40),

              // BUTTON 1: View OWN Profile
              ElevatedButton.icon(
                onPressed: _navigateToMyProfile,
                icon: const Icon(Icons.person),
                label: const Text('View My Profile'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 15,
                  ),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 20),

              // BUTTON 2: navigation to Leave
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/dLeave');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Navigate to Leave Management Page...'),
                    ),
                  );
                },
                icon: const Icon(Icons.list_alt),
                label: const Text('View Leave Requests'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 15,
                  ),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
