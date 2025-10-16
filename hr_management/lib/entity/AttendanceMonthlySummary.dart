class AttendanceMonthlySummary {
  final int empId;
  final int totalDays;
  final int presents;
  final int absents;
  final int lates;
  // Java uses 'long', we use 'int' in Dart since hours are whole numbers
  final int totalOvertimeHours;

  AttendanceMonthlySummary({
    required this.empId,
    required this.totalDays,
    required this.presents,
    required this.absents,
    required this.lates,
    required this.totalOvertimeHours,
  });

  factory AttendanceMonthlySummary.fromJson(Map<String, dynamic> json) {
    return AttendanceMonthlySummary(
      // EmpId is Long in Java, so we use num.toInt() for safety
      empId: (json['empId'] as num).toInt(),
      totalDays: (json['totalDays'] as num).toInt(),
      presents: (json['presents'] as num).toInt(),
      absents: (json['absents'] as num).toInt(),
      lates: (json['lates'] as num).toInt(),
      totalOvertimeHours: (json['totalOvertimeHours'] as num).toInt(),
    );
  }
}