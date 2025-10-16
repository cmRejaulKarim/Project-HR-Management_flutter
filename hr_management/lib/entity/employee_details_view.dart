import '../entity/employee.dart';
import '../entity/department.dart'; // Needed for type hints in Employee
import '../entity/designation.dart'; // Needed for type hints in Employee

/// A View Model class that combines the core Employee data with resolved
/// nested details (like Department Name and Designation Name) for easy access in the UI.
class EmployeeDetails {
  // We keep the primary Employee object which holds all raw data
  final Employee employee;
  // final Department? department;
  // final Designation? designation;


  // The Employee model should contain the nested Department and Designation objects
  // received directly from the Spring Boot API (if it's a detail endpoint).
  // We reference them here from the employee object.
  // NOTE: The constructor is simplified because the employee object already has the nested data.

  EmployeeDetails({
    required this.employee, required
  });

  // ---------------------------------------------
  // ✅ Convenience Getters for Base Employee Fields
  // These simplify UI access (e.g., details.name instead of details.employee.name)
  // ---------------------------------------------
  int get id => employee.id;
  String get name => employee.name;
  String get email => employee.email;
  String? get phone => employee.phone;
  String? get address => employee.address;
  String? get gender => employee.gender;
  String? get dateOfBirth => employee.dateOfBirth;
  String? get joiningDate => employee.joiningDate;
  double? get basicSalary => employee.basicSalary;
  double? get allowance => employee.allowance; // Includes allowance
  bool get isActive => employee.active ?? false; // Provides a non-nullable boolean for status checks

  // ---------------------------------------------
  // ✅ Getters for Department and Designation NAMES
  // These safely extract the name from the nested object.
  // ---------------------------------------------
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
      // Ensure this URL matches your Spring Boot file serving configuration!
      return 'http://localhost:8085/images/employee/$photo';
    }
    return null;
  }
}