class Attendance {
  final int id;
  final int empId;
  final String date;
  final String? checkIn;
  final String? checkOut;
  final double? totalWorkingTime;
  final double? overtimeHours;

  final int? lateCount;
  final bool? absent;

  Attendance({
    required this.id,
    required this.empId,
    required this.date,
    this.checkIn,
    this.checkOut,
    this.totalWorkingTime,
    this.overtimeHours,
    this.lateCount,
    this.absent,
  });

  factory Attendance.fromJson(Map<String, dynamic> json) {
    final employeeJson = json['employee'] as Map<String, dynamic>?;
    final int? extractedEmpId = employeeJson?['id'] as int?;

    if (extractedEmpId == null) {
      throw FormatException(
        'Employee ID is missing or invalid in Attendance JSON',
      );
    }

    return Attendance(
      id: json['id'] as int,
      empId: extractedEmpId,
      date: json['date'] as String,

      checkIn: json['checkIn'] as String?,
      checkOut: json['checkOut'] as String?,

      totalWorkingTime: json['totalWorkingTime'] != null
          ? (json['totalWorkingTime'] as num).toDouble()
          : null,
      overtimeHours: json['overtimeHours'] != null
          ? (json['overtimeHours'] as num).toDouble()
          : null,

      lateCount: json['lateCount'] as int?,
      absent: json['absent'] as bool?,
    );
  }
}
