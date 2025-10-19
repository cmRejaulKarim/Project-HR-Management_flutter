class Leave {
  final int? id;
  final int? empId;
  final dynamic employee;

  final String startDate;
  final String endDate;
  final int totalLeaveDays;
  final String reason;
  final String requestedDate;
  final String status;
  final String? approvalDate;

  Leave({
    this.id,
    this.empId,
    required this.employee,
    required this.startDate,
    required this.endDate,
    required this.totalLeaveDays,
    required this.reason,
    required this.requestedDate,
    required this.status,
    this.approvalDate,
  });

  factory Leave.fromJson(Map<String, dynamic> json) {
    final dynamic employeeData = json['employee'];
    final int? parsedEmpId = (employeeData is Map<String, dynamic> && employeeData.containsKey('id'))
        ? employeeData['id'] as int?
        : null;

    return Leave(
      id: json['id'] as int?,
      empId: parsedEmpId,
      employee: employeeData,

      startDate: json['startDate'] as String,
      endDate: json['endDate'] as String,
      totalLeaveDays: json['totalLeaveDays'] as int,
      reason: json['reason'] ?? '',
      requestedDate: json['requestedDate'] as String,
      status: json['status'] as String,
      approvalDate: json['approvalDate'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    int? employeeIdToSend;
    if (empId != null) {
      employeeIdToSend = empId;
    } else if (employee is Map<String, dynamic> && employee.containsKey('id')) {
      employeeIdToSend = employee['id'] as int?;
    }

    Map<String, dynamic>? employeeJson;
    if (employeeIdToSend != null) {
      employeeJson = {'id': employeeIdToSend};
    }

    return {
      if (id != null) 'id': id,

      if (employeeJson != null) 'employee': employeeJson,

      'startDate': startDate,
      'endDate': endDate,
      'totalLeaveDays': totalLeaveDays,
      'reason': reason,
      'requestedDate': requestedDate,
      'status': status,
      if (approvalDate != null) 'approvalDate': approvalDate,
    };
  }
}