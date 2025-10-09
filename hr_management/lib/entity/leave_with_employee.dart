class LeaveWithEmployee {
  final int? id;
  final String startDate;
  final String endDate;
  final int totalLeaveDays;
  final String reason;
  final String requestedDate;
  final String status;
  final String? approvalDate;

  // Flattened employee info
  final int employeeId;
  final String employeeName;
  final String employeeEmail;
  final String? departmentName;

  LeaveWithEmployee({
    this.id,
    required this.startDate,
    required this.endDate,
    required this.totalLeaveDays,
    required this.reason,
    required this.requestedDate,
    required this.status,
    this.approvalDate,
    required this.employeeId,
    required this.employeeName,
    required this.employeeEmail,
    this.departmentName,
  });

  factory LeaveWithEmployee.fromJson(Map<String, dynamic> json) {
    return LeaveWithEmployee(
      id: json['id'],
      startDate: json['startDate'],
      endDate: json['endDate'],
      totalLeaveDays: json['totalLeaveDays'],
      reason: json['reason'],
      requestedDate: json['requestedDate'],
      status: json['status'],
      approvalDate: json['approvalDate'],
      employeeId: json['employeeId'],
      employeeName: json['employeeName'],
      employeeEmail: json['employeeEmail'],
      departmentName: json['departmentName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startDate': startDate,
      'endDate': endDate,
      'totalLeaveDays': totalLeaveDays,
      'reason': reason,
      'requestedDate': requestedDate,
      'status': status,
      'approvalDate': approvalDate,
      'employeeId': employeeId,
      'employeeName': employeeName,
      'employeeEmail': employeeEmail,
      'departmentName': departmentName,
    };
  }
}
