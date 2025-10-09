import 'package:flutter/material.dart';
import 'package:hr_management/entity/department.dart';
import 'package:hr_management/service/department_service.dart';

class DepartmentPage extends StatelessWidget {
  const DepartmentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Department Page',
      debugShowCheckedModeBanner: false,
      home: DepartmentScreen(),
    );
  }
}

class DepartmentScreen extends StatefulWidget {
  const DepartmentScreen({super.key});

  @override
  State<DepartmentScreen> createState() => _DepartmentScreenState();
}

class _DepartmentScreenState extends State<DepartmentScreen> {
  List<Department>? departments;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDepartments();
  }

  Future<void> fetchDepartments() async {
    final service = DepartmentService();
    final data = await service.getAllDepartments();

    setState(() {
      departments = data;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Departments')),
      body: isLoading
          ? Center(child: Text('No Departments Found'))
          : ListView.builder(
              itemCount: departments?.length,
              itemBuilder: (context, index) {
                final department = departments![index];
                return Card(child: ListTile(title: Text(department.name)));
              },
            ),
    );
  }
}
