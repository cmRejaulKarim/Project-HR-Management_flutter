import 'package:flutter/material.dart';
import 'package:hr_management/pages/employee/employee_profile.dart';
import 'package:hr_management/entity/employee.dart';
import 'package:hr_management/pages/sidebar.dart';
import 'package:hr_management/service/auth_service.dart';
import 'package:hr_management/pages/advance/advance_request_list_page.dart';

class AccountantDash extends StatefulWidget {
  final String role;
  final Employee profile;

  const AccountantDash({super.key, required this.role, required this.profile});

  @override
  State<AccountantDash> createState() => _AccountantDashState();
}

class _AccountantDashState extends State<AccountantDash> {
  // Define constants for navigation items
  static const String dashRoute = 'HR (Accounts)';
  static const String advanceRequestRoute = 'Advance Requests';
  static const String profileRoute = 'My Profile';

  String _currentRoute = dashRoute;

  // The AuthService instance
  final AuthService _authService = AuthService();

  Widget _buildBody() {
    switch (_currentRoute) {
      case advanceRequestRoute:
        // 1. Advance Request List Page
        return const AdvanceRequestListPage();
      case profileRoute:
        // 2. Employee Profile Page
        return EmployeeDashboard(profile: widget.profile);
      case dashRoute:
      default:
        // 3. Default Dashboard Welcome
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.account_balance, size: 80, color: Colors.teal),
              const SizedBox(height: 20),
              Text(
                'Welcome, ${widget.profile.name ?? 'Accountant'}!',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Use the sidebar to manage payroll and advances.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              ),
            ],
          ),
        );
    }
  }

  // --- Widget Build ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The AppBar title reflects the current view
      appBar: AppBar(title: Text(_currentRoute)),
      drawer: Sidebar(
        role: widget.role,
        profile: widget.profile,
        authService: _authService,
      ),
      body: _buildBody(),
    );
  }
}
