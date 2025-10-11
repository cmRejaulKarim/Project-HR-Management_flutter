class DeptHead {
  int? id;
  int employeeId;
  int departmentId;
  String assignedDate;
  String endDate;
  bool active;

  DeptHead({
    this.id,
    required this.employeeId,
    required this.departmentId,
    required this.assignedDate,
    required this.endDate,
    required this.active,
  });

  factory DeptHead.fromJson(Map<String, dynamic> json) {
    return DeptHead(
      id: json['id'],
      employeeId: json['employeeId'],
      departmentId: json['departmentId'],
      assignedDate: json['assignedDate'],
      endDate: json['endDate'],
      active: json['active'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'employeeId': employeeId,
      'departmentId': departmentId,
      'assignedDate': assignedDate,
      'endDate': endDate,
      'active': active,
    };
  }
}
