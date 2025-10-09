import 'dart:convert';
import 'package:hr_management/entity/department.dart';
import 'package:http/http.dart' as http;

class DepartmentService {
  final String baseUrl = "http://localhost:8085/api";

  Future<List<Department>?> getAllDepartments() async {
    final url = Uri.parse('$baseUrl/department');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> body = jsonDecode(response.body);

        return body.map((json) => Department.fromJson(json)).toList();
      } else {
        print('Failed to fetch departments: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error fetching departments: $e');
      return null;
    }
  }

  Future<List<Department>> getDepartments() async {
    final response = await http.get(Uri.parse('$baseUrl/department'));
    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return data.map((json) => Department.fromJson(json)).toList();
    }
    throw Exception('Failed to load departments');
  }

  Future<List<Department>> getDesignations() async {
    final response = await http.get(Uri.parse('$baseUrl/designation/by-department/'));
    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return data.map((json) => Department.fromJson(json)).toList();
    }
    throw Exception('Failed to load departments');
  }


}
