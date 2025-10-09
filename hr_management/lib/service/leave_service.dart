import 'dart:convert';

import 'package:hr_management/entity/leave.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class LeaveService {
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

  //get current months leave
  Future<List<Leave>> getCurrentMonthLeaveByUser() async {
    final headers = await getAuthHeaders();
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
    final response = await http.get(
      Uri.parse('${baseUrl}YearlyTotalByEmp'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception("Failed to fetch yearly leave total");
  }

  // Get total approved leave days for specific employee
  Future<int> getYearlyTotalLeavesByEmpId(int empId) async {
    final headers = await getAuthHeaders();
    final response = await http.get(
      Uri.parse('${baseUrl}YearlyTotalByEmpId?empId=$empId'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception("Failed to fetch yearly leave total for employee");
  }

  // Get leaves by department
  Future<List<Leave>> getLeavesByDept() async {
    final headers = await getAuthHeaders();
    final response = await http.get(
      Uri.parse('${baseUrl}byDept'),
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
    final response = await http.get(
      Uri.parse('${baseUrl}ofDeptHeads'),
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
    final response = await http.put(
      Uri.parse('${baseUrl}$id/approve'),
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
    final response = await http.put(
      Uri.parse('${baseUrl}$id/reject'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      return Leave.fromJson(jsonDecode(response.body));
    }
    throw Exception("Failed to reject leave");
  }

  // Delete leave
  Future<void> deleteLeave(int id) async {
    final headers = await getAuthHeaders();
    final response = await http.delete(Uri.parse('${baseUrl}$id'), headers: headers);
    if (response.statusCode != 200) {
      throw Exception("Failed to delete leave");
    }
  }

  // Get all leaves (Admin)
  Future<List<Leave>> getAllLeaves() async {
    final headers = await getAuthHeaders();
    final response = await http.get(Uri.parse('${baseUrl}all'), headers: headers);
    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return data.map((json) => Leave.fromJson(json)).toList();
    }
    throw Exception("Failed to fetch all leaves");
  }

  // Get approved leave days by employee and year
  Future<int> getYearlyApprovedLeaveDays(int empId, int year) async {
    final headers = await getAuthHeaders();
    final response = await http.get(
      Uri.parse('${baseUrl}approved/yearly?empId=$empId&year=$year'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception("Failed to get yearly approved leave days");
  }
}
