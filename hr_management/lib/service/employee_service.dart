import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hr_management/service/authservice.dart';

class EmployeeService{

  final String baseUrl = "http://localhost:8085/api";

  Future<Map<String, dynamic>?> getEmployeeProfile() async {
    String? token = await AuthService().getToken();

    if (token == null) {
      print('Token is null');
      return null;

    }

    final url = Uri.parse('$baseUrl/employee/profile');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print('Failed to fetch employee profile: ${response.body}');
      return null;
    }


  }
}