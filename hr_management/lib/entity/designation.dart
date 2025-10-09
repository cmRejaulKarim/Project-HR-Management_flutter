class Designation {
  final int id;
  final String name;

  Designation({required this.id, required this.name});

  factory Designation.fromJson(Map<String, dynamic> json) {
    return Designation(id: json['id'], name: json['name']);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}
