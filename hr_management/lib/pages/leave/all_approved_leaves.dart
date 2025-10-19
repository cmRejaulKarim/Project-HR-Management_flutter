import 'package:flutter/material.dart';
import 'package:hr_management/entity/leave.dart';
import 'package:hr_management/service/leave_service.dart';

// NOTE: Minimal Employee model for UI compilation (replace with your actual entity/employee.dart)
class Employee {
  final String name;
  Employee({required this.name});

  // Method to safely map the dynamic employee data from the Leave model
  factory Employee.fromDynamic(dynamic data) {
    if (data is Map<String, dynamic> && data.containsKey('name')) {
      return Employee(name: data['name'] as String);
    }
    return Employee(name: 'Unknown Employee'); // Fallback
  }
}

class ApprovedLeavesPage extends StatefulWidget {
  const ApprovedLeavesPage({super.key});

  @override
  State<ApprovedLeavesPage> createState() => _ApprovedLeavesPageState();
}

class _ApprovedLeavesPageState extends State<ApprovedLeavesPage> {
  late final LeaveService _leaveService = LeaveService();
  late Future<List<Leave>> _allApprovedLeavesFuture;

  // State for filtering
  List<Leave> _allLeaves = [];
  // Initialize to 'All Months' so it explicitly shows all data by default.
  String? _selectedMonth = 'All Months';

  // List of all 12 months for the dropdown
  final List<String> _months = [
    'All Months',
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  @override
  void initState() {
    super.initState();
    // Fetch all approved leaves only once
    _allApprovedLeavesFuture = _leaveService.getLeavesByStatus('APPROVED');
  }

  // Client-side filtering logic
  List<Leave> _getFilteredLeaves() {
    // Check for 'All Months' explicitly
    if (_selectedMonth == 'All Months' || _selectedMonth == null) {
      return _allLeaves;
    }

    // Get the 1-based index of the selected month
    final monthIndex = _months.indexOf(_selectedMonth!);

    return _allLeaves.where((leave) {
      try {
        // Parse the start date. Assumes startDate is in a parsable format (like YYYY-MM-DD)
        final startDate = DateTime.parse(leave.startDate);
        // Compare the month part of the date with the selected month index
        return startDate.month == monthIndex;
      } catch (e) {
        // Handle potential date parsing errors (e.g., if startDate is malformed)
        return false;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    // Determine the list to display based on filtering
    final filteredLeaves = _getFilteredLeaves();

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Approved Leaves', style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // --- Month Filter Dropdown ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Filter by Month',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                prefixIcon: const Icon(Icons.calendar_today, color: Colors.teal),
              ),
              // Use _selectedMonth as the value, which defaults to 'All Months'
              value: _selectedMonth,
              items: _months.map((String month) {
                return DropdownMenuItem<String>(
                  value: month,
                  child: Text(month),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedMonth = newValue;
                });
              },
            ),
          ),

          // --- Leaves List ---
          Expanded(
            child: FutureBuilder<List<Leave>>(
              future: _allApprovedLeavesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Could not load approved leaves. Error: ${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.red.shade700),
                      ),
                    ),
                  );
                }

                // FIX: Use a dedicated variable to track if initial data is set.
                // We set _allLeaves and force a rebuild only the first time data arrives.
                if (snapshot.hasData && _allLeaves.isEmpty) {
                  // Use a local variable to capture the state change
                  bool shouldSetState = false;
                  if (snapshot.data!.isNotEmpty) {
                    _allLeaves = snapshot.data!;
                    shouldSetState = true;
                  }

                  // Force a rebuild only if we actually set data for the first time
                  // This is crucial for the _getFilteredLeaves() method to run with the data.
                  if (shouldSetState) {
                    // Using addPostFrameCallback is often safer inside a build method
                    // when you need to trigger a state change immediately after the current frame.
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) {
                        setState(() {});
                      }
                    });
                  }

                  // Return the CircularProgressIndicator one last time
                  // while we wait for the subsequent rebuild to show the data.
                  // If the list is empty, continue to the empty state check below.
                  if (_allLeaves.isEmpty) {
                    // Fall through to the empty check
                  } else {
                    // Return a placeholder while the frame callback triggers the rebuild
                    return const Center(child: CircularProgressIndicator());
                  }
                }

                // Now use the filtered list for display
                if (filteredLeaves.isEmpty) {
                  // Show a message if filtering results in an empty list, or if the initial fetch was empty
                  final message = _selectedMonth == 'All Months'
                      ? 'No approved leaves found.'
                      : 'No approved leaves found for ${_selectedMonth}.';
                  return Center(child: Text(message));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12.0),
                  itemCount: filteredLeaves.length,
                  itemBuilder: (context, index) {
                    final leave = filteredLeaves[index];
                    // Safely extract employee data from the dynamic field
                    final employee = Employee.fromDynamic(leave.employee);

                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      child: ListTile(
                        leading: const Icon(Icons.check_circle, color: Colors.teal, size: 30),
                        title: Text(
                          employee.name, // Use the extracted employee name
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        subtitle: Text(
                          'Reason: ${leave.reason}\nDates: ${leave.startDate} to ${leave.endDate} (${leave.totalLeaveDays} days)',
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                        onTap: () {
                          // Navigate to a detailed view for this approved leave
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
