import 'package:flutter/material.dart';
import 'package:hr_management/entity/department.dart';
import 'package:hr_management/entity/designation.dart';

// Assuming these imports resolve to your defined model classes
import 'package:hr_management/entity/employee.dart';
import 'package:hr_management/entity/advance.dart';
import 'package:hr_management/entity/attendance.dart';
import 'package:hr_management/entity/leave.dart';

// Assuming these imports resolve to your defined service classes
import 'package:hr_management/service/auth_service.dart';
import 'package:hr_management/service/department_service.dart';
import 'package:hr_management/service/designation_service.dart';
import 'package:hr_management/service/employee_service.dart';
import 'package:hr_management/service/attendance_service.dart';
import 'package:hr_management/service/leave_service.dart';
import 'package:hr_management/service/advance_service.dart';

class EmployeeDashboard extends StatefulWidget {
  // Required: The profile passed from the login page
  final Employee profile;

  const EmployeeDashboard({Key? key, required this.profile}) : super(key: key);

  final String imageurl = "http://localhost:8085/images/employee/";

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
  final DepartmentService _departmentService = DepartmentService();
  final DesignationService _designationService = DesignationService();

  // --- State Variables ---
  bool _isLoading = true;
  Attendance? _todayAttendance;
  List<Leave> _userLeaves = [];
  List<AdvanceSalary> _userAdvances = [];
  String _departmentName = 'N/A';
  String _designationName = 'N/A';

  // Forms Controllers
  final TextEditingController _advanceAmountController =
      TextEditingController();
  final TextEditingController _advanceReasonController =
      TextEditingController();
  final GlobalKey<FormState> _advanceFormKey = GlobalKey<FormState>();

  // for leave form (controllers are still needed for the dialog state)
  DateTime? _leaveStartDate;
  DateTime? _leaveEndDate;
  int _totalLeaveDays = 0;
  final TextEditingController _leaveReasonController = TextEditingController();
  final GlobalKey<FormState> _leaveFormKey = GlobalKey<FormState>();

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
      debugPrint('Loading attendance...');
      final attendance = await _attendanceService.getTodayLog();

      debugPrint('Loading leaves...');
      final leaves = await _leaveService.getCurrentMonthLeaveByUser();

      debugPrint('Loading advances...');
      final advances = await _advanceService.viewAdvanceRequestsByEmp();

      if (widget.profile.department != null) {
        final allDepts = await _departmentService.getAllDepartments();
        final dept = allDepts?.firstWhere(
          (d) => d.id == widget.profile.department,
          orElse: () => Department(id: -1, name: 'Unknown Department'),
        );
        _departmentName = dept?.name ?? 'N/A';

        // Fetch designations for the specific department to get the name
        if (widget.profile.designation != null) {
          final desgs = await _designationService.getAllDesignations();
          final desg = desgs!.firstWhere(
            (d) => d.id == widget.profile.designation,
            orElse: () => Designation(id: -1, name: 'Unknown Designation'),
          );
          _designationName = desg.name;
        }
      }

      setState(() {
        _todayAttendance = attendance;
        _userLeaves = leaves;
        _userAdvances = advances;
      });
    } catch (e) {
      debugPrint('Error loading dashboard data: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // --- Advance Form Eligibility Logic ---
  bool get _canRequestAdvanceThisMonth {
    final now = DateTime.now();
    // Check if any advance request exists for the current month and year
    return !_userAdvances.any((advance) {
      try {
        final requestDate = DateTime.parse(advance.requestDate);
        return requestDate.year == now.year && requestDate.month == now.month;
      } catch (_) {
        return false;
      }
    });
  }

  // --- Advance Form Submission (Called from Dialog) ---
  Future<void> _submitAdvanceRequest() async {
    if (!_advanceFormKey.currentState!.validate()) return;

    final amount = double.tryParse(_advanceAmountController.text);
    final reason = _advanceReasonController.text.trim();

    if (amount == null || amount <= 0) {
      _showSnackBar('Please enter a valid amount.');
      return;
    }

    try {
      final success = await _advanceService.addAdvanceRequest(
        amount,
        reason,
      );

      if (success != null) {
        // Dismiss dialog
        if (mounted) Navigator.of(context).pop();

        _showSnackBar('Advance request submitted successfully!');
        _advanceAmountController.clear();
        _advanceReasonController.clear();
        await _loadDashboardData();
      } else {
        _showSnackBar('Failed to submit advance request. Please try again.');
      }
    } catch (e) {
      _showSnackBar('An error occurred during submission: $e');
    }
  }

  // --- Leave Logic (Called from Dialog) ---

  void _calculateTotalLeaveDays() {
    // Force a re-render of the dialog content to update the days count
    if (_leaveStartDate != null && _leaveEndDate != null) {
      if (_leaveEndDate!.isAfter(_leaveStartDate!) ||
          _leaveEndDate!.isAtSameMomentAs(_leaveStartDate!)) {
        setState(() {
          _totalLeaveDays =
              _leaveEndDate!.difference(_leaveStartDate!).inDays + 1;
        });
      } else {
        setState(() {
          _totalLeaveDays = 0;
        });
      }
    }
  }

  Future<void> _submitLeaveRequest() async {
    if (!_leaveFormKey.currentState!.validate()) return;

    if (_leaveStartDate == null ||
        _leaveEndDate == null ||
        _totalLeaveDays <= 0) {
      _showSnackBar("Please select valid leave dates.");
      return;
    }

    final leave = Leave(
      employee: widget.profile.id,
      startDate: _leaveStartDate!.toIso8601String().split('T')[0],
      endDate: _leaveEndDate!.toIso8601String().split('T')[0],
      totalLeaveDays: _totalLeaveDays,
      reason: _leaveReasonController.text,
      requestedDate: DateTime.now().toIso8601String().split('T')[0],
      status: 'PENDING',
    );

    try {
      await _leaveService.applyLeave(leave);

      // Dismiss dialog
      if (mounted) Navigator.of(context).pop();

      _showSnackBar("Leave request submitted.");
      // Reset local state after successful submission
      _leaveStartDate = null;
      _leaveEndDate = null;
      _totalLeaveDays = 0;
      _leaveReasonController.clear();

      await _loadDashboardData(); // reload list
    } catch (e) {
      _showSnackBar("Error submitting leave: $e");
    }
  }

  // --- Utility Widgets and Functions ---

  String? get photoUrl {
    final photo = widget.profile.photo;
    if (photo != null && photo.isNotEmpty) {
      return 'http://localhost:8085/images/employee/$photo';
    }
    return null;
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
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

  // --- Core UI Widgets ---

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
                backgroundImage: photoUrl != null
                    ? NetworkImage(photoUrl!)
                    : null,
                child: photoUrl == null
                    ? const Icon(Icons.person, size: 40)
                    : null,
              ),
            ),
            const SizedBox(height: 15),
            Center(
              child: Text(
                widget.profile.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Center(
              child: Text(
                widget.profile.email,
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            ),
            const Divider(height: 30),
            _profileRow(Icons.call, 'Phone', widget.profile.phone ?? 'N/A'),
            _profileRow(
              Icons.calendar_today,
              'DOB',
              widget.profile.dateOfBirth ?? 'N/A',
            ),
            _profileRow(
              Icons.work,
              'Department', // Changed label
              _departmentName, // Use the fetched name
            ),
            _profileRow(
              Icons.star,
              'Designation', // Changed label
              _designationName, // Use the fetched name
            ),
            _profileRow(
              Icons.calendar_month,
              'Joining Date',
              widget.profile.joiningDate ?? 'N/A',
            ),
          ],
        ),
      ),
    );
  }

  // Attendance Card

  Widget _buildStyledAttendanceRow(
    IconData icon,
    String label,
    String value, {
    TextStyle? statusStyle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.purple),
          const SizedBox(width: 10),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
            child: RichText(
              text: TextSpan(
                text: value,
                style: TextStyle(color: Colors.black, fontSize: 14),
                // Default style
                children: [
                  if (statusStyle != null)
                    TextSpan(
                      text: value.contains('(Late)')
                          ? ' (Late)'
                          : (value.contains('Absent') ? ' Absent' : ''),
                      style: statusStyle,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceCard() {
    // Determine status strings
    final bool isLate = (_todayAttendance?.lateCount ?? 0) > 0;
    final bool isAbsent = _todayAttendance?.absent == true;

    // Base values
    final String checkInTime = _todayAttendance?.checkIn ?? 'N/A';
    final String checkOutTime = _todayAttendance?.checkOut ?? 'N/A';

    // Define colored text styles
    const TextStyle lateStyle = TextStyle(
      color: Colors.red,
      fontWeight: FontWeight.bold,
    );
    const TextStyle absentStyle = TextStyle(
      color: Colors.red,
      fontWeight: FontWeight.bold,
    );
    const TextStyle normalValueStyle = TextStyle(
      color: Colors.black,
      fontSize: 14,
    );

    // Attendance Card - Non-Collapsible
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.timer, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'Today\'s Attendance',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ],
            ),
            const Divider(),
            _isLoading
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10.0),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : Column(
                    children: [
                      // --- Check-In (with colored Late status) ---
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.login,
                              size: 20,
                              color: Colors.purple,
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'Check-In: ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  text: checkInTime,
                                  style: normalValueStyle,
                                  children: [
                                    if (isLate)
                                      const TextSpan(
                                        text: ' (Late)',
                                        style: lateStyle,
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // --- Check-Out (with colored Absent status) ---
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.logout,
                              size: 20,
                              color: Colors.purple,
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'Check-Out: ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  text: checkOutTime,
                                  style: normalValueStyle,
                                  children: [
                                    if (isAbsent)
                                      const TextSpan(
                                        text: '  Absent',
                                        style: absentStyle,
                                      )
                                    else if (checkOutTime == 'N/A')
                                      TextSpan(
                                        text: ' (Pending)',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      _profileRow(
                        Icons.timer_10,
                        'Total Working Time',
                        _todayAttendance?.totalWorkingTime != null
                            ? '${_todayAttendance!.totalWorkingTime!.toStringAsFixed(2)} hrs'
                            : 'N/A',
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaveHistory() {
    // Leave History - Non-Collapsible Card (CHANGE)
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 8),
            child: Row(
              children: [
                Icon(Icons.date_range, color: Colors.green),
                SizedBox(width: 8),
                Text(
                  'Leave History',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ],
            ),
          ),
          const Divider(height: 0),
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
                  itemCount: _userLeaves.length > 5 ? 5 : _userLeaves.length,
                  // Show top 5
                  itemBuilder: (context, index) {
                    final leave = _userLeaves[index];
                    Color statusColor = leave.status == 'APPROVED'
                        ? Colors.green
                        : (leave.status == 'REJECTED'
                              ? Colors.red
                              : Colors.orange);

                    return ListTile(
                      title: Text(
                        '${leave.startDate} to ${leave.endDate} (${leave.totalLeaveDays} days)',
                      ),
                      subtitle: Text(leave.reason),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          leave.status,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    );
                  },
                ),
          if (_userLeaves.length > 5)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: TextButton(
                onPressed: () {
                  _showSnackBar(
                    'Showing all ${(_userLeaves.length)} leave requests...',
                  );
                },
                child: const Text('View All Leaves'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAdvanceRequestsHistory() {
    // Advance Requests History - Non-Collapsible Card (CHANGE)
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 8),
            child: Row(
              children: [
                Icon(Icons.money, color: Colors.orange),
                SizedBox(width: 8),
                Text(
                  'Advance Salary Requests History',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ],
            ),
          ),
          const Divider(height: 0),
          _isLoading
              ? const Center(child: LinearProgressIndicator())
              : _userAdvances.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('No advance request found for this month.'),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _showAdvanceRequestDialog,
                          icon: const Icon(Icons.add, color: Colors.black),
                          label: const Text(
                            "Request Advance Salary",
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            elevation: 2,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _userAdvances.length,
                  itemBuilder: (context, index) {
                    final advance = _userAdvances[index];
                    Color statusColor = advance.status == 'APPROVED'
                        ? Colors.green
                        : (advance.status == 'REJECTED'
                              ? Colors.red
                              : Colors.orange);

                    return ListTile(
                      leading: Icon(Icons.attach_money, color: statusColor),
                      title: Text('৳${advance.amount.toStringAsFixed(2)}'),
                      subtitle: Text(
                        'Requested: ${advance.requestDate}\nReason: ${advance.reason ?? 'N/A'}',
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          advance.status,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }

  // --- Dialog Forms ---

  Widget _buildLeaveRequestFormDialog(StateSetter dialogSetState) {
    return SingleChildScrollView(
      child: AlertDialog(
        title: const Text("Request Leave"),
        content: Form(
          key: _leaveFormKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // From Date
              const Text("From Date"),
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _leaveStartDate ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    dialogSetState(() {
                      _leaveStartDate = picked;
                      // Call main state method to update total days
                      _calculateTotalLeaveDays();
                    });
                  }
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    _leaveStartDate != null
                        ? _leaveStartDate!.toLocal().toString().split(' ')[0]
                        : 'Select date',
                  ),
                ),
              ),
              const SizedBox(height: 15),

              // To Date
              const Text("To Date"),
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _leaveEndDate ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    dialogSetState(() {
                      _leaveEndDate = picked;
                      // Call main state method to update total days
                      _calculateTotalLeaveDays();
                    });
                  }
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    _leaveEndDate != null
                        ? _leaveEndDate!.toLocal().toString().split(' ')[0]
                        : 'Select date',
                  ),
                ),
              ),
              const SizedBox(height: 15),

              // Total Leave Days - Use the main state's value
              TextFormField(
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Total Leave Days',
                  border: OutlineInputBorder(),
                ),
                initialValue: _totalLeaveDays.toString(),
                key: ValueKey('LeaveDays$_totalLeaveDays'), // Key for rebuild
              ),
              const SizedBox(height: 15),

              // Reason
              TextFormField(
                controller: _leaveReasonController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Reason',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'Please enter a reason.'
                    : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Reset local state variables before closing
              setState(() {
                _leaveStartDate = null;
                _leaveEndDate = null;
                _totalLeaveDays = 0;
                _leaveReasonController.clear();
              });
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _submitLeaveRequest,
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  void _showLeaveRequestDialog() {
    // Reset form state before opening dialog
    _leaveStartDate = null;
    _leaveEndDate = null;
    _totalLeaveDays = 0;
    _leaveReasonController.clear();
    _leaveFormKey.currentState?.reset();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        // Use a StatefulBuilder to allow the dialog content (dates/days) to update
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter dialogSetState) {
            return _buildLeaveRequestFormDialog(dialogSetState);
          },
        );
      },
    );
  }

  void _showAdvanceRequestDialog() {
    // Reset form state before opening dialog
    _advanceAmountController.clear();
    _advanceReasonController.clear();
    _advanceFormKey.currentState?.reset();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        // Check eligibility right before building the dialog content
        if (!_canRequestAdvanceThisMonth) {
          return AlertDialog(
            title: const Text('Advance Request Not Allowed'),
            content: const Text(
              'You have already submitted an advance request this month. Please wait for the next month.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          );
        }

        // If eligible, show the form
        return SingleChildScrollView(
          child: AlertDialog(
            title: const Text("Request New Advance Salary"),
            content: Form(
              key: _advanceFormKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _advanceAmountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Amount (৳)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.payments),
                    ),
                    validator: (value) {
                      if (value == null ||
                          double.tryParse(value) == null ||
                          double.parse(value) <= 0) {
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
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: _submitAdvanceRequest,
                child: const Text('Submit Request'),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- Main Build Method ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee\'s Status'),
        backgroundColor: Colors.purple,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed:
                _loadDashboardData, // Call the existing data fetching method
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _authService.logout();
              Navigator.of(
                context,
              ).pushNamedAndRemoveUntil('/login', (route) => false);
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
                  _buildLeaveHistory(), // Non-Collapsible History
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: ElevatedButton.icon(
                      onPressed: _showLeaveRequestDialog, // Trigger Dialog
                      icon: const Icon(Icons.add),
                      label: const Text("Request Leave"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                    ),
                  ),
                  _buildAdvanceRequestsHistory(), // Non-Collapsible History
                ],
              ),
            ),
    );
  }
}
