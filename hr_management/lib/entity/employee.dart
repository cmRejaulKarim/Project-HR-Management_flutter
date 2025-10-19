// lib/entity/employee.dart

import 'department.dart';
import 'designation.dart';

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

  final int? departmentId;
  final int? designationId;

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
    this.departmentId,
    this.designationId,
    this.department,
    this.designation,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    T? _parseNested<T>(dynamic data, T Function(Map<String, dynamic>) fromJson) {
      if (data is Map<String, dynamic>) {
        return fromJson(data);
      }
      return null;
    }

    int? _parseId(dynamic data) {
      if (data is num) {
        return data.toInt();
      }
      return null;
    }

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

      basicSalary: (json['basicSalary'] as num?)?.toDouble(),
      allowance: (json['allowance'] as num?)?.toDouble(),
      active: json['active'] as bool?,

      departmentId: rawDeptId,
      designationId: rawDesId,

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