import 'dart:convert';
import 'package:hr_management/entity/department.dart';
import 'package:hr_management/entity/designation.dart';
import 'package:hr_management/entity/emp_group_by_dept_dto.dart';
import 'package:hr_management/entity/employee_details_view.dart';
import 'package:http/http.dart' as http;
import 'package:hr_management/service/auth_service.dart';
import 'package:hr_management/entity/employee.dart';

class EmployeeService {
  final String baseUrl = "http://localhost:8085/api";

  Future<Map<String, String>> _getAuthHeaders({
    bool isMultipart = false,
  }) async {
    String? token = await AuthService().getToken();
    final Map<String, String> headers = {'Authorization': 'Bearer $token'};
    if (!isMultipart) {
      headers['Content-Type'] = 'application/json';
    }
    return headers;
  }

  // Maps to: @PostMapping("/register")
  Future<bool> registerEmployee({
    required Map<String, dynamic> userData,
    required Map<String, dynamic> employeeDtoData,
    required String photoPath,
  }) async {
    final url = Uri.parse('$baseUrl/employee/register');
    String? token = await AuthService().getToken();
    if (token == null) return false;

    var request = http.MultipartRequest('POST', url)
      ..headers.addAll({'Authorization': 'Bearer $token'});

    final registrationDTO = {'user': userData, 'employeeDTO': employeeDtoData};
    final jsonString = jsonEncode(registrationDTO);

    request.fields['data'] = jsonString;

    try {
      request.files.add(await http.MultipartFile.fromPath('photo', photoPath));
    } catch (e) {
      print('Error reading photo file: $e');
      return false;
    }

    // 5. Send the request
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200 || response.statusCode == 201) {
      print('Employee registered successfully: ${response.body}');
      return true;
    } else {
      print('Registration failed: ${response.statusCode} - ${response.body}');
      return false;
    }
  }

  Future<Employee?> getEmployeeProfile() async {
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

      return Employee.fromJson(json);
    } else {
      print('Failed to fetch employee profile: ${response.body}');
      return null;
    }
  }

  // Maps to: @GetMapping("/{id}")
  Future<Employee?> getEmployeeById(int employeeId) async {
    final url = Uri.parse('$baseUrl/employee/$employeeId');
    final response = await http.get(url, headers: await _getAuthHeaders());

    if (response.statusCode == 200) {
      return Employee.fromJson(jsonDecode(response.body));
    }
    print('Failed to fetch employee by ID $employeeId: ${response.statusCode}');
    return null;
  }

  // Maps to: @GetMapping("/all") (The DTO version)
  Future<List<Employee>> getAllEmployees() async {
    final url = Uri.parse('$baseUrl/employee/all');
    final response = await http.get(url, headers: await _getAuthHeaders());

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => Employee.fromJson(json)).toList();
    }
    print('Failed to fetch all employees: ${response.statusCode}');
    return [];
  }

  // Maps to: @GetMapping("/byDept")
  Future<List<Employee>> getEmployeesByDept() async {
    final url = Uri.parse('$baseUrl/employee/byDept');
    final response = await http.get(url, headers: await _getAuthHeaders());

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => Employee.fromJson(json)).toList();
    }
    print('Failed to fetch employees by department: ${response.statusCode}');
    return [];
  }

  // Maps to: @GetMapping("/groupByDept")
  Future<List<EmpGroupByDeptDTO>> getEmployeesGroupedByDepartment() async {
    final url = Uri.parse('$baseUrl/employee/groupByDept');
    final response = await http.get(url, headers: await _getAuthHeaders());

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);

      return jsonList
          .map((e) => EmpGroupByDeptDTO.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    print(
      'Failed to fetch employees grouped by department: ${response.statusCode} - ${response.body}',
    );
    return [];
  }

  // Maps to: @PutMapping("/suspend/{id}")
  Future<bool> suspendEmployee(int employeeId) async {
    final url = Uri.parse('$baseUrl/employee/suspend/$employeeId');
    final response = await http.put(url, headers: await _getAuthHeaders());

    return response.statusCode == 200;
  }

  // Maps to: @PutMapping("/resume/{id}")
  Future<bool> resumeEmployee(int employeeId) async {
    final url = Uri.parse('$baseUrl/employee/resume/$employeeId');
    final response = await http.put(url, headers: await _getAuthHeaders());

    return response.statusCode == 200;
  }

  //for employee profile detail

  Future<Department?> getDepartmentById(int id) async {
    final url = Uri.parse('$baseUrl/department/$id');
    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        return Department.fromJson(body);
      } else {
        print('Failed to fetch department: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error fetching department: $e');
      return null;
    }
  }

  Future<Designation?> getDesignationById(int id) async {
    final url = Uri.parse('$baseUrl/designation/$id');
    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        return Designation.fromJson(body);
      } else {
        print('Failed to fetch designation: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error fetching designation: $e');
      return null;
    }
  }

  //NEW OR UPDATED METHOD for fetching full details
  Future<EmployeeDetails?> getFullEmployeeDetails(int employeeId) async {
    // 1. Fetch the base Employee object (which contains the IDs)
    final Employee? employee = await getEmployeeById(employeeId);

    if (employee == null) {
      return null;
    }

    // 2. Fetch Department and Designation concurrently
    final departmentFuture = employee.department != null
        ? getDepartmentById(employee.department!.id)
        : Future<Department?>.value(null);

    final designationFuture = employee.designation != null
        ? getDesignationById(employee.designation!.id)
        : Future<Designation?>.value(null);

    final results = await Future.wait([departmentFuture, designationFuture]);

    final Department? department = results[0] as Department?;
    final Designation? designation = results[1] as Designation?;

    // 3. Combine into the EmployeeDetails view model
    return EmployeeDetails(
      employee: employee,
      // department: department,
      // designation: designation,
    );
  }
}
