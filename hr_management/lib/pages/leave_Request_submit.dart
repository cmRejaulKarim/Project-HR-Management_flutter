import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../entity/leave.dart';
import '../service/leave_service.dart'; // Assuming your LeaveService is here

class LeaveRequestPage extends StatefulWidget {
  // Assuming you can pass the logged-in employee's ID to this page
  final int loggedInEmpId;

  const LeaveRequestPage({super.key, required this.loggedInEmpId});

  @override
  State<LeaveRequestPage> createState() => _LeaveRequestPageState();
}

class _LeaveRequestPageState extends State<LeaveRequestPage> {
  final _formKey = GlobalKey<FormState>();
  final LeaveService _leaveService = LeaveService();
  final TextEditingController _reasonController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  int _totalLeaveDays = 0;
  bool _isLoading = false;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  // Helper to pick a date
  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 5),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          // Reset end date if it's before the new start date
          if (_endDate != null && _endDate!.isBefore(_startDate!)) {
            _endDate = null;
          }
        } else {
          _endDate = picked;
        }
        _calculateLeaveDays();
      });
    }
  }

  // Calculate the difference between start and end dates (inclusive)
  void _calculateLeaveDays() {
    if (_startDate != null && _endDate != null) {
      if (_endDate!.isBefore(_startDate!)) {
        setState(() {
          _totalLeaveDays = 0;
        });
        return;
      }
      final difference = _endDate!.difference(_startDate!).inDays;
      // Add 1 to make it inclusive (e.g., May 1 to May 1 is 1 day)
      setState(() {
        _totalLeaveDays = difference + 1;
      });
    } else {
      setState(() {
        _totalLeaveDays = 0;
      });
    }
  }

  // Submits the leave request
  Future<void> _submitLeave() async {
    if (_formKey.currentState!.validate() && _totalLeaveDays > 0) {
      setState(() {
        _isLoading = true;
      });

      // Format dates to match Spring Boot's LocalDate (YYYY-MM-DD)
      final String formattedStartDate = DateFormat('yyyy-MM-dd').format(_startDate!);
      final String formattedEndDate = DateFormat('yyyy-MM-dd').format(_endDate!);
      final String formattedRequestedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

      final newLeave = Leave(
        // We set empId so toJson() can correctly format the nested Employee ID
        empId: widget.loggedInEmpId,
        // The API expects the full nested object on retrieval, but we only need the ID for sending.
        // We use an empty map here since we rely on empId.
        employee: {},
        startDate: formattedStartDate,
        endDate: formattedEndDate,
        totalLeaveDays: _totalLeaveDays,
        reason: _reasonController.text.trim(),
        requestedDate: formattedRequestedDate,
        status: 'PENDING', // Default status for a new request
      );

      try {
        await _leaveService.applyLeave(newLeave);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Leave request submitted successfully!')),
          );
          // Navigate back or clear form
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to submit leave: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Leave Request'),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // --- Start Date Picker ---
              ListTile(
                leading: const Icon(Icons.calendar_today, color: Colors.teal),
                title: Text(
                  _startDate == null
                      ? 'Select Start Date'
                      : 'Start Date: ${DateFormat('MMM dd, yyyy').format(_startDate!)}',
                ),
                trailing: const Icon(Icons.arrow_right),
                onTap: () => _selectDate(context, true),
              ),
              const Divider(),

              // --- End Date Picker ---
              ListTile(
                leading: const Icon(Icons.calendar_month, color: Colors.teal),
                title: Text(
                  _endDate == null
                      ? 'Select End Date'
                      : 'End Date: ${DateFormat('MMM dd, yyyy').format(_endDate!)}',
                ),
                trailing: const Icon(Icons.arrow_right),
                onTap: () => _selectDate(context, false),
              ),
              const Divider(),

              // --- Total Days Display ---
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  'Total Days: $_totalLeaveDays',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _totalLeaveDays > 0 ? Colors.green : Colors.redAccent,
                  ),
                ),
              ),

              // --- Reason Field ---
              TextFormField(
                controller: _reasonController,
                decoration: const InputDecoration(
                  labelText: 'Reason for Leave',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.note),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a reason for your leave.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),

              // --- Submit Button ---
              ElevatedButton(
                onPressed: _isLoading ? null : _submitLeave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                    : const Text(
                  'Submit Request',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
              if (_totalLeaveDays == 0 && _startDate != null && _endDate != null)
                const Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Text(
                    'End Date must be on or after Start Date.',
                    style: TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}