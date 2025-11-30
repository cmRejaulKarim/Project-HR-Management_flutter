import '../entity/employee.dart';

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
  final DepartmentHead? departmentHead;
  final List<Employee> employees;

  EmpGroupByDeptDTO({
    required this.departmentId,
    required this.departmentName,
    this.departmentHead,
    required this.employees,
  });

  factory EmpGroupByDeptDTO.fromJson(Map<String, dynamic> json) {
    DepartmentHead? head;
    if (json['departmentHead'] != null) {
      head = DepartmentHead.fromJson(
        json['departmentHead'] as Map<String, dynamic>,
      );
    }

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
