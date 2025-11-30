class AttendanceMonthlySummary {
  final int empId;
  final int totalDays;
  final int presents;
  final int absents;
  final int lates;
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
      empId: (json['empId'] as num).toInt(),
      totalDays: (json['totalDays'] as num).toInt(),
      presents: (json['presents'] as num).toInt(),
      absents: (json['absents'] as num).toInt(),
      lates: (json['lates'] as num).toInt(),
      totalOvertimeHours: (json['totalOvertimeHours'] as num).toInt(),
    );
  }
}
