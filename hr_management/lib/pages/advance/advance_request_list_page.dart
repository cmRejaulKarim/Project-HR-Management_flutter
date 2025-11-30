import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hr_management/entity/advance.dart';
import 'package:hr_management/service/advance_service.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

const double _kTabletBreakpoint = 600.0;

class AdvanceRequestListPage extends StatefulWidget {
  const AdvanceRequestListPage({super.key});

  @override
  State<AdvanceRequestListPage> createState() => _AdvanceRequestListPageState();
}

class _AdvanceRequestListPageState extends State<AdvanceRequestListPage> {
  final AdvanceService _advanceService = AdvanceService();
  late Future<List<AdvanceSalary>> _futureAdvances;

  String _currentFilter = 'ALL';

  @override
  void initState() {
    super.initState();
    _futureAdvances = _fetchAdvances();
  }

  // Method to fetch and sort the advances
  Future<List<AdvanceSalary>> _fetchAdvances() async {
    final advances = await _advanceService.viewAllAdvanceRequests();
    advances.sort((a, b) => b.requestDate.compareTo(a.requestDate));
    return advances;
  }

  // --- Action Handlers (unchanged) ---

  Future<void> _handleAction(int id, bool isApprove) async {
    final actionText = isApprove ? "Approve" : "Reject";

    // 1. Show confirmation dialog
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('$actionText Request?'),
            content: Text(
              'Are you sure you want to $actionText advance request ID: $id?',
            ),
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
        ) ??
        false;

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
        SnackBar(
          content: Text('Advance request ID $id ${actionText}d successfully.'),
        ),
      );
      // Refresh the entire list
      setState(() {
        _futureAdvances = _fetchAdvances();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to $actionText advance request ID $id.'),
        ),
      );
    }
  }

  // --- Helper Widget to display status (unchanged) ---
  Widget _buildStatusText(String status) {
    Color color = Colors.orange;
    if (status == 'APPROVED') {
      color = Colors.green;
    } else if (status == 'REJECTED') {
      color = Colors.red;
    }
    return Text(
      status,
      style: TextStyle(color: color, fontWeight: FontWeight.bold),
    );
  }

  // -------------------------------------------------------------------
  // PDF Download Logic - FULL IMPLEMENTATION
  // -------------------------------------------------------------------
  Future<void> _downloadApprovedPdf(List<AdvanceSalary> allAdvances) async {
    final approvedAdvances = allAdvances
        .where((a) => a.status == 'APPROVED')
        .toList();

    if (approvedAdvances.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ No approved requests to download.')),
      );
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('⏳ Generating PDF...')));

    try {
      final pdf = pw.Document(title: "Approved Advance Requests");

      // Prepare the data for the PDF table
      final headers = [
        'ID',
        'Employee',
        'Amount (৳)',
        'Reason',
        'Requested Date',
      ];
      final data = approvedAdvances.map((advance) {
        final employeeName = advance.employee != null && advance.employee is Map
            ? advance.employee['name'] ?? 'N/A'
            : 'N/A';

        return [
          advance.id.toString(),
          employeeName,
          advance.amount.toStringAsFixed(2),
          advance.reason ?? 'N/A',
          advance.requestDate,
        ];
      }).toList();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4.portrait,
          header: (pw.Context context) {
            return pw.Center(
              child: pw.Text(
                'Approved Advance Requests Report',
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            );
          },
          build: (pw.Context context) {
            return [
              pw.SizedBox(height: 10),
              pw.Text(
                'Total Approved Requests: ${approvedAdvances.length}',
                style: const pw.TextStyle(fontSize: 12),
              ),
              pw.SizedBox(height: 10),
              pw.Table.fromTextArray(
                headers: headers,
                data: data,
                border: pw.TableBorder.all(color: PdfColors.grey),
                headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
                headerDecoration: const pw.BoxDecoration(
                  color: PdfColors.blueGrey700,
                ),
                cellHeight: 30,
                cellAlignments: {
                  0: pw.Alignment.centerLeft,
                  1: pw.Alignment.centerLeft,
                  2: pw.Alignment.centerRight,
                  3: pw.Alignment.centerLeft,
                  4: pw.Alignment.center,
                },
              ),
            ];
          },
        ),
      );

      // Use the printing package to share/save the PDF file
      await Printing.sharePdf(
        bytes: await pdf.save(),
        filename:
            'approved_advances_${DateTime.now().toIso8601String().substring(0, 10)}.pdf',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ PDF download initiated successfully.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error generating PDF: $e')));
    }
  }

  // --- Widget for Download Button ---
  Widget _buildDownloadButton(List<AdvanceSalary> advances) {
    if (advances.isEmpty) return const SizedBox.shrink();

    return IconButton(
      icon: const Icon(Icons.download),
      tooltip: 'Download Approved Requests PDF',
      onPressed: () => _downloadApprovedPdf(advances),
    );
  }

  // --- Widget for Filter Dropdown ---
  Widget _buildFilterDropdown() {
    final List<String> statuses = ['ALL', 'PENDING', 'APPROVED', 'REJECTED'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _currentFilter,
          icon: const Icon(Icons.filter_list, color: Colors.white),
          style: const TextStyle(color: Colors.black),
          dropdownColor: Colors.white,
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                _currentFilter = newValue;
              });
            }
          },
          items: statuses.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                'Show ${value == 'ALL' ? 'All' : value}',
                style: const TextStyle(color: Colors.black),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // --- Large Screen (DataTable) Widget (MODIFIED for filtering) ---
  Widget _buildDataTable(List<AdvanceSalary> advances) {
    // Filter the list before building the table
    final filteredAdvances = advances.where((advance) {
      return _currentFilter == 'ALL' || advance.status == _currentFilter;
    }).toList();

    if (filteredAdvances.isEmpty) {
      return Center(
        child: Text(
          'No requests found for the selected filter: $_currentFilter.',
        ),
      );
    }

    return SingleChildScrollView(
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
        rows: filteredAdvances.map((advance) {
          final employeeName =
              advance.employee != null && advance.employee is Map
              ? advance.employee['name'] ?? 'N/A'
              : 'N/A';
          final isPending = advance.status == 'PENDING';

          return DataRow(
            cells: [
              DataCell(Text(advance.id.toString())),
              DataCell(Text(employeeName)),
              DataCell(Text('৳${advance.amount.toStringAsFixed(2)}')),
              DataCell(Text(advance.reason ?? '')),
              DataCell(Text(advance.requestDate)),
              DataCell(_buildStatusText(advance.status)),
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
    );
  }

  // --- Small Screen (List View) Widget (MODIFIED for filtering) ---
  Widget _buildListView(List<AdvanceSalary> advances) {
    // Filter the list before building the ListView
    final filteredAdvances = advances.where((advance) {
      return _currentFilter == 'ALL' || advance.status == _currentFilter;
    }).toList();

    if (filteredAdvances.isEmpty) {
      return Center(
        child: Text(
          'No requests found for the selected filter: $_currentFilter.',
        ),
      );
    }

    return ListView.builder(
      itemCount: filteredAdvances.length,
      itemBuilder: (context, index) {
        final advance = filteredAdvances[index];
        final employeeName = advance.employee != null && advance.employee is Map
            ? advance.employee['name'] ?? 'N/A'
            : 'N/A';
        final isPending = advance.status == 'PENDING';

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title Row: Employee Name and Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        '${employeeName} (ID: ${advance.id})',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    _buildStatusText(advance.status),
                  ],
                ),
                const Divider(height: 10),
                // Details
                Text('Amount: ৳${advance.amount.toStringAsFixed(2)}'),
                Text('Requested: ${advance.requestDate}'),
                Text('Reason: ${advance.reason ?? 'N/A'}'),

                // Action Buttons
                if (isPending)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _handleAction(advance.id!, true),
                          icon: const Icon(Icons.check),
                          label: const Text('Approve'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: () => _handleAction(advance.id!, false),
                          icon: const Icon(Icons.close),
                          label: const Text('Reject'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Advance Requests'),
        actions: [
          FutureBuilder<List<AdvanceSalary>>(
            future: _futureAdvances,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return _buildDownloadButton(snapshot.data!);
              }
              return const SizedBox.shrink();
            },
          ),
          _buildFilterDropdown(),
        ],
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

          // Use LayoutBuilder for responsiveness
          return LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > _kTabletBreakpoint) {
                // Wide screen
                return _buildDataTable(advances);
              } else {
                // Narrow screen
                return _buildListView(advances);
              }
            },
          );
        },
      ),
    );
  }
}
