class Leave {
  final int? id;
  final String startDate;
  final String endDate;
  final int totalLeaveDays;
  final String reason;
  final String requestedDate;
  final String status;
  final String? approvalDate;

  Leave({
    this.id,
    required this.startDate,
    required this.endDate,
    required this.totalLeaveDays,
    required this.reason,
    required this.requestedDate,
    required this.status,
    this.approvalDate,
  });

  // Convert JSON to Leave object
  factory Leave.fromJson(Map<String, dynamic> json) {
    return Leave(
      id: json['id'],
      startDate: json['startDate'],
      endDate: json['endDate'],
      totalLeaveDays: json['totalLeaveDays'],
      reason: json['reason'] ?? '',
      requestedDate: json['requestedDate'],
      status: json['status'],
      approvalDate: json['approvalDate'],
    );
  }

  // Convert Leave object to JSON
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
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
