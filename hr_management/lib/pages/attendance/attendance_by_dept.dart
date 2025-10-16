import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hr_management/entity/AttendanceMonthlySummary.dart';
import 'package:hr_management/entity/attendance.dart';
import 'package:hr_management/entity/employee.dart';
import 'package:hr_management/service/attendance_service.dart';
import 'package:hr_management/service/employee_service.dart';

const double _kBreakpoint = 600.0;

class AttendanceByDept extends StatefulWidget {
  const AttendanceByDept({super.key});

  @override
  State<AttendanceByDept> createState() =>
      _AttendanceByDeptState();
}

class _AttendanceByDeptState
    extends State<AttendanceByDept> {
  final AttendanceService _attendanceService = AttendanceService();
  final EmployeeService _employeeService = EmployeeService();

  // Futures will be initialized after the employee map is loaded
  Future<List<Attendance>>? _futureTodayLog;
  Future<List<AttendanceMonthlySummary>>? _futureMonthlySummary;
  Map<int, String> _employeeMap = {};

  final DateTime _now = DateTime.now();
  late final String _currentMonthYear;
  late final int _currentYear;
  late final int _currentMonth;

  @override
  void initState() {
    super.initState();
    _currentYear = _now.year;
    _currentMonth = _now.month;
    _currentMonthYear = '${_now.month}/${_now.year}';

    _initializeData();
  }
  void _initializeData() async {
    // 1. Fetch the necessary employee ID -> Name LIST first
    final List<Employee> employees = await _employeeService.getEmployeesByDept();

    // 2. Convert the list into the required Map<int, String>
    final Map<int, String> map = {
      for (var emp in employees) emp.id: emp.name
    };

    // 3. Set state and initialize futures
    setState(() {
      _employeeMap = map;
      _futureTodayLog = _attendanceService.getDepartmentTodayLog();
      _futureMonthlySummary = _attendanceService.getDepartmentMonthlySummary(
        _currentYear,
        _currentMonth,
      );
    });
  }

  String _getEmpName(int empId) {
    return _employeeMap[empId] ?? 'N/A (ID: $empId)';
  }

  // --- Helper Widgets ---

  Widget _buildLogStatus(bool? absent) {
    String text = absent == true ? 'Absent' : absent == false ? 'Present' : 'N/A';
    Color color = absent == true ? Colors.red : absent == false ? Colors.green : Colors.grey;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }

  // --- 1. Today's Log Section Builder ---

  Widget _buildTodayLog(List<Attendance> logs, double width) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Today’s Log',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const Divider(),
            if (logs.isEmpty)
              const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Text('No attendance logs recorded for today.'),
                  ))
            else if (width > _kBreakpoint)
              _buildTodayLogDataTable(logs)
            else
              _buildTodayLogListView(logs),
          ],
        ),
      ),
    );
  }

  Widget _buildTodayLogDataTable(List<Attendance> logs) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 24,
        columns: const [
          DataColumn(label: Text('Employee Name')),
          DataColumn(label: Text('Check-in')),
          DataColumn(label: Text('Check-out')),
          DataColumn(label: Text('Status')),
        ],
        rows: logs
            .map(
              (log) => DataRow(
            cells: [
              DataCell(Text(_getEmpName(log.empId))),
              DataCell(Text(log.checkIn ?? 'Not yet')),
              DataCell(Text(log.checkOut ?? 'Not yet')),
              DataCell(_buildLogStatus(log.absent)),
            ],
          ),
        )
            .toList(),
      ),
    );
  }

  Widget _buildTodayLogListView(List<Attendance> logs) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: logs.length,
      itemBuilder: (context, index) {
        final log = logs[index];
        return ListTile(
          leading: const Icon(Icons.person, color: Colors.blueGrey),
          title: Text(_getEmpName(log.empId), style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Check-in: ${log.checkIn ?? 'Not yet'}'),
              Text('Check-out: ${log.checkOut ?? 'Not yet'}'),
            ],
          ),
          trailing: _buildLogStatus(log.absent),
        );
      },
    );
  }

  // --- 2. Monthly Summary Section Builder ---

  Widget _buildMonthlySummary(List<AttendanceMonthlySummary> summaries, double width) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Monthly Summary ($_currentMonthYear)',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const Divider(),
            if (summaries.isEmpty)
              const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Text('No monthly summary data available.'),
                  ))
            else if (width > _kBreakpoint)
              _buildMonthlySummaryDataTable(summaries)
            else
              _buildMonthlySummaryListView(summaries),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlySummaryDataTable(List<AttendanceMonthlySummary> summaries) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 24,
        columns: const [
          DataColumn(label: Text('Employee Name')),
          DataColumn(label: Text('Total Days')),
          DataColumn(label: Text('Presents')),
          DataColumn(label: Text('Absents')),
          DataColumn(label: Text('Lates')),
          DataColumn(label: Text('OT Hours')),
        ],
        rows: summaries
            .map(
              (summary) => DataRow(
            cells: [
              DataCell(Text(_getEmpName(summary.empId))),
              DataCell(Text('${summary.totalDays}')),
              DataCell(Text('${summary.presents}', style: const TextStyle(color: Colors.green))),
              DataCell(Text('${summary.absents}', style: const TextStyle(color: Colors.red))),
              DataCell(Text('${summary.lates}', style: const TextStyle(color: Colors.orange))),
              // Since totalOvertimeHours is an int, display it directly
              DataCell(Text('${summary.totalOvertimeHours}')),
            ],
          ),
        )
            .toList(),
      ),
    );
  }

  Widget _buildMonthlySummaryListView(List<AttendanceMonthlySummary> summaries) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: summaries.length,
      itemBuilder: (context, index) {
        final summary = summaries[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 8),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getEmpName(summary.empId),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const Divider(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSummaryStat('Days', summary.totalDays, Colors.grey),
                    _buildSummaryStat('Presents', summary.presents, Colors.green),
                    _buildSummaryStat('Absents', summary.absents, Colors.red),
                    _buildSummaryStat('Lates', summary.lates, Colors.orange),
                    _buildSummaryStat('OT Hrs', summary.totalOvertimeHours, Colors.blue),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummaryStat(String label, dynamic value, Color color) {
    return Column(
      children: [
        Text(
          '$value',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }

  // --- Main Build Method ---

  @override
  Widget build(BuildContext context) {
    // Show loading spinner until the employee map is loaded
    if (_employeeMap.isEmpty || _futureTodayLog == null || _futureMonthlySummary == null) {
      return const Scaffold(
        appBar: CupertinoAppBar(title: Text('Department Attendance Dashboard')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Department Attendance Dashboard'),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;

          return SingleChildScrollView(
            child: Column(
              children: [
                // Today's Log Section
                FutureBuilder<List<Attendance>>(
                  future: _futureTodayLog,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(50.0),
                            child: CircularProgressIndicator(),
                          ));
                    }
                    if (snapshot.hasError) {
                      return Center(
                          child: Text('Error loading today\'s log: ${snapshot.error}'));
                    }
                    final logs = snapshot.data ?? [];
                    return _buildTodayLog(logs, width);
                  },
                ),

                // Monthly Summary Section
                FutureBuilder<List<AttendanceMonthlySummary>>(
                  future: _futureMonthlySummary,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(50.0),
                            child: CircularProgressIndicator(),
                          ));
                    }
                    if (snapshot.hasError) {
                      return Center(
                          child: Text(
                              'Error loading monthly summary: ${snapshot.error}'));
                    }
                    final summaries = snapshot.data ?? [];
                    return _buildMonthlySummary(summaries, width);
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// Simple AppBar replacement for use in the loading state
class CupertinoAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget title;
  const CupertinoAppBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: title,
      backgroundColor: Colors.blue.shade800,
      foregroundColor: Colors.white,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}