class Attendance {
  final int id;
  // This is the Employee ID, which is nested in the JSON
  final int empId;
  final String date;
  final String? checkIn;
  final String? checkOut;
  final double? totalWorkingTime;
  final double? overtimeHours;

  // These fields are already nullable, but we'll cast explicitly in fromJson
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
    // Safely extract nested employee ID
    final employeeJson = json['employee'] as Map<String, dynamic>?;
    final int? extractedEmpId = employeeJson?['id'] as int?;

    // Check if extractedEmpId is null (unlikely but safe)
    if (extractedEmpId == null) {
      throw FormatException('Employee ID is missing or invalid in Attendance JSON');
    }

    return Attendance(
      // Use explicit cast for non-nullable fields
      id: json['id'] as int,
      empId: extractedEmpId,
      date: json['date'] as String,

      // CheckIn/CheckOut are nullable Strings
      checkIn: json['checkIn'] as String?,
      checkOut: json['checkOut'] as String?,

      // Safe casting for double fields that come as num or null
      totalWorkingTime: json['totalWorkingTime'] != null
          ? (json['totalWorkingTime'] as num).toDouble()
          : null,
      overtimeHours: json['overtimeHours'] != null
          ? (json['overtimeHours'] as num).toDouble()
          : null,

      // Cast for nullable int/bool fields
      lateCount: json['lateCount'] as int?,
      absent: json['absent'] as bool?,
    );
  }

}