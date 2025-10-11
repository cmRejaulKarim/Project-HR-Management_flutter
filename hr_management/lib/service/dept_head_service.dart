import 'dart:convert';
import 'package:hr_management/entity/dept_head.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';


class DeptHeadService {
  final String baseUrl = 'http://localhost:8085/api/deptHead';

  /// Helper: Get Authorization headers with Bearer token
  Future<Map<String, String>> _getAuthHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');

    final headers = <String, String>{
      'Content-Type': 'application/json',
    };

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  /// Register current user as Department Head
  Future<String> register() async {
    final headers = await _getAuthHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to register as Dept Head');
    }
  }

  /// Get all department heads
  Future<List<DeptHead>> getAll() async {
    final headers = await _getAuthHeaders();
    final response = await http.get(
      Uri.parse(baseUrl),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => DeptHead.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load department heads');
    }
  }

  /// Get all active department heads
  Future<List<DeptHead>> getAllActive() async {
    final headers = await _getAuthHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/active'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => DeptHead.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load active department heads');
    }
  }

  /// End Department Head role by ID
  Future<String> endRole(int id) async {
    final headers = await _getAuthHeaders();
    final response = await http.put(
      Uri.parse('$baseUrl/end/$id'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to end department head role');
    }
  }
}
