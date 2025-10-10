import 'package:flutter/material.dart';
// Assuming these imports resolve to your defined model classes
import 'package:hr_management/entity/employee.dart';
import 'package:hr_management/entity/advance.dart';
import 'package:hr_management/entity/attendance.dart';
import 'package:hr_management/entity/leave.dart';

// Assuming these imports resolve to your defined service classes
import 'package:hr_management/service/authservice.dart';
import 'package:hr_management/service/employee_service.dart';
import 'package:hr_management/service/attendance_service.dart';
import 'package:hr_management/service/leave_service.dart';
import 'package:hr_management/service/advance_service.dart';

class EmployeeDashboard extends StatefulWidget {
  // Required: The profile passed from the login page
  final Employee profile;

  const EmployeeDashboard({Key? key, required this.profile}) : super(key: key);

  @override
  State<EmployeeDashboard> createState() => _EmployeeDashboardState();
}

class _EmployeeDashboardState extends State<EmployeeDashboard> {
  // --- Service Instances ---
  final AuthService _authService = AuthService();
  final EmployeeService _employeeService = EmployeeService();
  final AttendanceService _attendanceService = AttendanceService();
  final LeaveService _leaveService = LeaveService();
  final AdvanceService _advanceService = AdvanceService();

  // --- State Variables ---
  bool _isLoading = true;
  Attendance? _todayAttendance;
  List<Leave> _userLeaves = [];
  List<AdvanceSalary> _userAdvances = [];

  // Forms Controllers
  final TextEditingController _advanceAmountController = TextEditingController();
  final TextEditingController _advanceReasonController = TextEditingController();
  final GlobalKey<FormState> _advanceFormKey = GlobalKey<FormState>();

  // Collapsible State (for simple toggling)
  bool _isLeaveExpanded = true;
  bool _isAdvanceExpanded = true;


  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  // --- Data Loading Logic ---
  Future<void> _loadDashboardData() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // 1. Fetch Today's Attendance
      final attendance = await _attendanceService.getTodayLog();

      // 2. Fetch User's Leaves
      final leaves = await _leaveService.getLeaveByUser();

      // 3. Fetch Advance Salary Requests
      final advances = await _advanceService.getAdvanceRequests();

      setState(() {
        _todayAttendance = attendance;
        _userLeaves = leaves;
        _userAdvances = advances;
      });
    } catch (e) {
      // In a real app, show a snackbar or toast
      debugPrint('Error loading dashboard data: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // --- Advance Form Visibility Logic ---
  bool get _canRequestAdvanceThisMonth {
    final now = DateTime.now();
    // Check if any advance request exists for the current month and year
    return !_userAdvances.any((advance) {
      try {
        final requestDate = DateTime.parse(advance.requestDate);
        return requestDate.year == now.year && requestDate.month == now.month;
      } catch (_) {
        // Handle invalid date format by assuming it doesn't match
        return false;
      }
    });
  }

  // --- Advance Form Submission ---
  Future<void> _submitAdvanceRequest() async {
    if (!_advanceFormKey.currentState!.validate()) return;

    final amount = double.tryParse(_advanceAmountController.text);
    final reason = _advanceReasonController.text.trim();

    if (amount == null || amount <= 0) {
      _showSnackBar('Please enter a valid amount.');
      return;
    }

    try {
      final success = await _advanceService.submitAdvanceRequest(amount, reason);

      if (success) {
        _showSnackBar('Advance request submitted successfully!');
        _advanceAmountController.clear();
        _advanceReasonController.clear();
        // Reload data to update the advance request list and visibility
        await _loadDashboardData();
      } else {
        _showSnackBar('Failed to submit advance request. Please try again.');
      }
    } catch (e) {
      _showSnackBar('An error occurred during submission: $e');
    }
  }

  // --- Utility Widgets ---
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _buildProfileCard() {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 40,
                // Placeholder/fallback image
                backgroundImage: widget.profile.photo != null
                    ? NetworkImage(widget.profile.photo!)
                    : null,
                child: widget.profile.photo == null ? const Icon(Icons.person, size: 40) : null,
              ),
            ),
            const SizedBox(height: 15),
            Center(
              child: Text(
                widget.profile.name,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            Center(
              child: Text(
                widget.profile.email,
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            ),
            const Divider(height: 30),
            _profileRow(Icons.badge, 'Employee ID', widget.profile.id.toString()),
            _profileRow(Icons.call, 'Phone', widget.profile.phone ?? 'N/A'),
            _profileRow(Icons.calendar_today, 'DOB', widget.profile.dateOfBirth ?? 'N/A'),
            _profileRow(Icons.work, 'Department ID', widget.profile.departmentId?.toString() ?? 'N/A'),
            _profileRow(Icons.star, 'Designation ID', widget.profile.designationId?.toString() ?? 'N/A'),
            _profileRow(Icons.calendar_month, 'Joining Date', widget.profile.joiningDate ?? 'N/A'),
          ],
        ),
      ),
    );
  }

  Widget _profileRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.purple),
          const SizedBox(width: 10),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildAttendanceCard() {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ExpansionTile(
        initiallyExpanded: true,
        title: const Text('Today\'s Attendance', style: TextStyle(fontWeight: FontWeight.bold)),
        leading: const Icon(Icons.timer, color: Colors.blue),
        children: [
          _isLoading
              ? const Padding(
            padding: EdgeInsets.all(8.0),
            child: Center(child: CircularProgressIndicator()),
          )
              : Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _profileRow(Icons.login, 'Check-In', _todayAttendance?.checkIn ?? 'N/A'),
                _profileRow(Icons.logout, 'Check-Out', _todayAttendance?.checkOut ?? 'N/A'),
                _profileRow(Icons.timer_10, 'Total Working Time',
                    _todayAttendance?.totalWorkingTime != null
                        ? '${_todayAttendance!.totalWorkingTime!.toStringAsFixed(2)} hrs'
                        : 'N/A'
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaveHistory() {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ExpansionTile(
        title: const Text('Leave History', style: TextStyle(fontWeight: FontWeight.bold)),
        leading: const Icon(Icons.date_range, color: Colors.green),
        initiallyExpanded: _isLeaveExpanded,
        onExpansionChanged: (isExpanded) => setState(() => _isLeaveExpanded = isExpanded),
        children: [
          _isLoading
              ? const Center(child: LinearProgressIndicator())
              : _userLeaves.isEmpty
              ? const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('No leave requests found.'),
          )
              : ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _userLeaves.length > 5 ? 5 : _userLeaves.length, // Show top 5
            itemBuilder: (context, index) {
              final leave = _userLeaves[index];
              Color statusColor = leave.status == 'APPROVED' ? Colors.green : (leave.status == 'REJECTED' ? Colors.red : Colors.orange);

              return ListTile(
                title: Text('${leave.startDate} to ${leave.endDate} (${leave.totalLeaveDays} days)'),
                subtitle: Text(leave.reason),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    leave.status,
                    style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              );
            },
          ),
          if (_userLeaves.length > 5)
            TextButton(
              onPressed: () {
                // Navigate to full leave history page
                _showSnackBar('Showing all ${(_userLeaves.length)} leave requests...');
              },
              child: const Text('View All Leaves'),
            )
        ],
      ),
    );
  }

  Widget _buildAdvanceRequests() {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ExpansionTile(
        title: const Text('Advance Salary Requests', style: TextStyle(fontWeight: FontWeight.bold)),
        leading: const Icon(Icons.money, color: Colors.orange),
        initiallyExpanded: _isAdvanceExpanded,
        onExpansionChanged: (isExpanded) => setState(() => _isAdvanceExpanded = isExpanded),
        children: [
          _isLoading
              ? const Center(child: LinearProgressIndicator())
              : _userAdvances.isEmpty
              ? const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('No advance salary requests found.'),
          )
              : ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _userAdvances.length,
            itemBuilder: (context, index) {
              final advance = _userAdvances[index];
              Color statusColor = advance.status == 'APPROVED' ? Colors.green : (advance.status == 'REJECTED' ? Colors.red : Colors.orange);

              return ListTile(
                leading: Icon(Icons.attach_money, color: statusColor),
                title: Text('\$${advance.amount.toStringAsFixed(2)}'),
                subtitle: Text('Requested: ${advance.requestDate}\nReason: ${advance.reason ?? 'N/A'}'),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    advance.status,
                    style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAdvanceRequestForm() {
    if (!_canRequestAdvanceThisMonth) {
      return Card(
        color: Colors.lightBlue.shade50,
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: const ListTile(
          leading: Icon(Icons.info, color: Colors.blue),
          title: Text('Advance Request Status'),
          subtitle: Text('You have already submitted an advance request this month. Please wait for approval or the next month.'),
        ),
      );
    }

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ExpansionTile(
        title: const Text('Request New Advance Salary', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
        leading: const Icon(Icons.add_task, color: Colors.red),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _advanceFormKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _advanceAmountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Amount (\$)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.payments),
                    ),
                    validator: (value) {
                      if (value == null || double.tryParse(value) == null || double.parse(value) <= 0) {
                        return 'Please enter a valid amount.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: _advanceReasonController,
                    decoration: const InputDecoration(
                      labelText: 'Reason',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.edit_note),
                    ),
                    maxLines: 2,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please state the reason for the advance.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _submitAdvanceRequest,
                    icon: const Icon(Icons.send),
                    label: const Text('Submit Request'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Main Build Method ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee Dashboard'),
        backgroundColor: Colors.purple,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _authService.logout();
              Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildProfileCard(),
            _buildAttendanceCard(),
            _buildLeaveHistory(),
            _buildAdvanceRequests(),
            _buildAdvanceRequestForm(), // Visibility handled internally
          ],
        ),
      ),
    );
  }
}
