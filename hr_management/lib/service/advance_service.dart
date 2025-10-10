import 'dart:convert';
import 'package:hr_management/entity/advance.dart';
import 'package:hr_management/service/authservice.dart';
import 'package:http/http.dart' as http;

class AdvanceService {
  final String baseUrl = "http://localhost:8085/api/advanceSalary";
  final AuthService _authService = AuthService();

  Future<List<AdvanceSalary>> getAdvanceRequests() async {
    final token = await _authService.getToken();
    if (token == null) return [];

    final response = await http.get(
      Uri.parse('$baseUrl/ByEmp'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => AdvanceSalary.fromJson(e)).toList();
    } else {
      print('Failed to fetch advance requests: ${response.body}');
      return [];
    }
  }

  Future<bool> submitAdvanceRequest(double amount, String reason) async {
    final token = await _authService.getToken();
    if (token == null) return false;

    final uri = Uri.parse('$baseUrl/request?amount=$amount&reason=$reason');
    final response = await http.post(uri, headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    });

    return response.statusCode == 200;
  }
}
