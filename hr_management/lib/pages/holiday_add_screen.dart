import 'package:flutter/material.dart';
import 'package:hr_management/entity/holiday.dart';
import 'package:hr_management/service/holiday_service.dart';
import 'package:intl/intl.dart';

class HolidayScreen extends StatefulWidget {
  const HolidayScreen({super.key});

  @override
  State<HolidayScreen> createState() => _HolidayScreenState();
}

class _HolidayScreenState extends State<HolidayScreen> {
  final HolidayService _holidayService = HolidayService();

  // State for the View Holidays Tab
  late Future<List<Holiday>> _holidaysFuture;

  // State for the Add Holiday Tab
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _selectedDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _holidaysFuture = _holidayService.getAllHolidays();
  }

  @override
  void dispose() {
    _dateController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

// -----------------------------------------------------------------------------
// HELPER METHODS: VIEW HOLIDAYS (including Delete logic)
// -----------------------------------------------------------------------------

  void _refreshHolidays() {
    setState(() {
      _holidaysFuture = _holidayService.getAllHolidays();
    });
  }

  // Function to handle holiday deletion
  Future<void> _deleteHoliday(int id) async {
    final bool success = await _holidayService.deleteHoliday(id);

    if (success) {
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Holiday deleted successfully!')),
      );
      _refreshHolidays(); // Refresh the list after deletion
    } else {
      // Show failure message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Failed to delete holiday. Please try again.')),
      );
    }
  }

  // Function to show a confirmation dialog before deleting
  void _confirmDelete(Holiday holiday) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: Text(
              'Are you sure you want to delete the holiday "${holiday.description}" on ${holiday.date}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteHoliday(holiday.id);
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  // Helper function to find the index of the next upcoming holiday
  int _getNextHolidayIndex(List<Holiday> holidays) {
    final now = DateTime.now();
    int nextHolidayIndex = -1;
    DateTime? nextHolidayDate;

    for (int i = 0; i < holidays.length; i++) {
      try {
        final holidayDate = DateFormat('yyyy-MM-dd').parse(holidays[i].date);

        if (holidayDate.isAfter(now) || holidayDate.isAtSameMomentAs(now)) {
          if (nextHolidayDate == null || holidayDate.isBefore(nextHolidayDate)) {
            nextHolidayDate = holidayDate;
            nextHolidayIndex = i;
          }
        }
      } catch (e) {
        print('Error parsing date for holiday: ${holidays[i].date}, $e');
      }
    }
    return nextHolidayIndex;
  }

// -----------------------------------------------------------------------------
// HELPER METHODS: ADD HOLIDAY
// -----------------------------------------------------------------------------

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text =
        '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      });
    }
  }

  Future<void> _addHoliday() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final date = _dateController.text;
      final description = _descriptionController.text;

      final newHoliday = await _holidayService.addHoliday(date, description);

      setState(() {
        _isLoading = false;
      });

      if (newHoliday != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Holiday added successfully!')),
        );
        _dateController.clear();
        _descriptionController.clear();
        _selectedDate = null;
        _refreshHolidays(); // Important: refresh the view list
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Failed to add holiday. Please try again.')),
        );
      }
    }
  }

// -----------------------------------------------------------------------------
// WIDGET BUILDERS
// -----------------------------------------------------------------------------

  Widget _buildViewHolidaysTab() {
    return FutureBuilder<List<Holiday>>(
      future: _holidaysFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
              child: Text('Error: ${snapshot.error}. Check your service URL.'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No holidays found.'));
        } else {
          final holidays = snapshot.data!;
          final nextHolidayIndex = _getNextHolidayIndex(holidays);

          return ListView.builder(
            itemCount: holidays.length,
            itemBuilder: (context, index) {
              final holiday = holidays[index];
              final isNextHoliday = index == nextHolidayIndex;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                elevation: isNextHoliday ? 4 : 2,
                color: isNextHoliday ? Colors.lightGreen.shade50 : Colors.white,
                child: ListTile(
                  leading: Icon(
                    isNextHoliday ? Icons.star : Icons.date_range,
                    color: isNextHoliday ? Colors.orange : Colors.blue,
                  ),
                  title: Text(
                    holiday.description,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isNextHoliday ? Colors.deepOrange : Colors.black,
                    ),
                  ),
                  subtitle: Text(
                    holiday.date + (isNextHoliday ? ' (NEXT UPCOMING)' : ''),
                    style: TextStyle(
                      fontWeight:
                      isNextHoliday ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  // ✅ DELETE BUTTON RE-ADDED HERE
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _confirmDelete(holiday),
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }

  Widget _buildAddHolidayTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Date Picker Field
            TextFormField(
              controller: _dateController,
              readOnly: true, // Prevent manual editing
              decoration: InputDecoration(
                labelText: 'Date',
                hintText: 'Select the holiday date',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () => _selectDate(context),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a date';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Description Field
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'e.g., Christmas Day, Eid al-Fitr',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),
            const SizedBox(height: 30),

            // Submit Button
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _addHoliday,
              icon: _isLoading
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                ),
              )
                  : const Icon(Icons.add),
              label: Text(_isLoading ? 'Adding...' : 'Add Holiday'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Holiday Management'),
          bottom: TabBar(
            tabs: const [
              Tab(text: 'View Holidays', icon: Icon(Icons.list)),
              Tab(text: 'Add Holiday', icon: Icon(Icons.add_box)),
            ],
            onTap: (index) {
              if (index == 0) {
                _refreshHolidays();
              }
            },
          ),
        ),
        body: TabBarView(
          children: [
            _buildViewHolidaysTab(),
            _buildAddHolidayTab(),
          ],
        ),
      ),
    );
  }
}