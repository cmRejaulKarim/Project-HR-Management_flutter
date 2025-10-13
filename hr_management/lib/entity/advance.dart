// entity/advance.dart

class AdvanceSalary {
  final int? id;
  final double amount;
  final String? reason;
  final String status;
  final String requestDate;
  final String? approvalDate;

  // New fields to handle the Employee relationship:
  final int? empId; // Used when sending data (the ID of the employee).
  final dynamic employee; // Holds the nested Employee object received from the API (for display).

  AdvanceSalary({
    this.id,
    required this.amount,
    this.reason,
    required this.status,
    required this.requestDate,
    this.approvalDate,
    // Add new fields to the constructor
    this.empId,
    required this.employee, // Can be null, or Map, or Employee object
  });

  factory AdvanceSalary.fromJson(Map<String, dynamic> json) {
    // Extract nested employee data
    final dynamic employeeData = json['employee'];
    final int? parsedEmpId = (employeeData is Map<String, dynamic> && employeeData.containsKey('id'))
        ? employeeData['id'] as int?
        : null;

    return AdvanceSalary(
      id: json['id'] as int?,
      amount: (json['amount'] as num).toDouble(),
      reason: json['reason'] as String?,
      status: json['status'] as String,
      requestDate: json['requestDate'] as String,
      approvalDate: json['approvalDate'] as String?,

      // Populate new fields
      empId: parsedEmpId,
      employee: employeeData,
    );
  }

  Map<String, dynamic> toJson() {
    // 1. Determine the Employee ID to send.
    int? employeeIdToSend;
    if (empId != null) {
      employeeIdToSend = empId;
    } else if (employee is Map<String, dynamic> && employee.containsKey('id')) {
      employeeIdToSend = employee['id'] as int?;
    }

    // 2. Wrap the ID in a nested 'employee' object.
    Map<String, dynamic>? employeeJson;
    if (employeeIdToSend != null) {
      // This produces: {"employee": {"id": 1}}
      employeeJson = {'id': employeeIdToSend};
    }

    return {
      if (id != null) 'id': id,

      // NOTE: For the POST /request endpoint, the employee field is NOT sent
      // because the Spring Boot controller resolves the employee from the token.
      // However, if this model is used for PUT/UPDATE where the employee field IS required, 
      // we include it.

      // For POST /request, this will be excluded, which is fine since Spring derives it.
      // For PUT, this allows sending the minimal Employee structure.
      if (employeeJson != null) 'employee': employeeJson,

      'amount': amount,
      if (reason != null) 'reason': reason,
      'status': status,
      'requestDate': requestDate,
      if (approvalDate != null) 'approvalDate': approvalDate,
    };
  }
}