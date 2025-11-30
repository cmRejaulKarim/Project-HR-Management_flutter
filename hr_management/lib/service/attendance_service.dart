import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:hr_management/entity/AttendanceMonthlySummary.dart';
import 'package:hr_management/entity/attendance.dart';
import 'package:hr_management/service/auth_service.dart';
import 'package:http/http.dart' as http;

class AttendanceService {
  final String baseUrl = "http://localhost:8085/api/attendance";
  final AuthService _authService = AuthService();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getToken();
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  Future<Attendance?> getTodayLog() async {
    final token = await _authService.getToken();
    if (token == null) return null;

    final response = await http.get(
      Uri.parse('$baseUrl/today'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final body = response.body.trim();

      if (body.isEmpty) {
        print("No attendance log for today.");
        return null;
      }

      try {
        return Attendance.fromJson(jsonDecode(body));
      } catch (e) {
        print('Error decoding attendance JSON: $e\nBody: $body');
        return null;
      }
    } else {
      print(
        'Failed to fetch today\'s log (status: ${response.statusCode}): ${response.body}',
      );
      return null;
    }
  }

  // // ✅ Get Today's Log
  // Future<Attendance?> getTodayLog() async {
  //   final headers = await _getHeaders();
  //   final response = await http.get(Uri.parse('$baseUrl/today'), headers: headers);
  //
  //   if (response.statusCode == 200) {
  //     final body = response.body.trim();
  //     if (body.isEmpty) return null;
  //     try {
  //       return Attendance.fromJson(jsonDecode(body));
  //     } catch (e) {
  //       print('Error decoding attendance JSON: $e');
  //       return null;
  //     }
  //   } else {
  //     print('Failed to fetch today\'s log: ${response.statusCode}');
  //     return null;
  //   }
  // }

  //All Employees Monthly Attendance
  Future<List<Attendance>> getAllEmployeesMonthlyAttendance(
    int year,
    int month,
  ) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/monthly?year=$year&month=$month'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => Attendance.fromJson(e)).toList();
    } else {
      print('Failed to get all employees attendance: ${response.statusCode}');
      return [];
    }
  }

  //Single Employee Monthly Attendance
  Future<List<Attendance>> getEmployeeMonthlyAttendance(
    int employeeId,
    int year,
    int month,
  ) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/monthly/$employeeId?year=$year&month=$month'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => Attendance.fromJson(e)).toList();
    } else {
      print(
        'Failed to get employee monthly attendance: ${response.statusCode}',
      );
      return [];
    }
  }

  // Department Today Log (UPDATED to use new URL and return typed list)
  Future<List<Attendance>> getDepartmentTodayLog() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/department/today'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      try {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => Attendance.fromJson(e)).toList();
      } catch (e) {
        debugPrint('Error decoding department today log JSON: $e');
        return [];
      }
    } else {
      debugPrint('Failed to get department today log: ${response.statusCode}');
      return [];
    }
  }

  //Department Monthly Summary (UPDATED to return typed list and parse DTO)
  Future<List<AttendanceMonthlySummary>> getDepartmentMonthlySummary(
    int year,
    int month,
  ) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/department/monthly-summary?year=$year&month=$month'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      try {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => AttendanceMonthlySummary.fromJson(e)).toList();
      } catch (e) {
        debugPrint('Error decoding monthly summary JSON: $e');
        return [];
      }
    } else {
      debugPrint(
        'Failed to get department monthly summary: ${response.statusCode}',
      );
      return [];
    }
  }
}
