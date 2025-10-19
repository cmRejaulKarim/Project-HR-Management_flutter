import 'dart:convert';

import 'package:hr_management/entity/leave.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class LeaveService {
  // Corrected baseUrl to match Spring Boot @RequestMapping("/api/leave/")
  final String baseUrl = "http://localhost:8085/api/leave";

  // for Auth header and token
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

  Future<Leave?> applyLeave(Leave leave) async {
    final headers = await getAuthHeaders();
    // Endpoint: /api/leave/add
    final response = await http.post(
      Uri.parse('$baseUrl/add'),
      headers: headers,
      body: jsonEncode(leave.toJson()),
    );
    if (response.statusCode == 200) {
      return Leave.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to apply leave');
    }
  }

  // get leave for employee profile
  Future<List<Leave>> getLeaveByUser() async {
    final headers = await getAuthHeaders();
    // Endpoint: /api/leave/byEmp
    final response = await http.get(
      Uri.parse('$baseUrl/byEmp'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return data.map((item) => Leave.fromJson(item)).toList();
    }
    throw Exception('Failed to fetch Employee leave');
  }

  Future<List<Leave>> getLeaveByUserSafer() async {
    final headers = await getAuthHeaders();
    // Endpoint: /api/leave/byEmp
    final response = await http.get(
      Uri.parse('$baseUrl/byEmp'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      final body = response.body;
      if (body.trim().isEmpty) {
        return [];
      }
      try {
        List<dynamic> data = jsonDecode(body);
        print('getLeaveByUser response body: "${response.body}"');
        return data.map((item) => Leave.fromJson(item)).toList();

      } catch (e) {
        print('getLeaveByUser JSON decode error: $e, body: $body');
        return [];
      }
    } else {
      print('getLeaveByUser failed: ${response.statusCode}, body: ${response.body}');
      throw Exception('Failed to fetch Employee leave');
    }
  }

  //get current months leave
  Future<List<Leave>> getCurrentMonthLeaveByUser() async {
    final headers = await getAuthHeaders();
    // Endpoint: /api/leave/monthlyByEmp
    final response = await http.get(
      Uri.parse('$baseUrl/monthlyByEmp'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return data.map((item) => Leave.fromJson(item)).toList();
    }
    throw Exception('Failed to fetch Employee monthly leave');
  }

  // get current years leave
  Future<List<Leave>> getYearlyLeavesByUser() async {
    final headers = await getAuthHeaders();
    // Endpoint: /api/leave/yearlyByEmp
    final response = await http.get(
      Uri.parse('$baseUrl/yearlyByEmp'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return data.map((item) => Leave.fromJson(item)).toList();
    }
    throw Exception('Failed to fetch Employee yearly leave');
  }

  // Get total approved leave days (current year)
  Future<int> getYearlyTotalLeavesByUser() async {
    final headers = await getAuthHeaders();
    // Corrected concatenation. Endpoint: /api/leave/YearlyTotalByEmp
    final response = await http.get(
      Uri.parse('$baseUrl/YearlyTotalByEmp'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      // API returns an Integer, so we parse the body directly as an int
      return int.parse(response.body);
    }
    throw Exception("Failed to fetch yearly leave total");
  }

  // Get total approved leave days for specific employee
  Future<int> getYearlyTotalLeavesByEmpId(int empId) async {
    final headers = await getAuthHeaders();
    // Corrected concatenation. Endpoint: /api/leave/YearlyTotalByEmpId?empId=...
    final response = await http.get(
      Uri.parse('$baseUrl/YearlyTotalByEmpId?empId=$empId'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      // API returns an Integer, so we parse the body directly as an int
      return int.parse(response.body);
    }
    throw Exception("Failed to fetch yearly leave total for employee");
  }

  // Get leaves by department
  Future<List<Leave>> getLeavesByDept() async {
    final headers = await getAuthHeaders();
    // Endpoint: /api/leave/byDept
    final response = await http.get(
      Uri.parse('$baseUrl/byDept'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return data.map((json) => Leave.fromJson(json)).toList();
    }
    throw Exception("Failed to load department leaves");
  }

  // Get leaves of department heads
  Future<List<Leave>> getDeptHeadLeaves() async {
    final headers = await getAuthHeaders();
    // Endpoint: /api/leave/ofDeptHeads
    final response = await http.get(
      Uri.parse('$baseUrl/ofDeptHeads'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return data.map((json) => Leave.fromJson(json)).toList();
    }
    throw Exception("Failed to load department head leaves");
  }

  // Approve leave
  Future<Leave?> approveLeave(int id) async {
    final headers = await getAuthHeaders();
    // Endpoint: /api/leave/{id}/approve
    final response = await http.put(
      Uri.parse('$baseUrl/$id/approve'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      return Leave.fromJson(jsonDecode(response.body));
    }
    throw Exception("Failed to approve leave");
  }

  // Reject leave
  Future<Leave?> rejectLeave(int id) async {
    final headers = await getAuthHeaders();
    // Endpoint: /api/leave/{id}/reject
    final response = await http.put(
      Uri.parse('$baseUrl/$id/reject'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      return Leave.fromJson(jsonDecode(response.body));
    }
    throw Exception("Failed to reject leave");
  }

  // Delete leave
  // Note: Your Spring Boot API doesn't show a DELETE endpoint, but I'll keep the
  // method and assume a standard REST endpoint of /api/leave/{id}
  Future<void> deleteLeave(int id) async {
    final headers = await getAuthHeaders();
    // Endpoint: /api/leave/{id}
    final response = await http.delete(
      Uri.parse('$baseUrl/$id'),
      headers: headers,
    );
    if (response.statusCode != 200) {
      throw Exception("Failed to delete leave");
    }
  }

  // Get all leaves (Admin)
  Future<List<Leave>> getAllLeaves() async {
    final headers = await getAuthHeaders();
    // Endpoint: /api/leave/all
    final response = await http.get(
      Uri.parse('$baseUrl/all'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return data.map((json) => Leave.fromJson(json)).toList();
    }
    throw Exception("Failed to fetch all leaves");
  }

  // Get approved leave days by employee, month, and year
  Future<int> getMonthlyApprovedLeaveDays(int empId, int month, int year) async {
    final headers = await getAuthHeaders();
    // Endpoint: /api/leave/approved/monthly?empId=...&month=...&year=...
    final response = await http.get(
      Uri.parse('$baseUrl/approved/monthly?empId=$empId&month=$month&year=$year'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      return int.parse(response.body);
    }
    throw Exception("Failed to get monthly approved leave days");
  }

  // Get approved leave days by employee and year
  Future<int> getYearlyApprovedLeaveDays(int empId, int year) async {
    final headers = await getAuthHeaders();
    // Endpoint: /api/leave/approved/yearly?empId=...&year=...
    final response = await http.get(
      Uri.parse('$baseUrl/approved/yearly?empId=$empId&year=$year'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      // API returns an Integer, so we parse the body directly as an int
      return int.parse(response.body);
    }
    throw Exception("Failed to get yearly approved leave days");
  }

  // Note: Your Spring Boot API has an endpoint for this: @GetMapping("status/{status}")
  Future<List<Leave>> getLeavesByStatus(String status) async {
    final headers = await getAuthHeaders();
    // Endpoint: /api/leave/status/{status}
    final response = await http.get(
      Uri.parse('$baseUrl/status/$status'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return data.map((json) => Leave.fromJson(json)).toList();
    }
    throw Exception("Failed to fetch leaves by status");
  }
}