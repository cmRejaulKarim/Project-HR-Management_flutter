// lib/entity/employee.dart

import 'department.dart'; // Ensure you have this model
import 'designation.dart'; // Ensure you have this model

class Employee {
  final int id;
  final String name;
  final String email;
  final String? photo;
  final String? address;
  final String? gender;
  final String? dateOfBirth;
  final String? joiningDate;
  final String? phone;
  final double? basicSalary;
  final double? allowance; // ✅ ADDED: Field for allowance
  final bool? active;

  // ✅ UPDATED: Store the full nested objects
  final Department? department;
  final Designation? designation;

  Employee({
    required this.id,
    required this.name,
    required this.email,
    this.photo,
    this.address,
    this.gender,
    this.dateOfBirth,
    this.joiningDate,
    this.phone,
    this.basicSalary,
    this.allowance, // Added to constructor
    this.active,
    this.department, // Added to constructor
    this.designation, // Added to constructor
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    // Helper function to safely parse nested objects or return null
    T? _parseNested<T>(dynamic data, T Function(Map<String, dynamic>) fromJson) {
      if (data is Map<String, dynamic>) {
        return fromJson(data);
      }
      return null;
    }

    // Fallback to ID-only if the value is an int (e.g., from a list DTO)
    // NOTE: If you need to retrieve the ID from a simple list endpoint,
    // you should create a separate, leaner EmployeeListItem model instead.

    return Employee(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      photo: json['photo'] as String?,
      address: json['address'] as String?,
      gender: json['gender'] as String?,
      dateOfBirth: json['dateOfBirth'] as String?,
      joiningDate: json['joiningDate'] as String?,
      phone: json['phone'] as String?,

      // Handle numeric conversion safely
      basicSalary: (json['basicSalary'] as num?)?.toDouble(),
      allowance: (json['allowance'] as num?)?.toDouble(), // ✅ PARSED allowance
      active: json['active'] as bool?,

      // ✅ Handle nested objects (Department/Designation)
      department: _parseNested(json['department'], Department.fromJson),
      designation: _parseNested(json['designation'], Designation.fromJson),
    );
  }

  // NOTE: When sending data back to Spring, you typically only send IDs if needed, 
  // or a specific DTO map. This toJson sends nulls for complex objects.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      if (photo != null) 'photo': photo,
      if (address != null) 'address': address,
      if (gender != null) 'gender': gender,
      if (dateOfBirth != null) 'dateOfBirth': dateOfBirth,
      // If sending back, usually only the ID is needed for related entities
      if (department != null) 'departmentId': department!.id,
      if (designation != null) 'designationId': designation!.id,
      if (joiningDate != null) 'joiningDate': joiningDate,
      if (phone != null) 'phone': phone,
      if (basicSalary != null) 'basicSalary': basicSalary,
      if (allowance != null) 'allowance': allowance,
      if (active != null) 'active': active,
    };
  }
}