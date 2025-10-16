class Employee {
  final int id;
  final String name;
  final String email;
  final String? photo; // optional
  final String? address;
  final String? gender;
  final String? dateOfBirth; // or DateTime
  final int? departmentId;
  final int? designationId;
  final String? joiningDate;
  final String? phone;
  final double? basicSalary;
  final bool? active;

  Employee({
    required this.id,
    required this.name,
    required this.email,
    this.photo,
    this.address,
    this.gender,
    this.dateOfBirth,
    this.departmentId,
    this.designationId,
    this.joiningDate,
    this.phone,
    this.basicSalary,
    this.active,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      photo: json['photo'],
      address: json['address'],
      gender: json['gender'],
      dateOfBirth: json['dateOfBirth'],
      // departmentId: json['department'],
      // designationId: json['designation'],
      // ✅ FIX: extract `id` from department and designation objects
      departmentId: json['department'] is Map ? json['department']['id'] : json['department'],
      designationId: json['designation'] is Map ? json['designation']['id'] : json['designation'],

      joiningDate: json['joiningDate'],
      phone: json['phone'],
      basicSalary: (json['basicSalary'] as num?)?.toDouble(),
      active: json['active'] as bool?,
    );
  }
  //basicSalary:  (json['basicSalary'] != null)
  // ? (json['basicSalary'] as num).toDouble()
  //     : null,


  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      if (photo != null) 'photo': photo,
      if (address != null) 'address': address,
      if (gender != null) 'gender': gender,
      if (dateOfBirth != null) 'dateOfBirth': dateOfBirth,
      if (departmentId != null) 'department': departmentId,
      if (designationId != null) 'designation': designationId,
      if (joiningDate != null) 'joiningDate': joiningDate,
      if (phone != null) 'phone': phone,
      if (basicSalary != null) 'basicSalary': basicSalary,
      if (active != null) 'active': active,
    };
  }

  String? operator [](String other) {}
}
// class Employee {
//   final int id;
//   final String name;
//   final String email;
//   final String? photo;
//   final String? address;
//   final String? gender;
//   final String? dateOfBirth;
//   final int? departmentId;
//   final int? designationId;
//   final String? joiningDate;
//   final String? phone;
//   final double? basicSalary;
//   final bool? active;
//
//   Employee({
//     required this.id,
//     required this.name,
//     required this.email,
//     this.photo,
//     this.address,
//     this.gender,
//     this.dateOfBirth,
//     this.departmentId,
//     this.designationId,
//     this.joiningDate,
//     this.phone,
//     this.basicSalary,
//     this.active, // ✅ ADDED
//   });
//
//   factory Employee.fromJson(Map<String, dynamic> json) {
//     // Note: The Spring Boot EmployeeDTO sends department/designation as IDs (Long)
//     // The previous implementation for nested objects is still good practice for other endpoints
//     // but for the DTO-based endpoints, they will likely be just 'department' (ID)
//     final departmentValue = json['department'];
//     final designationValue = json['designation'];
//
//     return Employee(
//       id: json['id'] as int,
//       name: json['name'] as String,
//       email: json['email'] as String,
//       photo: json['photo'] as String?,
//       address: json['address'] as String?,
//       gender: json['gender'] as String?,
//       dateOfBirth: json['dateOfBirth'] as String?,
//
//       // Since the controller uses EmployeeDTO (which has Long/int IDs),
//       // we primarily expect an ID, but handle both object or ID for robustness.
//       departmentId: departmentValue is int
//           ? departmentValue
//           : (departmentValue is Map ? departmentValue['id'] as int? : null),
//       designationId: designationValue is int
//           ? designationValue
//           : (designationValue is Map ? designationValue['id'] as int? : null),
//
//       joiningDate: json['joiningDate'] as String?,
//       phone: json['phone'] as String?,
//       basicSalary: (json['basicSalary'] as num?)?.toDouble(),
//       active: json['active'] as bool?,
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'name': name,
//       'email': email,
//       // ... other fields ...
//       if (departmentId != null) 'department': departmentId,
//       if (designationId != null) 'designation': designationId,
//       // ... other fields ...
//       if (basicSalary != null) 'basicSalary': basicSalary,
//       if (active != null) 'active': active,
//     };
//   }
// }
