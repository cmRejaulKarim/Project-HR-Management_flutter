class AdvanceSalary {
  final int? id;
  final double amount;
  final String? reason;
  final String status;
  final String requestDate;
  final String? approvalDate;

  final int? empId;
  final dynamic employee;

  AdvanceSalary({
    this.id,
    required this.amount,
    this.reason,
    required this.status,
    required this.requestDate,
    this.approvalDate,
    this.empId,
    required this.employee,
  });

  factory AdvanceSalary.fromJson(Map<String, dynamic> json) {
    final dynamic employeeData = json['employee'];
    final int? parsedEmpId =
        (employeeData is Map<String, dynamic> && employeeData.containsKey('id'))
        ? employeeData['id'] as int?
        : null;

    return AdvanceSalary(
      id: json['id'] as int?,
      amount: (json['amount'] as num).toDouble(),
      reason: json['reason'] as String?,
      status: json['status'] as String,
      requestDate: json['requestDate'] as String,
      approvalDate: json['approvalDate'] as String?,

      empId: parsedEmpId,
      employee: employeeData,
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

      'amount': amount,
      if (reason != null) 'reason': reason,
      'status': status,
      'requestDate': requestDate,
      if (approvalDate != null) 'approvalDate': approvalDate,
    };
  }
}
