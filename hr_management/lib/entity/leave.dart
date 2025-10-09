import 'employee.dart'; // Assuming it's in the same folder

class Leave {
  final int? id;
  final Employee? employee;
  final String startDate;
  final String endDate;
  final int totalLeaveDays;
  final String reason;
  final String requestedDate;
  final String status; // "PENDING", "APPROVED", "REJECTED"
  final String? approvalDate;

  Leave({
    this.id,
    this.employee,
    required this.startDate,
    required this.endDate,
    required this.totalLeaveDays,
    required this.reason,
    required this.requestedDate,
    required this.status,
    this.approvalDate,
  });

  factory Leave.fromJson(Map<String, dynamic> json) {
    return Leave(
      id: json['id'],
      employee: json['employee'] != null ? Employee.fromJson(json['employee']) : null,
      startDate: json['startDate'],
      endDate: json['endDate'],
      totalLeaveDays: json['totalLeaveDays'],
      reason: json['reason'],
      requestedDate: json['requestedDate'],
      status: json['status'],
      approvalDate: json['approvalDate'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employee': employee?.toJson(),
      'startDate': startDate,
      'endDate': endDate,
      'totalLeaveDays': totalLeaveDays,
      'reason': reason,
      'requestedDate': requestedDate,
      'status': status,
      'approvalDate': approvalDate,
    };
  }
}
