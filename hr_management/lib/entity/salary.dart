import 'package:hr_management/entity/employee.dart';
// Note: Ensure the Employee class is correctly defined and available via import.

class Salary {
  final int id;
  final Employee employee;
  final String month;
  final double basicSalary;
  final double allowance;
  final double overtimeSalary;
  final double totalSalary;
  final double advanceDeduction;
  final double absencePenalty;
  final double netPay;
  final int? totalMonthlyOverTimeHour;
  final int totalMonthlyLeave;
  final int totalMonthlyAbsence;
  final String submitDate;

  Salary({
    required this.id,
    required this.employee,
    required this.month,
    required this.basicSalary,
    required this.allowance,
    required this.overtimeSalary,
    required this.totalSalary,
    required this.advanceDeduction,
    required this.absencePenalty,
    required this.netPay,
    required this.totalMonthlyOverTimeHour, // Changed to nullable
    required this.totalMonthlyLeave,
    required this.totalMonthlyAbsence,
    required this.submitDate,
  });

  factory Salary.fromJson(Map<String, dynamic> json) {
    // Helper function to safely cast numbers to double
    double parseDouble(dynamic value) {
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    return Salary(
      id: json['id'] as int,
      // Ensure your Employee model's fromJson handles the entire nested structure
      employee: Employee.fromJson(json['employee'] as Map<String, dynamic>),
      month: json['month'] as String,
      basicSalary: parseDouble(json['basicSalary']),
      allowance: parseDouble(json['allowance']),
      overtimeSalary: parseDouble(json['overtimeSalary']),
      totalSalary: parseDouble(json['totalSalary']),
      advanceDeduction: parseDouble(json['advanceDeduction']),
      absencePenalty: parseDouble(json['absencePenalty']),
      netPay: parseDouble(json['netPay']),
      // ✅ Using 'as int?' to correctly handle 'null' in the JSON
      totalMonthlyOverTimeHour: json['totalMonthlyOverTimeHour'] as int?,
      totalMonthlyLeave: json['totalMonthlyLeave'] as int,
      totalMonthlyAbsence: json['totalMonthlyAbsence'] as int,
      submitDate: json['submitDate'] as String,
    );
  }
}