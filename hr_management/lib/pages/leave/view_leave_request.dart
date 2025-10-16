import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../entity/leave.dart';
import '../../service/leave_service.dart';

class DepartmentLeaveViewPage extends StatefulWidget {
  const DepartmentLeaveViewPage({super.key});

  @override
  State<DepartmentLeaveViewPage> createState() => _DepartmentLeaveViewPageState();
}

class _DepartmentLeaveViewPageState extends State<DepartmentLeaveViewPage> {
  final LeaveService _leaveService = LeaveService();
  late Future<List<Leave>> _leavesFuture;

  @override
  void initState() {
    super.initState();
    // Fetch leaves for the department head's department
    _leavesFuture = _leaveService.getLeavesByDept();
  }

  // Function to refresh the list after an action
  void _refreshLeaves() {
    setState(() {
      _leavesFuture = _leaveService.getLeavesByDept();
    });
  }

  // Common function to approve or reject a leave request
  Future<void> _updateLeaveStatus(int leaveId, bool isApprove) async {
    try {
      if (isApprove) {
        await _leaveService.approveLeave(leaveId);
      } else {
        await _leaveService.rejectLeave(leaveId);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Leave request ${isApprove ? 'APPROVED' : 'REJECTED'} successfully!'),
            backgroundColor: isApprove ? Colors.green : Colors.red,
          ),
        );
        _refreshLeaves(); // Refresh the list
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update leave status: $e')),
        );
      }
    }
  }

  // Helper to color the status badge
  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return Colors.orange;
      case 'APPROVED':
        return Colors.green;
      case 'REJECTED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Department Leave Requests'),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshLeaves,
          ),
        ],
      ),
      body: FutureBuilder<List<Leave>>(
        future: _leavesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No leave requests found.'));
          }

          final leaves = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: leaves.length,
            itemBuilder: (context, index) {
              final leave = leaves[index];
              final employeeName = leave.employee != null && leave.employee is Map
                  ? (leave.employee['name'] ?? 'Unknown Employee')
                  : 'N/A';

              return Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            employeeName,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Chip(
                            label: Text(
                              leave.status,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                            backgroundColor: _getStatusColor(leave.status),
                          ),
                        ],
                      ),
                      const Divider(height: 10),
                      Text('Reason: ${leave.reason}'),
                      const SizedBox(height: 4),
                      Text('Duration: ${leave.totalLeaveDays} days'),
                      Text('From: ${leave.startDate} to ${leave.endDate}'),

                      // Action buttons for PENDING requests
                      if (leave.status.toUpperCase() == 'PENDING')
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton.icon(
                                icon: const Icon(Icons.close, color: Colors.red),
                                label: const Text('Reject', style: TextStyle(color: Colors.red)),
                                onPressed: () => _updateLeaveStatus(leave.id!, false),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton.icon(
                                icon: const Icon(Icons.check, color: Colors.white),
                                label: const Text('Approve', style: TextStyle(color: Colors.white)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                ),
                                onPressed: () => _updateLeaveStatus(leave.id!, true),
                              ),
                            ],
                          ),
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