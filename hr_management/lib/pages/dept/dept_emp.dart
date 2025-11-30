import 'package:flutter/material.dart';
import 'package:hr_management/entity/employee.dart';
import 'package:hr_management/pages/employee/employee_details.dart';
import 'package:hr_management/service/employee_service.dart';

class DepartmentEmployees extends StatefulWidget {
  const DepartmentEmployees({super.key});

  @override
  State<DepartmentEmployees> createState() => _DepartmentEmployeesState();
}

class _DepartmentEmployeesState extends State<DepartmentEmployees> {
  final EmployeeService _employeeService = EmployeeService();
  List<Employee> _departmentEmployees = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchDepartmentEmployees();
  }

  Future<void> _fetchDepartmentEmployees() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final List<Employee> employees = await _employeeService
          .getEmployeesByDept();
      setState(() {
        _departmentEmployees = employees;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load employees. Please check network connection.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String? _getPhotoUrl(String? photoFileName) {
    if (photoFileName != null && photoFileName.isNotEmpty) {
      return 'http://localhost:8085/images/employee/$photoFileName';
    }
    return null;
  }

  void _navigateToEmployeeDetails(Employee employee) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EmployeeDetailScreen(employee: employee),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Department Team'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchDepartmentEmployees,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(child: Text(_error!));
    }
    if (_departmentEmployees.isEmpty) {
      return const Center(
        child: Text('No employees found in your department.'),
      );
    }

    return ListView.builder(
      itemCount: _departmentEmployees.length,
      itemBuilder: (context, index) {
        final employee = _departmentEmployees[index];
        final photoUrl = _getPhotoUrl(employee.photo);

        // --- UPDATED ListTile and CircleAvatar ---
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: ListTile(
            // Clickable Card
            onTap: () => _navigateToEmployeeDetails(employee),

            leading: CircleAvatar(
              radius: 30,
              backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
              child: photoUrl == null
                  ? (employee.name.isNotEmpty
                        ? Text(employee.name[0].toUpperCase())
                        : const Icon(Icons.person, size: 30))
                  : null,
            ),

            title: Text(employee.name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(employee.email),
                Text('Phone: ${employee.phone ?? 'N/A'}'),
              ],
            ),
            trailing: Text(
              employee.active == true ? 'Active' : 'Suspended',
              style: TextStyle(
                color: employee.active == true ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }
}
