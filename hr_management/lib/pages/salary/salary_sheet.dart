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

  late Future<List<Salary>> _futureSalaries;
  int? _filterYear;
  int? _filterMonth;

  @override
  void initState() {
    super.initState();
    _futureSalaries = _fetchSalaries();
  }

  Future<List<Salary>> _fetchSalaries() async {
    return _salaryService.fetchFullSalaries(
      year: _filterYear,
      month: _filterMonth,
    );
  }

  void _resetAndRefetch() {
    setState(() {
      _futureSalaries = _fetchSalaries();
    });
  }

  // Filter Dropdown Widget
  Widget _buildFilterDropdown() {
    final now = DateTime.now();
    final List<Map<String, int?>> filterOptions = [
      {'year': null, 'month': null},
    ];
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
        icon: const Icon(Icons.filter_alt),
        // Use theme colors for better integration
        dropdownColor: Theme.of(context).cardColor,
        style: TextStyle(
          color: Theme.of(context).textTheme.bodyLarge?.color,
          fontSize: 16,
        ),

        items: filterOptions.map((option) {
          final displayValue = _getDisplayText(option);
          final selectValue = option['year'] != null
              ? '${option['year']}-${option['month'].toString().padLeft(2, '0')}'
              : 'All';

          return DropdownMenuItem(
            value: selectValue,
            child: Text(
              displayValue,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
          );
        }).toList(),
        onChanged: (String? newValue) {
          if (newValue != currentSelectedValue) {
            if (newValue == 'All') {
              _filterYear = null;
              _filterMonth = null;
            } else if (newValue != null) {
              final parts = newValue.split('-');
              _filterYear = int.parse(parts[0]);
              _filterMonth = int.parse(parts[1]);
            }
            _resetAndRefetch();
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
        // Ensure action icons are visible
        actionsIconTheme: const IconThemeData(color: Colors.greenAccent),

        actions: [
          // Filter Dropdown
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: _buildFilterDropdown(),
            ),
          ),

          // Refresh Button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetAndRefetch,
          ),
        ],
        backgroundColor: Theme.of(context).highlightColor,
      ),

      body: FutureBuilder<List<Salary>>(
        future: _futureSalaries,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Error fetching data: ${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'No salaries found for this selection.',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: _resetAndRefetch,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Clear Filter / Retry'),
                  ),
                ],
              ),
            );
          }

          final salaries = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: salaries.length,
            itemBuilder: (context, index) {
              final salary = salaries[index];
              final employeeName = salary.employee.name;

              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 6.0),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),

                  title: Text(
                    employeeName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),

                  subtitle: Text(
                    'Pay Period: ${salary.month.substring(0, 7)}',
                    style: const TextStyle(color: Colors.grey),
                  ),

                  trailing: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Net Pay',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        '৳${salary.netPay.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: Colors.green,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),

                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            SalaryDetailScreen(salary: salary),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
