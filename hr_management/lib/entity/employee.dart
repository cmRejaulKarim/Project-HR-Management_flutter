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
  final double? allowance;
  final bool? active;

  // Fields to capture the raw IDs sent by the API
  final int? departmentId;
  final int? designationId;

  // Fields for the full nested objects (will be null with your current JSON)
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
    this.allowance,
    this.active,
    // Add raw ID fields to the constructor
    this.departmentId,
    this.designationId,
    // Keep nested objects
    this.department,
    this.designation,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    // Helper function to safely parse nested objects or return null
    T? _parseNested<T>(dynamic data, T Function(Map<String, dynamic>) fromJson) {
      if (data is Map<String, dynamic>) {
        return fromJson(data);
      }
      return null;
    }

    // 💡 NEW: Helper to safely extract an ID if the value is a number (int or double)
    int? _parseId(dynamic data) {
      if (data is num) {
        return data.toInt();
      }
      return null;
    }

    // Capture the ID directly from the "department" and "designation" keys
    final int? rawDeptId = _parseId(json['department']);
    final int? rawDesId = _parseId(json['designation']);

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
      allowance: (json['allowance'] as num?)?.toDouble(),
      active: json['active'] as bool?,

      // 💡 Store the raw IDs, which came directly from the JSON
      departmentId: rawDeptId,
      designationId: rawDesId,

      // Attempt to parse nested objects (will return null with your current JSON)
      // This is kept for compatibility if the API changes later.
      department: _parseNested(json['department'], Department.fromJson),
      designation: _parseNested(json['designation'], Designation.fromJson),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      if (photo != null) 'photo': photo,
      if (address != null) 'address': address,
      if (gender != null) 'gender': gender,
      if (dateOfBirth != null) 'dateOfBirth': dateOfBirth,
      // 💡 Use the stored raw IDs for toJson if the nested object is null
      'departmentId': department?.id ?? departmentId,
      'designationId': designation?.id ?? designationId,
      if (joiningDate != null) 'joiningDate': joiningDate,
      if (phone != null) 'phone': phone,
      if (basicSalary != null) 'basicSalary': basicSalary,
      if (allowance != null) 'allowance': allowance,
      if (active != null) 'active': active,
    };
  }
}