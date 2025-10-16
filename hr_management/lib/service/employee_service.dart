import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hr_management/service/auth_service.dart';
// Import the Employee model so the service can return a concrete type
import 'package:hr_management/entity/employee.dart';

class EmployeeService {
  final String baseUrl = "http://localhost:8085/api";

  // CHANGED RETURN TYPE from Map<String, dynamic>? to Employee?
  Future<Employee?> getEmployeeProfile() async {
    // Using a new instance of AuthService to avoid dependency issues if not injected
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
      final Map<String, dynamic> json = jsonDecode(response.body);

      // ✅ FIX: Convert the JSON map into an Employee object using the factory constructor
      return Employee.fromJson(json);
    } else {
      print('Failed to fetch employee profile: ${response.body}');
      return null;
    }
  }
}
