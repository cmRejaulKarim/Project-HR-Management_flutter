import 'package:flutter/material.dart';
import 'package:hr_management/entity/employee.dart';
import 'package:hr_management/entity/employee_details_view.dart';
import 'package:hr_management/service/employee_service.dart';

class EmployeeDetailScreen extends StatefulWidget {
  final Employee employee;

  const EmployeeDetailScreen({super.key, required this.employee});

  @override
  State<EmployeeDetailScreen> createState() => _EmployeeDetailScreenState();
}

class _EmployeeDetailScreenState extends State<EmployeeDetailScreen> {
  final EmployeeService _employeeService = EmployeeService();

  Future<EmployeeDetails?>? _detailsFuture;

  @override
  void initState() {
    super.initState();
    _detailsFuture = _employeeService.getFullEmployeeDetails(
      widget.employee.id,
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, size: 20, color: Colors.blueGrey.shade600),
          const SizedBox(width: 12),

          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),

          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                color: valueColor ?? Colors.black87,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  // Widget to build the body content once data is loaded
  Widget _buildDetailsBody(BuildContext context, EmployeeDetails details) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Center(
            child: CircleAvatar(
              radius: 60,
              backgroundImage: details.photoUrl != null
                  ? NetworkImage(details.photoUrl!) as ImageProvider
                  : null,
              child: details.photoUrl == null
                  ? Text(
                      details.employee.name.isNotEmpty
                          ? details.employee.name[0].toUpperCase()
                          : '?',
                      style: const TextStyle(fontSize: 40, color: Colors.white),
                    )
                  : null,
              backgroundColor: Colors.blue.shade300,
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: Text(
              details.employee.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          Center(
            child: Text(
              details.designationName,
              style: TextStyle(fontSize: 18, color: Colors.grey.shade700),
            ),
          ),
          const SizedBox(height: 24),

          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Contact Information',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Divider(),
                  _buildDetailRow(Icons.email, 'Email', details.employee.email),
                  _buildDetailRow(
                    Icons.phone,
                    'Phone',
                    details.employee.phone ?? 'N/A',
                  ),
                  _buildDetailRow(
                    Icons.location_on,
                    'Address',
                    details.employee.address ?? 'N/A',
                  ),
                  _buildDetailRow(
                    Icons.male,
                    'Gender',
                    details.employee.gender ?? 'N/A',
                  ),
                  _buildDetailRow(
                    Icons.cake,
                    'Date of Birth',
                    details.employee.dateOfBirth ?? 'N/A',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Employment Details',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Divider(),
                  _buildDetailRow(
                    Icons.business,
                    'Department',
                    details.departmentName,
                  ),
                  _buildDetailRow(
                    Icons.work,
                    'Designation',
                    details.designationName,
                  ),
                  _buildDetailRow(
                    Icons.date_range,
                    'Joining Date',
                    details.employee.joiningDate ?? 'N/A',
                  ),
                  _buildDetailRow(
                    Icons.paid,
                    'Basic Salary',
                    '\$${details.employee.basicSalary?.toStringAsFixed(2) ?? 'N/A'}',
                  ),

                  _buildDetailRow(
                    details.employee.active == true
                        ? Icons.check_circle
                        : Icons.cancel,
                    'Status',
                    details.employee.active == true ? 'Active' : 'Suspended',
                    valueColor: details.employee.active == true
                        ? Colors.green.shade700
                        : Colors.red.shade700,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.employee.name),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<EmployeeDetails?>(
        future: _detailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  'Failed to load employee details: ${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Employee data not found.'));
          }

          final details = snapshot.data!;
          return _buildDetailsBody(context, details);
        },
      ),
    );
  }
}
