import 'package:flutter/material.dart';
import 'package:hr_management/entity/department.dart';
import 'package:hr_management/entity/employee.dart';
import 'package:hr_management/entity/leave.dart';
import 'package:hr_management/pages/loginpage.dart';
import 'package:hr_management/pages/sidebar.dart';
import 'package:hr_management/service/authservice.dart';
import 'package:hr_management/service/department_service.dart';
import 'package:hr_management/service/leave_service.dart';

class DeptHeadDashboard extends StatefulWidget {
  final String role;
  final Employee profile;

  const DeptHeadDashboard({
    super.key,
    required this.role,
    required this.profile,
  });

  @override
  State<DeptHeadDashboard> createState() => _DeptHeadDashboardState();
}

class _DeptHeadDashboardState extends State<DeptHeadDashboard> {
  late Future<List<Leave>> _leavesFuture;
  final LeaveService _leaveService = LeaveService();
  final AuthService _authService = AuthService();
  final DepartmentService _departmentService = DepartmentService();

  String? _departmentName;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _leavesFuture = _leaveService.getLeavesByDept();
    _fetchDepartmentName();
  }
  void _fetchDepartmentName() async {
    Department? dept = await _departmentService.getDepartmentById(widget.profile.departmentId!);
    if (dept != null) {
      setState(() {
        _departmentName = dept.name;  // Assuming `name` is the field in Department
      });
    } else {
      print('Department not found');
    }
  }


  // Part of the _DeptHeadDashboardState class

  Future<void> _handleAction(Leave leave, bool approve) async {
    if (leave.id == null) return; // Safety check

    // 1. Show processing message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${approve ? 'Approving' : 'Rejecting'} leave for ${leave.employee}...')),
    );

    try {
      // 2. Call the appropriate service method
      final updatedLeave = approve
          ? await _leaveService.approveLeave(leave.id!)
          : await _leaveService.rejectLeave(leave.id!);

      if (!mounted) return;

      // 3. Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Leave successfully ${updatedLeave?.status}!'),
          backgroundColor: updatedLeave?.status == "APPROVED" ? Colors.green : Colors.red,
        ),
      );

      // 4. Refresh the list to update the UI
      _fetchLeaves();

    } catch (e) {
      if (!mounted) return;
      // 5. Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to perform action: $e'), backgroundColor: Colors.red),
      );
    }
  }

// Function to trigger data fetch
  void _fetchLeaves() {
    setState(() {
      _leavesFuture = _leaveService.getLeavesByDept();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Department Head Dashboard"),
        backgroundColor: Colors.blue.shade700,
      ),
      drawer: Sidebar(
        role: widget.role,
        profile: widget.profile,
        authService: _authService,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Leave Requests for ${_departmentName ?? 'Loading department...'}', //have to name
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            FutureBuilder<List<Leave>>(
              future: _leavesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Error loading leaves: ${snapshot.error}',
                        style: TextStyle(fontSize: 16, color: Colors.red),
                      ),
                    ),
                  );
                } else {
                  final leaves = snapshot.data!;

                  return ListView.builder(
                    shrinkWrap: true,
                    physics:const NeverScrollableScrollPhysics(),
                    itemCount: leaves.length,
                    itemBuilder: (context, index) {
                      final leave = leaves[index];
                      return _buildLeaveRequestCard(leave);

                    }
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaveRequestCard(Leave leave) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        elevation: 3,
      child: ListTile(
        leading: CircleAvatar(
          child: Text(leave.employee[0]),
        ),
        title: Text(
          '${leave.employee} - ${leave.status}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: leave.status == 'PENDING' ? Colors.orange.shade700 : Colors.green.shade700,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Start Date: ${leave.startDate}\nEnd Date: ${leave.endDate}',
              ),
              Text(
                'Reason: ${leave.reason}',
              ),
            ],
      ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Approve button (sets 'approve' to true)
            IconButton(
              icon: const Icon(Icons.check_circle_outline, color: Colors.green),
              onPressed: () => _handleAction(leave, true),
            ),
            // Reject button (sets 'approve' to false)
            IconButton(
              icon: const Icon(Icons.cancel_outlined, color: Colors.red),
              onPressed: () => _handleAction(leave, false),
            ),
          ],
        ),
      ),
    );
  }


}
