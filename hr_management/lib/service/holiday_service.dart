import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hr_management/entity/holiday.dart';
import 'package:hr_management/service/auth_service.dart';

class HolidayService {
  final String baseUrl =
      'http://localhost:8085/api/holiday'; // Adjust as needed
  final AuthService _authService = AuthService();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getToken();
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  // ✅ Get all holidays
  Future<List<Holiday>> getAllHolidays() async {
    final headers = await _getHeaders();
    final response = await http.get(Uri.parse(baseUrl), headers: headers);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => Holiday.fromJson(e)).toList();
    } else {
      print('Failed to fetch holidays: ${response.statusCode}');
      return [];
    }
  }

  // ✅ Add a holiday (as query params)
  Future<Holiday?> addHoliday(String date, String description) async {
    final headers = await _getHeaders();
    final uri = Uri.parse(
      baseUrl,
    ).replace(queryParameters: {'date': date, 'description': description});

    final response = await http.post(uri, headers: headers);

    if (response.statusCode == 200) {
      return Holiday.fromJson(jsonDecode(response.body));
    } else {
      print('Failed to add holiday: ${response.statusCode} ${response.body}');
      return null;
    }
  }

  // ✅ Delete a holiday by ID
  Future<bool> deleteHoliday(int id) async {
    final headers = await _getHeaders();
    final response = await http.delete(
      Uri.parse('$baseUrl/$id'),
      headers: headers,
    );

    return response.statusCode == 200;
  }
}
