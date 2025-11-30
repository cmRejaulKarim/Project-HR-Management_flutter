import 'package:flutter/material.dart';
import 'package:hr_management/entity/salary.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class SalaryDetailScreen extends StatelessWidget {
  final Salary salary;

  const SalaryDetailScreen({super.key, required this.salary});

  String _getName(dynamic entity) {
    if (entity != null) {
      return entity.name;
    }
    return 'N/A';
  }

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

  //PDF Generation Function
  Future<void> _generatePdf(BuildContext context) async {
    final pdf = pw.Document();

    // Data for PDF
    final designationName = _getName(salary.employee.designation);
    final departmentName = _getName(salary.employee.department);
    final payPeriod = salary.month.substring(0, 7);
    final employeeName = salary.employee.name;

    // Helper for PDF Detail Row
    pw.Widget _buildPdfRow(String label, String value, {PdfColor? color}) {
      return pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 4),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(label, style: const pw.TextStyle(fontSize: 10)),
            pw.Text(
              value,
              style: pw.TextStyle(
                fontSize: 10,
                fontWeight: color != null
                    ? pw.FontWeight.bold
                    : pw.FontWeight.normal,
                color: color,
              ),
            ),
          ],
        ),
      );
    }

    // PDF Content Layout
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text(
                  'PAYSLIP - $payPeriod',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 20),

              // Employee Details
              pw.Text(
                'Employee Details',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Divider(),
              _buildPdfRow('Name', employeeName),
              _buildPdfRow('Department', departmentName),
              _buildPdfRow('Designation', designationName),
              pw.SizedBox(height: 15),

              // Earnings Section
              pw.Text(
                'Earnings',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Divider(),
              _buildPdfRow(
                'Basic Salary',
                '${salary.basicSalary.toStringAsFixed(2)}',
              ),
              _buildPdfRow(
                'Allowance',
                '${salary.allowance.toStringAsFixed(2)}',
              ),
              _buildPdfRow(
                'Overtime Hours',
                '${salary.totalMonthlyOverTimeHour ?? 0} hrs',
              ),
              _buildPdfRow(
                'Overtime Pay',
                '${salary.overtimeSalary.toStringAsFixed(2)}',
                color: PdfColors.green700,
              ),

              // Gross Salary
              pw.Divider(thickness: 1.5),
              _buildPdfRow(
                'Gross Salary',
                '${salary.totalSalary.toStringAsFixed(2)}',
                color: PdfColors.blue700,
              ),
              pw.Divider(thickness: 1.5),
              pw.SizedBox(height: 15),

              // Deductions Section
              pw.Text(
                'Deductions',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Divider(),
              _buildPdfRow(
                'Leave Days',
                '${salary.totalMonthlyLeave} days',
                color: PdfColors.red700,
              ),
              _buildPdfRow(
                'Leave Penalty',
                '${salary.leavePenalty.toStringAsFixed(2)}',
                color: PdfColors.red700,
              ),
              _buildPdfRow(
                'Absence Days',
                '${salary.totalMonthlyAbsence} days',
                color: PdfColors.red700,
              ),
              _buildPdfRow(
                'Absence Penalty',
                '${salary.absencePenalty.toStringAsFixed(2)}',
                color: PdfColors.red700,
              ),
              _buildPdfRow(
                'Advance Deduction',
                '${salary.advanceDeduction.toStringAsFixed(2)}',
                color: PdfColors.red700,
              ),

              // Net Pay
              pw.Divider(thickness: 2),
              _buildPdfRow(
                'NET PAYABLE',
                '${salary.netPay.toStringAsFixed(2)}',
                color: PdfColors.deepPurple700,
              ),
              pw.Divider(thickness: 2),

              pw.Spacer(),
              pw.Text(
                'Generated on: ${DateTime.now().toString().substring(0, 10)}',
                style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey),
              ),
            ],
          );
        },
      ),
    );

    // Use the printing package to display the PDF preview and printing options
    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'payslip_${employeeName}_$payPeriod.pdf',
    );
  }

  @override
  Widget build(BuildContext context) {
    final designationName = _getName(salary.employee.designation);
    final departmentName = _getName(salary.employee.department);

    return Scaffold(
      appBar: AppBar(
        title: Text('${salary.employee.name}\'s Salary'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          //ADD PDF ACTION BUTTON
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () => _generatePdf(context),
            tooltip: 'Generate PDF Payslip',
          ),
        ],
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

                // Employee Role Information
                Text(
                  '👤 Employee Details',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                _buildDetailRow('Designation', designationName),
                _buildDetailRow('Department', departmentName),
                const Divider(),
                const SizedBox(height: 10),

                // Earnings Section
                Text(
                  '💰 Earnings',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const Divider(),
                _buildDetailRow(
                  'Basic Salary',
                  '৳${salary.basicSalary.toStringAsFixed(2)}',
                ),
                _buildDetailRow(
                  'Allowance',
                  '৳${salary.allowance.toStringAsFixed(2)}',
                ),
                _buildDetailRow(
                  'Overtime Hours',
                  '${salary.totalMonthlyOverTimeHour ?? 0} hrs',
                ),
                _buildDetailRow(
                  'Overtime Pay',
                  '৳${salary.overtimeSalary.toStringAsFixed(2)}',
                  color: Colors.green.shade700,
                ),

                // Total Before Deductions
                const Divider(height: 20, thickness: 2),
                _buildDetailRow(
                  'Gross Salary',
                  '৳${salary.totalSalary.toStringAsFixed(2)}',
                  color: Colors.blue,
                ),
                const Divider(height: 20, thickness: 2),

                // Deductions Section
                Text(
                  '💸 Deductions',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const Divider(),
                _buildDetailRow(
                  'Leave Days',
                  '${salary.totalMonthlyLeave} days',
                  color: Colors.red,
                ),
                _buildDetailRow(
                  'Leave Penalty',
                  '৳${salary.leavePenalty.toStringAsFixed(2)}',
                  color: Colors.red,
                ),
                _buildDetailRow(
                  'Absence Days',
                  '${salary.totalMonthlyAbsence} days',
                  color: Colors.red,
                ),
                _buildDetailRow(
                  'Absence Penalty',
                  '৳${salary.absencePenalty.toStringAsFixed(2)}',
                  color: Colors.red,
                ),
                _buildDetailRow(
                  'Advance Deduction',
                  '৳${salary.advanceDeduction.toStringAsFixed(2)}',
                  color: Colors.red,
                ),

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
