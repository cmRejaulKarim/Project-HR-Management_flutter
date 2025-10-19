// lib/service/salary_service.dart

import 'dart:convert';
import 'package:hr_management/entity/salary.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
// Assuming getAuthHeaders is defined here or imported

// ⭐️ Provided getAuthHeaders implementation (assumed to be available)
Future<Map<String, String>> getAuthHeaders() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('authToken');
  if (token == null) {
    throw Exception('Token not found');
  }
  final headers = {
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json',
  };
  return headers;
}
// ⭐️ End of getAuthHeaders

class SalaryService {
  final String _baseUrl = "http://localhost:8085/api/salary";

  // Fetches the full list of salaries, optionally filtered by month/year.
  Future<List<Salary>> fetchFullSalaries({
    int? year,
    int? month,
  }) async {
    // 1. Get the authenticated headers (token retrieval)
    final headers = await getAuthHeaders();

    // Build query parameters map
    Map<String, String> queryParams = {};
    if (year != null) {
      queryParams['year'] = year.toString();
    }
    if (month != null) {
      queryParams['month'] = month.toString();
    }

    final uri = Uri.parse(_baseUrl).replace(queryParameters: queryParams);

    // 2. Pass headers to the request
    final response = await http.get(
      uri,
      headers: headers, // <-- TOKEN IS PASSED HERE
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => Salary.fromJson(json as Map<String, dynamic>)).toList();
    } else if (response.statusCode == 204) {
      // HTTP 204 No Content
      return [];
    } else if (response.statusCode == 401 || response.statusCode == 403) {
      // Token expired or invalid
      throw Exception('Authentication required. Please re-login.');
    } else {
      throw Exception('Failed to load salaries. Status: ${response.statusCode}');
    }
  }
}