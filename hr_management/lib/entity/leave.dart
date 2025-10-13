// You'll need to define your Status enum and import your Employee model
// enum Status { PENDING, APPROVED, REJECTED }
// import 'package:hr_management/entity/employee.dart';

class Leave {
  final int? id;
  // This field is used when SENDING data (the ID of the employee).
  final int? empId;
  // This field holds the actual nested Employee object received from the API (for display).
  final dynamic employee; // Use dynamic or a separate Employee model

  final String startDate;
  final String endDate;
  final int totalLeaveDays;
  final String reason;
  final String requestedDate;
  final String status; // Keep as String to match JSON
  final String? approvalDate;

  Leave({
    this.id,
    this.empId,
    required this.employee, // 'dynamic' will hold the Map<String, dynamic> from API
    required this.startDate,
    required this.endDate,
    required this.totalLeaveDays,
    required this.reason,
    required this.requestedDate,
    required this.status,
    this.approvalDate,
  });

  // Convert JSON to Leave object (used for FETCHING data)
  factory Leave.fromJson(Map<String, dynamic> json) {
    // Check if 'employee' is a Map (nested object)
    final dynamic employeeData = json['employee'];
    final int? parsedEmpId = (employeeData is Map<String, dynamic> && employeeData.containsKey('id'))
        ? employeeData['id'] as int?
        : null;

    return Leave(
      id: json['id'] as int?,
      // Populate empId from the nested employee object's ID.
      empId: parsedEmpId,
      // Store the full nested employee data (Map or the full Employee object if you create that model).
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

  // Convert Leave object to JSON (used for SAVING/SENDING data to the API)
  Map<String, dynamic> toJson() {
    // 1. Determine the Employee ID to send.
    int? employeeIdToSend;
    if (empId != null) {
      employeeIdToSend = empId;
    } else if (employee is Map<String, dynamic> && employee.containsKey('id')) {
      employeeIdToSend = employee['id'] as int?;
    }

    // 2. CRITICAL FIX: Wrap the ID in a nested 'employee' object.
    Map<String, dynamic>? employeeJson;
    if (employeeIdToSend != null) {
      // This produces: {"employee": {"id": 1}}
      employeeJson = {'id': employeeIdToSend};
    }

    return {
      // Include 'id' only if it's an update operation
      if (id != null) 'id': id,

      // Send the nested employee ID object (required by Spring for @ManyToOne)
      if (employeeJson != null) 'employee': employeeJson,

      'startDate': startDate,
      'endDate': endDate,
      'totalLeaveDays': totalLeaveDays,
      'reason': reason,
      'requestedDate': requestedDate,
      // Status is often sent to specify the initial state (e.g., "PENDING")
      'status': status,
      if (approvalDate != null) 'approvalDate': approvalDate,
    };
  }
}