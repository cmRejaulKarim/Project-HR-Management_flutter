import 'package:flutter/material.dart';
import 'package:hr_management/entity/advance.dart';
import 'package:hr_management/service/advance_service.dart';

class AdvanceRequestListPage extends StatefulWidget {
  const AdvanceRequestListPage({super.key});

  @override
  State<AdvanceRequestListPage> createState() => _AdvanceRequestListPageState();
}

class _AdvanceRequestListPageState extends State<AdvanceRequestListPage> {
  final AdvanceService _advanceService = AdvanceService();
  late Future<List<AdvanceSalary>> _futureAdvances;

  @override
  void initState() {
    super.initState();
    _futureAdvances = _fetchAdvances();
  }

  // Method to fetch and sort the advances
  Future<List<AdvanceSalary>> _fetchAdvances() async {
    final advances = await _advanceService.viewAllAdvanceRequests();

    // Sorting Logic: "view last is in top"
    // Since requestDate is a String (yyyy-MM-dd), standard String comparison works for sorting.
    advances.sort((a, b) => b.requestDate.compareTo(a.requestDate));
    // b.compareTo(a) ensures descending order (latest date first)

    return advances;
  }

  // --- Action Handlers ---

  Future<void> _handleAction(int id, bool isApprove) async {
    final actionText = isApprove ? "Approve" : "Reject";

    // 1. Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$actionText Request?'),
        content: Text('Are you sure you want to $actionText advance request ID: $id?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(actionText),
          ),
        ],
      ),
    ) ?? false;

    if (!confirmed) return;

    // 2. Perform the API call
    AdvanceSalary? updatedAdvance;
    if (isApprove) {
      updatedAdvance = await _advanceService.approveAdvanceSalary(id);
    } else {
      updatedAdvance = await _advanceService.rejectAdvanceSalary(id);
    }

    // 3. Update UI and show feedback
    if (updatedAdvance != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Advance request ID $id $actionText(d) successfully.')),
      );
      // Refresh the entire list
      setState(() {
        _futureAdvances = _fetchAdvances();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to $actionText advance request ID $id.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Advance Requests'),
      ),
      body: FutureBuilder<List<AdvanceSalary>>(
        future: _futureAdvances,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No advance requests found.'));
          }

          final advances = snapshot.data!;

          return SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('ID')),
                  DataColumn(label: Text('Employee')),
                  DataColumn(label: Text('Amount')),
                  DataColumn(label: Text('Reason')),
                  DataColumn(label: Text('Requested Date')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Action')),
                ],
                rows: advances.map((advance) {
                  // Safely get employee name from the nested dynamic map
                  final employeeName = advance.employee != null && advance.employee is Map
                      ? advance.employee['name'] ?? 'N/A'
                      : 'N/A';

                  // Determine button visibility based on status
                  final isPending = advance.status == 'PENDING';

                  return DataRow(
                    cells: [
                      DataCell(Text(advance.id.toString())),
                      DataCell(Text(employeeName)),
                      DataCell(Text('\$${advance.amount.toStringAsFixed(2)}')),
                      DataCell(Text(advance.reason ?? '')),
                      DataCell(Text(advance.requestDate)),
                      DataCell(
                        Text(
                          advance.status,
                          style: TextStyle(
                            color: advance.status == 'APPROVED' ? Colors.green :
                            advance.status == 'REJECTED' ? Colors.red :
                            Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      DataCell(
                        Row(
                          children: [
                            if (isPending)
                              IconButton(
                                icon: const Icon(Icons.check, color: Colors.green),
                                tooltip: 'Approve',
                                onPressed: () => _handleAction(advance.id!, true),
                              ),
                            if (isPending)
                              IconButton(
                                icon: const Icon(Icons.close, color: Colors.red),
                                tooltip: 'Reject',
                                onPressed: () => _handleAction(advance.id!, false),
                              ),
                          ],
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }
}