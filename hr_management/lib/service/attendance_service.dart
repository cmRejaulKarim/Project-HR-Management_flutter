import 'dart:convert';
import 'package:hr_management/entity/attendance.dart';
import 'package:hr_management/service/authservice.dart';
import 'package:http/http.dart' as http;

class AttendanceService {
  final String baseUrl = "http://localhost:8085/api/attendance";
  final AuthService _authService = AuthService();

  Future<Attendance?> getTodayLog() async {
    final token = await _authService.getToken();
    if (token == null) return null;

    final response = await http.get(
      Uri.parse('$baseUrl/today'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final body = response.body.trim();

      // ✅ Handle empty or blank body
      if (body.isEmpty) {
        print("No attendance log for today.");
        return null;
      }

      try {
        return Attendance.fromJson(jsonDecode(body));
      } catch (e) {
        print('Error decoding attendance JSON: $e\nBody: $body');
        return null;
      }
    } else {
      print(
        'Failed to fetch today\'s log (status: ${response.statusCode}): ${response.body}',
      );
      return null;
    }
  }
}
