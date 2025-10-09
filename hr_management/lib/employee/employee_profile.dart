import 'package:flutter/material.dart';
import 'package:hr_management/entity/leave.dart';
import 'package:hr_management/pages/loginpage.dart';
import 'package:hr_management/service/authservice.dart';
import 'package:hr_management/service/department_service.dart';
import 'package:hr_management/service/designation_service.dart';
import 'package:hr_management/service/leave_service.dart';

class EmployeeProfile extends StatefulWidget {
  final Map<String, dynamic> profile;

  EmployeeProfile({Key? key, required this.profile}) : super(key: key);

  @override
  State<EmployeeProfile> createState() => _EmployeeProfileState();
}

class _EmployeeProfileState extends State<EmployeeProfile> {
  final AuthService _authService = AuthService();

  final DepartmentService _departmentService = DepartmentService();

  final DesignationService _designationService = DesignationService();
  final LeaveService _leaveService = LeaveService();

  Map<int, String> departmentNames = {};

  Map<int, String> designationNames = {};
  List<Leave> userLeaves = [];
  bool isLoadingLeaves = true;

  @override
  void initState() {
    super.initState();
    _loadDepartmentsAndDesignations();
    _loadUserLeaves();
  }

  Future<void> _loadDepartmentsAndDesignations() async {
    final departments = await _departmentService.getDepartments();
    final designations = await _designationService.getAllDesignations();

    if (departments != null) {
      setState(() {
        departmentNames = {
          for (var department in departments) department.id: department.name,
        };
      });
    }

    if (designations != null) {
      setState(() {
        designationNames = {
          for (var designation in designations)
            designation.id: designation.name,
        };
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final String baseurl = "http://localhost:8085/images/employee/";

    final String? photo = widget.profile['photo'];

    final String? photoUrl = (photo != null && photo.isNotEmpty)
        ? "$baseurl$photo"
        : null;

    return Scaffold(
      appBar: AppBar(
        title: Text('Employee Profile'),
        backgroundColor: Colors.grey,
        centerTitle: true,
        elevation: 4,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: Colors.grey),
              accountName: Text(
                widget.profile['name'] ?? 'Unknown User',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              accountEmail: Text(
                widget.profile['email'] ?? 'N/A',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              currentAccountPicture: CircleAvatar(
                backgroundImage: (photoUrl != null)
                    ? NetworkImage(photoUrl)
                    : const AssetImage('assets/images/user.png')
                          as ImageProvider,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: Text('My Profile'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: Text('Edit Profile'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            const Divider(),

            ListTile(
              leading: const Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () async {
                await _authService.logout();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
            ),
          ],
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (photoUrl != null)
              Center(
                child: CircleAvatar(
                  radius: 80,
                  backgroundImage: NetworkImage(photoUrl),
                ),
              ),
            const SizedBox(height: 20),
            Text(
              widget.profile['name'] ?? 'Unknown User',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              widget.profile['email'] ?? 'N/A',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            _buildProfileItem(Icons.home, 'Address', widget.profile['address']),
            _buildProfileItem(Icons.person, 'Gender', widget.profile['gender']),
            _buildProfileItem(
              Icons.cake,
              'Date of Birth',
              widget.profile['dateOfBirth'],
            ),
            _buildProfileItem(
              Icons.apartment,
              'Department',
              departmentNames[widget.profile['department']] ?? 'Unknown',
            ),
            _buildProfileItem(
              Icons.work,
              'Designation',
              designationNames[widget.profile['designation']] ?? 'Unknown',
            ),
            _buildProfileItem(
              Icons.date_range,
              'Joining Date',
              widget.profile['joiningDate'],
            ),
            _buildProfileItem(Icons.phone, 'Phone', widget.profile['phone']),
            _buildProfileItem(
              Icons.monetization_on,
              'Basic Salary',
              widget.profile['basicSalary']?.toString(),
            ),

            const SizedBox(height: 20),

            Text(
              'Leave History',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            isLoadingLeaves
                ? Center(child: CircularProgressIndicator())
                : userLeaves.isEmpty
                ? Text('No leave history available')
                : ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: userLeaves.length,

                    itemBuilder: (context, index) {
                      final leave = userLeaves[index];
                      return Card(
                        elevation: 4,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          leading: Icon(Icons.event_note, color: Colors.blue),
                          title: Text('${leave.startDate} → ${leave.endDate}'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Reason: ${leave.reason}'),
                              Text('Status: ${leave.status}'),
                              Text('Requested Date: ${leave.requestedDate}'),
                              Text(
                                'Approval Date: ${leave.approvalDate ?? 'N/A'}',
                                style: TextStyle(
                                  color: _getStatusColor(leave.status),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          trailing: Text('${leave.totalLeaveDays} days'),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'APPROVED':
        return Colors.green;
      case 'REJECTED':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  void _loadUserLeaves() async {
    try {
      final leaves = await _leaveService.getLeaveByUser();
      setState(() {
        userLeaves = leaves;
        isLoadingLeaves = false;
      });
    } catch (e) {
      print('error loading leaves: $e');
      setState(() {
        isLoadingLeaves = false;
      });
    }
  }
}

Widget _buildProfileItem(IconData icon, String title, String? value) {
  return ListTile(
    leading: Icon(icon),
    title: Text(title),
    subtitle: Text(value ?? 'N/A'),
  );
}
