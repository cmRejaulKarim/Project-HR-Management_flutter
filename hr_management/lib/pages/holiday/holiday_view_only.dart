import 'package:flutter/material.dart';
import 'package:hr_management/entity/holiday.dart';
import 'package:hr_management/service/holiday_service.dart';
import 'package:intl/intl.dart'; // ⚠️ You need to add the 'intl' package to your pubspec.yaml

class HolidayViewOnly extends StatefulWidget {
  const HolidayViewOnly({super.key});

  @override
  State<HolidayViewOnly> createState() => _HolidayViewOnlyState();
}

class _HolidayViewOnlyState extends State<HolidayViewOnly> {
  final HolidayService _holidayService = HolidayService();
  late Future<List<Holiday>> _holidaysFuture;

  @override
  void initState() {
    super.initState();
    _holidaysFuture = _holidayService.getAllHolidays();
  }

  // Function to refresh the list of holidays
  void _refreshHolidays() {
    setState(() {
      _holidaysFuture = _holidayService.getAllHolidays();
    });
  }

  // Helper function to find the index of the next upcoming holiday
  int _getNextHolidayIndex(List<Holiday> holidays) {
    final now = DateTime.now();
    int nextHolidayIndex = -1;
    DateTime? nextHolidayDate;

    for (int i = 0; i < holidays.length; i++) {
      try {
        // Parse the 'yyyy-MM-dd' string date from the API
        final holidayDate = DateFormat('yyyy-MM-dd').parse(holidays[i].date);

        // Check if the holiday is today or in the future
        if (holidayDate.isAfter(now) || holidayDate.isAtSameMomentAs(now)) {
          // If this is the first one found, or it's closer than the current nextHolidayDate
          if (nextHolidayDate == null || holidayDate.isBefore(nextHolidayDate)) {
            nextHolidayDate = holidayDate;
            nextHolidayIndex = i;
          }
        }
      } catch (e) {
        // Handle parsing errors if the date format is unexpected
        print('Error parsing date for holiday: ${holidays[i].date}, $e');
      }
    }
    return nextHolidayIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Holidays'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshHolidays,
          ),
        ],
      ),
      body: FutureBuilder<List<Holiday>>(
        future: _holidaysFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
                child:
                Text('Error: ${snapshot.error}. Check your service URL.'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No holidays found.'));
          } else {
            final holidays = snapshot.data!;
            // 🎯 Find the next holiday to highlight
            final nextHolidayIndex = _getNextHolidayIndex(holidays);

            return ListView.builder(
              itemCount: holidays.length,
              itemBuilder: (context, index) {
                final holiday = holidays[index];
                final isNextHoliday = index == nextHolidayIndex;

                return Card(
                  margin:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  elevation: isNextHoliday ? 4 : 2, // Raised elevation for highlight
                  color: isNextHoliday
                      ? Colors.lightGreen.shade50
                      : Colors.white, // Light background for highlight
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
                   
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}