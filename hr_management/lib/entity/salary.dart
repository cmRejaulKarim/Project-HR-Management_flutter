import 'package:hr_management/entity/employee.dart';
// Note: Ensure the Employee class is correctly defined and available via import.

class Salary {
  final int id;
  // This assumes the employee_id in the DB is mapped to a nested Employee object
  final Employee employee;
  final String month;
  final double basicSalary;
  final double allowance;
  final double overtimeSalary;
  final double totalSalary;
  final double advanceDeduction;
  final double absencePenalty;
  // 🆕 Added 'leavePenalty' based on the 'leave_penalty' DB column
  final double leavePenalty;
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
    // 🆕 Required in constructor
    required this.leavePenalty,
    required this.netPay,
    required this.totalMonthlyOverTimeHour, // Nullable as per the bigint type in DB and your previous model
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

    // Safely parse the 'employee' field, assuming it's nested
    final employeeJson = json['employee'];
    final Employee employeeObject = employeeJson != null && employeeJson is Map<String, dynamic>
        ? Employee.fromJson(employeeJson)
    // Fallback for cases where employee might be a simple ID or null
    // You might need a more robust handling depending on your API response.
        : throw ArgumentError('Employee data is missing or invalid.');

    return Salary(
      id: json['id'] as int,
      employee: employeeObject,
      month: json['month'] as String,
      basicSalary: parseDouble(json['basicSalary']),
      allowance: parseDouble(json['allowance']),
      overtimeSalary: parseDouble(json['overtimeSalary']),
      totalSalary: parseDouble(json['totalSalary']),
      advanceDeduction: parseDouble(json['advanceDeduction']),
      absencePenalty: parseDouble(json['absencePenalty']),
      // 🆕 Added parsing for 'leavePenalty'
      leavePenalty: parseDouble(json['leavePenalty']),
      netPay: parseDouble(json['netPay']),
      // Correctly handle the nullable 'totalMonthlyOverTimeHour'
      totalMonthlyOverTimeHour: json['totalMonthlyOverTimeHour'] as int?,
      totalMonthlyLeave: json['totalMonthlyLeave'] as int,
      totalMonthlyAbsence: json['totalMonthlyAbsence'] as int,
      submitDate: json['submitDate'] as String,
    );
  }
}