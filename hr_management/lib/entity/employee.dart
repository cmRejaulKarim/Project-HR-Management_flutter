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
      basicSalary: (json['basicSalary'] != null)
          ? (json['basicSalary'] as num).toDouble()
          : null,
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
      if (departmentId != null) 'department': departmentId,
      if (designationId != null) 'designation': designationId,
      if (joiningDate != null) 'joiningDate': joiningDate,
      if (phone != null) 'phone': phone,
      if (basicSalary != null) 'basicSalary': basicSalary,
    };
  }
}
