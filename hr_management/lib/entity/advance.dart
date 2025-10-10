class AdvanceSalary {
  final int? id;
  final double amount;
  final String? reason;
  final String status;
  final String requestDate;
  final String? approvalDate;

  AdvanceSalary({
    this.id,
    required this.amount,
    this.reason,
    required this.status,
    required this.requestDate,
    this.approvalDate,
  });

  factory AdvanceSalary.fromJson(Map<String, dynamic> json) => AdvanceSalary(
    id: json['id'],
    amount: (json['amount'] as num).toDouble(),
    reason: json['reason'],
    status: json['status'],
    requestDate: json['requestDate'],
    approvalDate: json['approvalDate'],
  );

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'amount': amount,
    if (reason != null) 'reason': reason,
    'status': status,
    'requestDate': requestDate,
    if (approvalDate != null) 'approvalDate': approvalDate,
  };
}
