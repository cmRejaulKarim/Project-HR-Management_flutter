import '../entity/employee.dart';
import '../entity/department.dart';
import '../entity/designation.dart';
class EmployeeDetails {
  final Employee employee;
  EmployeeDetails({
    required this.employee, required
  });


  int get id => employee.id;
  String get name => employee.name;
  String get email => employee.email;
  String? get phone => employee.phone;
  String? get address => employee.address;
  String? get gender => employee.gender;
  String? get dateOfBirth => employee.dateOfBirth;
  String? get joiningDate => employee.joiningDate;
  double? get basicSalary => employee.basicSalary;
  double? get allowance => employee.allowance;
  bool get isActive => employee.active ?? false;

  Department? get department => employee.department;
  Designation? get designation => employee.designation;

  String get departmentName => employee.department?.name ?? 'N/A';
  String get designationName => employee.designation?.name ?? 'N/A';

  // ---------------------------------------------
  // ✅ Helper for Photo URL
  // ---------------------------------------------
  String? get photoUrl {
    final photo = employee.photo;
    if (photo != null && photo.isNotEmpty) {
      return 'http://localhost:8085/images/employee/$photo';
    }
    return null;
  }
}