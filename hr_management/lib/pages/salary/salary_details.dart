import 'package:flutter/material.dart';
import 'package:hr_management/entity/salary.dart';
// Note: You don't need to explicitly import employee.dart here if salary.dart imports it.

class SalaryDetailScreen extends StatelessWidget {
  final Salary salary;

  const SalaryDetailScreen({super.key, required this.salary});

  Widget _buildDetailRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 16, color: Colors.grey[700])),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: color != null ? FontWeight.bold : FontWeight.normal,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // Helper to safely get the name from a nested object (Designation/Department)
  String _getName(dynamic entity) {
    // This relies on the nested Department/Designation object having a 'name' field
    if (entity != null) {
      // Since your models (Employee/Department/Designation) are strongly typed,
      // we can safely access the name property.
      return entity.name;
    }
    return 'N/A';
  }


  @override
  Widget build(BuildContext context) {
    // Safely extract employee role information using the helper method
    final designationName = _getName(salary.employee.designation);
    final departmentName = _getName(salary.employee.department);

    return Scaffold(
      appBar: AppBar(
        title: Text('${salary.employee.name}\'s Salary'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Info
                Text(
                  'Pay Period: ${salary.month.substring(0, 7)}',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const Divider(),

                // ⭐️ ADDED: Employee Role Information
                Text(
                  '👤 Employee Details',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                _buildDetailRow('Designation', designationName),
                _buildDetailRow('Department', departmentName),
                const Divider(),
                const SizedBox(height: 10),

                // Earnings Section
                Text(
                  '💰 Earnings',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const Divider(),
                _buildDetailRow('Basic Salary', '৳${salary.basicSalary.toStringAsFixed(2)}'),
                _buildDetailRow('Allowance', '৳${salary.allowance.toStringAsFixed(2)}'),
                _buildDetailRow('Overtime Hours', '${salary.totalMonthlyOverTimeHour} hrs'),
                _buildDetailRow('Overtime Pay', '৳${salary.overtimeSalary.toStringAsFixed(2)}', color: Colors.green.shade700),

                // Total Before Deductions
                const Divider(height: 20, thickness: 2),
                _buildDetailRow('Gross Salary', '৳${salary.totalSalary.toStringAsFixed(2)}', color: Colors.blue),
                const Divider(height: 20, thickness: 2),

                // Deductions Section
                Text(
                  '💸 Deductions',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const Divider(),
                _buildDetailRow('Absence Days', '${salary.totalMonthlyAbsence} days', color: Colors.red),
                _buildDetailRow('Absence Penalty', '৳${salary.absencePenalty.toStringAsFixed(2)}', color: Colors.red),
                _buildDetailRow('Advance Deduction', '৳${salary.advanceDeduction.toStringAsFixed(2)}', color: Colors.red),

                // Final Net Pay
                const Divider(height: 20, thickness: 3, color: Colors.black),
                _buildDetailRow(
                  'NET PAYABLE',
                  '৳${salary.netPay.toStringAsFixed(2)}',
                  color: Colors.deepPurple,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}