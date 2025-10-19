// lib/pages/salary/salary_list_page.dart

import 'package:flutter/material.dart';
import 'package:hr_management/entity/salary.dart';
import 'package:hr_management/pages/salary/salary_details.dart';
import 'package:hr_management/service/salary_service.dart';

class SalaryListPage extends StatefulWidget {
  const SalaryListPage({super.key});

  @override
  State<SalaryListPage> createState() => _SalaryListPageState();
}

class _SalaryListPageState extends State<SalaryListPage> {
  final SalaryService _salaryService = SalaryService();

  // ⭐️ STATE: Tracks the entire list fetch
  late Future<List<Salary>> _futureSalaries;

  // ⭐️ FILTER STATE: Null for 'ALL'
  int? _filterYear;
  int? _filterMonth;

  @override
  void initState() {
    super.initState();
    _futureSalaries = _fetchSalaries();
  }

  // --- Data Fetching Logic (SIMPLIFIED) ---

  Future<List<Salary>> _fetchSalaries() async {
    // ⭐️ CALLS THE NON-PAGINATED SERVICE METHOD
    return _salaryService.fetchFullSalaries(
      year: _filterYear,
      month: _filterMonth,
    );
  }

  // --- Helper: Reset and Refetch (Used by refresh and filter change) ---
  void _resetAndRefetch() {
    setState(() {
      // Assigns a new future to trigger FutureBuilder refresh
      _futureSalaries = _fetchSalaries();
    });
  }

  // ⭐️ Filter Dropdown Widget (REUSED LOGIC)
  Widget _buildFilterDropdown() {
    final now = DateTime.now();
    final List<Map<String, int?>> filterOptions = [
      {'year': null, 'month': null}, // Option 1: ALL
    ];
    // Add options for the last 6 months (example)
    for (int i = 0; i < 6; i++) {
      int year = now.year;
      int month = now.month - i;
      while (month <= 0) {
        month += 12;
        year--;
      }
      filterOptions.add({'year': year, 'month': month});
    }

    String _getDisplayText(Map<String, int?> option) {
      if (option['year'] == null) return 'All Months';
      final date = DateTime(option['year']!, option['month']!);
      return '${date.year}-${date.month.toString().padLeft(2, '0')}';
    }

    final currentSelectedValue = _filterYear != null
        ? '${_filterYear}-${_filterMonth.toString().padLeft(2, '0')}'
        : 'All';

    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: currentSelectedValue,
        icon: const Icon(Icons.filter_list, color: Colors.white),
        dropdownColor: Theme.of(context).primaryColor,
        style: const TextStyle(color: Colors.white),
        items: filterOptions.map((option) {
          final displayValue = _getDisplayText(option);
          final selectValue = option['year'] != null
              ? '${option['year']}-${option['month'].toString().padLeft(2, '0')}'
              : 'All';

          return DropdownMenuItem(
            value: selectValue,
            child: Text(displayValue, style: const TextStyle(color: Colors.white)),
          );
        }).toList(),
        onChanged: (String? newValue) {
          if (newValue != currentSelectedValue) { // Only update if value changes
            if (newValue == 'All') {
              _filterYear = null;
              _filterMonth = null;
            } else if (newValue != null) {
              final parts = newValue.split('-');
              _filterYear = int.parse(parts[0]);
              _filterMonth = int.parse(parts[1]);
            }
            _resetAndRefetch(); // Trigger the refetch with the new filter
          }
        },
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee Salaries'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: _buildFilterDropdown(),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetAndRefetch,
          ),
        ],
      ),
      // ⭐️ BODY: Uses FutureBuilder since we fetch the full list
      body: FutureBuilder<List<Salary>>(
        future: _futureSalaries,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('No salaries found for this selection.'),
                  TextButton(
                    onPressed: _resetAndRefetch,
                    child: const Text('Clear Filter / Retry'),
                  )
                ],
              ),
            );
          }

          final salaries = snapshot.data!;

          return ListView.builder(
            itemCount: salaries.length,
            itemBuilder: (context, index) {
              final salary = salaries[index];
              final employeeName = salary.employee.name;

              return ListTile(
                title: Text('$employeeName - Pay Month: ${salary.month.substring(0, 7)}'),
                subtitle: Text('Net Pay: ৳${salary.netPay.toStringAsFixed(2)}'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => SalaryDetailScreen(salary: salary),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}