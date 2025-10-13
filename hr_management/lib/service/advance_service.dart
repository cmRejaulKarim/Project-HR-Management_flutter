import 'dart:convert';
import 'package:hr_management/entity/advance.dart'; // Ensure the updated model is imported
import 'package:hr_management/service/authservice.dart';
import 'package:http/http.dart' as http;

class AdvanceService {
  // IMPORTANT: Ensure your port is correct (http://localhost:8085)
  final String baseUrl = "http://localhost:8085/api/advanceSalary";
  final AuthService _authService = AuthService();

  Future<Map<String, String>> _getHeaders({String contentType = 'application/json'}) async {
    final token = await _authService.getToken();
    final headers = <String, String>{
      'Content-Type': contentType,
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // 1. Add Advance Request (POST /request) - Uses URL-encoded form body
  // Maps to: @PostMapping("/request") with @RequestParam
  Future<AdvanceSalary?> addAdvanceRequest(double amount, String reason) async {
    // Content-Type must be application/x-www-form-urlencoded
    final headers = await _getHeaders(contentType: 'application/x-www-form-urlencoded');

    // Parameters are sent in the body as form data
    final body = 'amount=$amount&reason=${Uri.encodeQueryComponent(reason)}';

    final response = await http.post(
      Uri.parse('$baseUrl/request'),
      headers: headers,
      body: body,
    );

    if (response.statusCode == 200) {
      return AdvanceSalary.fromJson(jsonDecode(response.body));
    } else {
      print('Failed to add advance request: ${response.statusCode} ${response.body}');
      return null;
    }
  }

  // 2. View requests by current employee (GET /ByEmp) - Monthly
  Future<List<AdvanceSalary>> viewAdvanceRequestsByEmp() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/ByEmp'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => AdvanceSalary.fromJson(e)).toList();
    } else {
      print('Failed to fetch monthly advance requests by emp: ${response.statusCode}');
      return [];
    }
  }

  // 3. View requests by current employee (GET /ByEmpYearly) - Yearly
  Future<List<AdvanceSalary>> viewYearlyAdvanceRequestsByEmp() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/ByEmpYearly'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => AdvanceSalary.fromJson(e)).toList();
    } else {
      print('Failed to fetch yearly advance requests by emp: ${response.statusCode}');
      return [];
    }
  }

  // 4. View all advance requests (GET /all)
  Future<List<AdvanceSalary>> viewAllAdvanceRequests() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/all'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => AdvanceSalary.fromJson(e)).toList();
    } else {
      print('Failed to fetch all advance requests: ${response.statusCode}');
      return [];
    }
  }

  // 5. View requests by employee id (GET /employee/{empId})
  Future<List<AdvanceSalary>> viewAdvanceRequests(int empId) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/employee/$empId'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => AdvanceSalary.fromJson(e)).toList();
    } else {
      print('Failed to fetch advance requests for employee $empId: ${response.statusCode}');
      return [];
    }
  }

  // 6. Approve AdvanceSalary by id (PUT /{id}/approve)
  Future<AdvanceSalary?> approveAdvanceSalary(int id) async {
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse('$baseUrl/$id/approve'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return AdvanceSalary.fromJson(jsonDecode(response.body));
    } else {
      print('Failed to approve advance salary $id: ${response.statusCode}');
      return null;
    }
  }

  // 7. Reject AdvanceSalary by id (PUT /{id}/reject)
  Future<AdvanceSalary?> rejectAdvanceSalary(int id) async {
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse('$baseUrl/$id/reject'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return AdvanceSalary.fromJson(jsonDecode(response.body));
    } else {
      print('Failed to reject advance salary $id: ${response.statusCode}');
      return null;
    }
  }

  // 8. Get approved advance for specific Month (GET /employee/{empId}/approved?date=...)
  Future<AdvanceSalary?> getApprovedAdvanceForMonth(int empId, String date) async {
    final headers = await _getHeaders();
    final uri = Uri.parse('$baseUrl/employee/$empId/approved').replace(queryParameters: {'date': date});

    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      // Check for empty body if no advance is found
      if (response.body.isEmpty) return null;
      return AdvanceSalary.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 404) {
      // Handle 404 if the server sends it for "not found"
      return null;
    } else {
      print('Failed to get approved advance for month: ${response.statusCode}');
      return null;
    }
  }

  // 9. Get all advances in a period (GET /employee/{empId}/period?startDate=...&endDate=...)
  Future<List<AdvanceSalary>> getAdvancesInPeriod(int empId, String startDate, String endDate) async {
    final headers = await _getHeaders();
    final uri = Uri.parse('$baseUrl/employee/$empId/period').replace(queryParameters: {
      'startDate': startDate,
      'endDate': endDate,
    });

    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => AdvanceSalary.fromJson(e)).toList();
    } else {
      print('Failed to get advances in period: ${response.statusCode}');
      return [];
    }
  }
}