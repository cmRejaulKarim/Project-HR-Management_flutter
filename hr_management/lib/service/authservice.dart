import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:jwt_decode/jwt_decode.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String baseUrl = "http://localhost:8085/api";

  Future<bool> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/auth/login');
    final headers = {'Content-Type': 'application/json'};

    final body = jsonEncode({'email': email, 'password': password});

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      String token = data['token'];

      Map<String, dynamic> payload = Jwt.parseJwt(token);
      String role = payload['role'];

      // Store token and role
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('authToken', token);
      await prefs.setString('userRole', role);

      return true;
    } else {
      print('Failed to log in: ${response.body}');
      return false;
    }
  }

  //register employee
  Future<bool> registerEmployee({
    required Map<String, dynamic> user,
    required Map<String, dynamic> employee,
    File? photoFile,
    Uint8List? photoBytes,
  }) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/employee'),
    );

    request.fields['user'] = jsonEncode(user);
    request.fields['employee'] = jsonEncode(employee);

    if (photoBytes != null) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'photo',
          photoBytes,
          filename: 'photo.jpg',
        ),
      );
    } else if (photoFile != null) {
      request.files.add(
        await http.MultipartFile.fromPath('photo', photoFile.path),
      );
    }

    var response = await request.send();
    return response.statusCode == 200 || response.statusCode == 201;
  }

  Future<String?> getUserRole() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print(prefs);
    print(prefs.getString('userRole'));
    return prefs.getString('userRole');
  }

  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
  }

  Future<bool> isTokenExpired() async {
    String? token = await getToken();
    if (token != null) {
      DateTime expiryDate = Jwt.getExpiryDate(token)!;
      return DateTime.now().isAfter(expiryDate);
    }
    return true;
  }
  Future<bool> isLoggedIn() async {
    String? token = await getToken();
    if (token != null && !await isTokenExpired()) {
      return true;
    }else{
      await logout();
      return false;
    }
  }

  Future<bool> hasRole(List<String> roles) async {
    String? userRole = await getUserRole();
    return userRole != null && roles.contains(userRole);
  }

  Future<bool> isEmployee() async {
    return await hasRole(['EMPLOYEE']);
  }
  Future<bool> isAccountant() async {
    return await hasRole(['ACCOUNTANT']);
  }
  Future<bool> isAdmin() async {
    return await hasRole(['ADMIN']);
  }
  Future<bool> isDeptHead() async {
    return await hasRole(['DEPARTMENT_HEAD']);
  }


  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');

    if (token == null) {
      // Already logged out or token not found
      return;
    }

    final url = Uri.parse('$baseUrl/auth/logout'); // Replace with your actual URL

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        print('Logout successful');
      } else {
        print('Logout failed: ${response.body}');
      }
    } catch (e) {
      print('Logout error: $e');
    }

    // Clear token and user role from local storage regardless of API response
    await prefs.remove('authToken');
    await prefs.remove('userRole');
  }

}
