class Holiday {
  final int id;
  final String date;
  final String description;

  Holiday({required this.id, required this.date, required this.description});

  factory Holiday.fromJson(Map<String, dynamic> json) {
    return Holiday(
      id: json['id'],
      date: json['date'],
      description: json['description'],
    );
  }
}
