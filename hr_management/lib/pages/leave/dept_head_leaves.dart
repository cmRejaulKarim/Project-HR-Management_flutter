import 'package:flutter/material.dart';
import 'package:hr_management/entity/leave.dart';
import 'package:hr_management/service/leave_service.dart';

const String _photoBaseUrl = 'http://localhost:8085/images/employee/';

class Employee {
  final String name;
  final String? photo;
  final dynamic department;
  final dynamic designation;

  Employee({required this.name, this.photo, this.department, this.designation});

  // UPDATED: Factory to safely map the nested employee data
  factory Employee.fromDynamic(dynamic data) {
    if (data is Map<String, dynamic> && data.containsKey('name')) {
      return Employee(
        name: data['name'] as String,
        photo: data['photo'] as String?,
        department: data['department'],
        designation: data['designation'],
      );
    }
    return Employee(name: 'Unknown Employee');
  }
}

class DeptHeadLeavesPage extends StatefulWidget {
  const DeptHeadLeavesPage({super.key});

  @override
  State<DeptHeadLeavesPage> createState() => _DeptHeadLeavesPageState();
}

class _DeptHeadLeavesPageState extends State<DeptHeadLeavesPage> {
  late final LeaveService _leaveService = LeaveService();
  late Future<List<Leave>> _pendingLeavesFuture;

  @override
  void initState() {
    super.initState();
    // Start fetching data immediately
    _fetchPendingLeaves();
  }

  //fetch and filter pending leaves
  void _fetchPendingLeaves() {
    setState(() {
      _pendingLeavesFuture = _leaveService.getDeptHeadLeaves().then((
        allLeaves,
      ) {
        //filter to show PENDING
        return allLeaves.where((leave) => leave.status == 'PENDING').toList();
      });
    });
  }

  // --- Leave Action Handlers (Approve/Reject) ---

  Future<void> _handleLeaveAction(int leaveId, String action) async {
    try {
      if (action == 'APPROVE') {
        await _leaveService.approveLeave(leaveId);
        _showSnackBar('Leave approved successfully.');
      } else if (action == 'REJECT') {
        await _leaveService.rejectLeave(leaveId);
        _showSnackBar('Leave rejected successfully.');
      }

      // Refresh the list
      _fetchPendingLeaves();
    } catch (e) {
      _showSnackBar('Failed to $action leave: $e', isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade700 : Colors.teal,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // --- UI Methods ---

  Widget _buildActionButton(
    String label,
    Color color,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      ),
    );
  }

  // --- New: Employee Photo Avatar Builder ---
  Widget _buildEmployeeAvatar(String? photoFileName) {
    if (photoFileName != null && photoFileName.isNotEmpty) {
      // Construct the full URL for the image
      final imageUrl = '$_photoBaseUrl$photoFileName';
      return CircleAvatar(
        radius: 20,
        backgroundColor: Colors.grey.shade300,
        backgroundImage: NetworkImage(imageUrl),
        // Handle image loading errors by showing a fallback background
        // onBackgroundImageError: (exception, stackTrace) {},
      );
    }
    // Fallback to default avatar if photo is null or empty
    return const CircleAvatar(
      radius: 20,
      backgroundColor: Colors.red,
      child: Icon(Icons.person, color: Colors.white, size: 24),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Dept Head Pending Leaves',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<Leave>>(
        future: _pendingLeavesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Could not load pending requests. Error: ${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.red.shade700, fontSize: 16),
                ),
              ),
            );
          }

          final pendingLeaves = snapshot.data ?? [];

          if (pendingLeaves.isEmpty) {
            return const Center(
              child: Text(
                'No pending leave requests from Department Heads.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12.0),
            itemCount: pendingLeaves.length,
            itemBuilder: (context, index) {
              final leave = pendingLeaves[index];
              final employee = Employee.fromDynamic(leave.employee);

              //department/designation names
              final departmentName =
                  (employee.department is Map<String, dynamic>)
                  ? employee.department['name'] ?? 'N/A'
                  : 'N/A';
              final designationName =
                  (employee.designation is Map<String, dynamic>)
                  ? employee.designation['name'] ?? 'N/A'
                  : 'N/A';

              return Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildEmployeeAvatar(employee.photo),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  employee.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '$designationName in $departmentName',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black54,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Requested on: ${leave.requestedDate}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 20, thickness: 1),
                      Text(
                        'Reason: ${leave.reason}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Dates: ${leave.startDate} to ${leave.endDate}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Total Days: ${leave.totalLeaveDays}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // --- Action Buttons ---
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          _buildActionButton(
                            'Reject',
                            Colors.grey,
                            Icons.close,
                            () => _handleLeaveAction(leave.id!, 'REJECT'),
                          ),
                          const SizedBox(width: 12),
                          _buildActionButton(
                            'Approve',
                            Colors.green.shade600,
                            Icons.check,
                            () => _handleLeaveAction(leave.id!, 'APPROVE'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
