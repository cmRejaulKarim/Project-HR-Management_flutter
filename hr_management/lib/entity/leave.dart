// You'll need to define your Status enum and import your Employee model
// enum Status { PENDING, APPROVED, REJECTED }
// import 'package:hr_management/entity/employee.dart';

class Leave {
  final int? id;
  // This field is used when SENDING data (for simplicity, often just the ID is sent).
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
    required this.employee,
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
    // The 'employee' field is a nested object in the fetched JSON.
    final Map<String, dynamic> employeeData = json['employee'];

    // Extract the employee ID from the nested object for the empId field.
    final int? parsedEmpId = employeeData['id'] as int?;

    return Leave(
      id: json['id'] as int?,
      // Populate empId from the nested employee object's ID.
      empId: parsedEmpId,
      // Store the full nested employee data (you can replace 'dynamic' with your Employee model).
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
    // Use the empId field for saving. If not provided, try to extract it from the nested 'employee' field.
    int? employeeIdToSend;
    if (empId != null) {
      employeeIdToSend = empId;
    } else if (employee is Map<String, dynamic> && employee.containsKey('id')) {
      employeeIdToSend = employee['id'] as int?;
    }

    return {
      // Include 'id' only if it's an update operation
      if (id != null) 'id': id,

      // Send the employee ID under the key 'employee' as required by your Spring entity setup
      if (employeeIdToSend != null) 'employee': employeeIdToSend,

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