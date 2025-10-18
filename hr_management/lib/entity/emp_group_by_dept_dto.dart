// lib/model/emp_group_by_dept_dto.dart

import '../entity/employee.dart'; // Import your existing Employee model

// Assuming a simplified User model for the departmentHead
// If you have a full User model, use that.
class DepartmentHead {
  final int id;
  final String name;
  final String email;

  DepartmentHead({required this.id, required this.name, required this.email});

  factory DepartmentHead.fromJson(Map<String, dynamic> json) {
    return DepartmentHead(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
    );
  }
}

class EmpGroupByDeptDTO {
  final int departmentId;
  final String departmentName;
  final DepartmentHead? departmentHead; // Can be null as per your JSON
  final List<Employee> employees;

  EmpGroupByDeptDTO({
    required this.departmentId,
    required this.departmentName,
    this.departmentHead,
    required this.employees,
  });

  factory EmpGroupByDeptDTO.fromJson(Map<String, dynamic> json) {
    // Safely parse departmentHead
    DepartmentHead? head;
    if (json['departmentHead'] != null) {
      head = DepartmentHead.fromJson(json['departmentHead'] as Map<String, dynamic>);
    }

    // Parse the list of employees
    final List<dynamic> employeeList = json['employees'] as List<dynamic>;
    final List<Employee> employees = employeeList
        .map((e) => Employee.fromJson(e as Map<String, dynamic>))
        .toList();

    return EmpGroupByDeptDTO(
      departmentId: json['departmentId'] as int,
      departmentName: json['departmentName'] as String,
      departmentHead: head,
      employees: employees,
    );
  }
}