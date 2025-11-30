import 'package:flutter/material.dart';
import 'package:hr_management/entity/emp_group_by_dept_dto.dart';
import 'package:hr_management/entity/employee.dart';
import 'package:hr_management/pages/employee/employee_details.dart';
import 'package:hr_management/service/employee_service.dart';

class EmployeeByDepartmentPage extends StatefulWidget {
  const EmployeeByDepartmentPage({super.key});

  @override
  State<EmployeeByDepartmentPage> createState() =>
      _EmployeeByDepartmentPageState();
}

class _EmployeeByDepartmentPageState extends State<EmployeeByDepartmentPage> {
  final EmployeeService _employeeService = EmployeeService();
  late Future<List<EmpGroupByDeptDTO>> _groupedEmployeesFuture;

  String? _getPhotoUrl(Employee employee) {
    final photo = employee.photo;
    if (photo != null && photo.isNotEmpty) {
      return 'http://localhost:8085/images/employee/$photo';
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _groupedEmployeesFuture = _employeeService
        .getEmployeesGroupedByDepartment();
  }

  void _navigateToEmployeeDetails(Employee employee) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EmployeeDetailScreen(employee: employee),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Employees by Department'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<EmpGroupByDeptDTO>>(
        future: _groupedEmployeesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No departments found.'));
          }

          final List<EmpGroupByDeptDTO> departments = snapshot.data!;

          return ListView.builder(
            itemCount: departments.length,
            itemBuilder: (context, index) {
              final deptData = departments[index];
              final headName = deptData.departmentHead?.name ?? 'N/A';
              final employeeCount = deptData.employees.length;

              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(
                  vertical: 8.0,
                  horizontal: 8.0,
                ),
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.all(16.0),
                  title: Text(
                    deptData.departmentName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.indigo,
                    ),
                  ),
                  subtitle: Text('Head: $headName | Employees: $employeeCount'),

                  children: deptData.employees.map((employee) {
                    final photoUrl = _getPhotoUrl(employee);

                    return ListTile(
                      contentPadding: const EdgeInsets.only(
                        left: 30,
                        right: 16,
                      ),
                      leading: CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.blueGrey.shade200,
                        backgroundImage: photoUrl != null
                            ? NetworkImage(photoUrl)
                            : null,
                        child: photoUrl == null
                            ? Text(
                                employee.name.isNotEmpty
                                    ? employee.name[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : null,
                      ),

                      title: Text(
                        employee.name,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Email: ${employee.email}'),
                          Text(
                            'Designation: ${employee.designation?.name ?? 'Unknown'}',
                          ),
                        ],
                      ),
                      onTap: () => _navigateToEmployeeDetails(employee),
                    );
                  }).toList(),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
