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

  factory Attendance.fromJson(Map<String, dynamic> json) => Attendance(
    id: json['id'],
    empId: json['empId'],
    date: json['date'],
    checkIn: json['checkIn'],
    checkOut: json['checkOut'],
    totalWorkingTime: json['totalWorkingTime'] != null
        ? (json['totalWorkingTime'] as num).toDouble()
        : null,
    overtimeHours: json['overtimeHours'] != null
        ? (json['overtimeHours'] as num).toDouble()
        : null,
    lateCount: json['lateCount'],
    absent: json['absent'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'empId': empId,
    'date': date,
    if (checkIn != null) 'checkIn': checkIn,
    if (checkOut != null) 'checkOut': checkOut,
    if (totalWorkingTime != null) 'totalWorkingTime': totalWorkingTime,
    if (overtimeHours != null) 'overtimeHours': overtimeHours,
    if (lateCount != null) 'lateCount': lateCount,
    if (absent != null) 'absent': absent,
  };
}
