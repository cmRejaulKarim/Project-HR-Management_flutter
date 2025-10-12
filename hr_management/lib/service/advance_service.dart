import 'dart:convert';
import 'package:hr_management/entity/advance.dart';
import 'package:hr_management/service/authservice.dart';
import 'package:http/http.dart' as http;

class AdvanceService {
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

  // Add Advance Request (using application/x-www-form-urlencoded)
  Future<AdvanceSalary?> addAdvanceRequest(double amount, String reason) async {
    final headers = await _getHeaders(contentType: 'application/x-www-form-urlencoded');
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

  // View advance requests by current employee
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
      print('Failed to fetch advance requests by emp: ${response.statusCode}');
      return [];
    }
  }

  // View advance requests by employee id
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

  // View all advance requests
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

  // Approve AdvanceSalary by id
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

  // Reject AdvanceSalary by id
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

  // Get monthly approved advance for employee
  Future<AdvanceSalary?> getMonthlyApprovedAdvance(int empId, String date) async {
    final headers = await _getHeaders();
    final uri = Uri.parse('$baseUrl/employee/$empId/approved').replace(queryParameters: {'date': date});

    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      return AdvanceSalary.fromJson(jsonDecode(response.body));
    } else {
      print('Failed to get monthly approved advance: ${response.statusCode}');
      return null;
    }
  }

  // Get advances in a period for employee
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


  // Future<List<AdvanceSalary>> getAdvanceRequests() async {
  //   final token = await _authService.getToken();
  //   if (token == null) return [];
  //
  //   final response = await http.get(
  //     Uri.parse('$baseUrl/ByEmp'),
  //     headers: {
  //       'Authorization': 'Bearer $token',
  //       'Content-Type': 'application/json',
  //     },
  //   );
  //
  //   if (response.statusCode == 200) {
  //     final List<dynamic> data = jsonDecode(response.body);
  //     return data.map((e) => AdvanceSalary.fromJson(e)).toList();
  //   } else {
  //     print('Failed to fetch advance requests: ${response.body}');
  //     return [];
  //   }
  // }
  //
  // Future<bool> submitAdvanceRequest(double amount, String reason) async {
  //   final token = await _authService.getToken();
  //   if (token == null) return false;
  //
  //   final uri = Uri.parse('$baseUrl/request?amount=$amount&reason=$reason');
  //   final response = await http.post(uri, headers: {
  //     'Authorization': 'Bearer $token',
  //     'Content-Type': 'application/json',
  //   });
  //
  //   return response.statusCode == 200;
  // }
}
