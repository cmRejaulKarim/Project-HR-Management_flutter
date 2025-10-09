import 'dart:io';

import 'package:date_field/date_field.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hr_management/entity/department.dart';
import 'package:hr_management/entity/designation.dart';
import 'package:hr_management/pages/loginpage.dart';
import 'package:hr_management/service/authservice.dart';
import 'package:hr_management/service/department_service.dart';
import 'package:hr_management/service/designation_service.dart';
import 'package:hr_management/utils/image_picker_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_picker_web/image_picker_web.dart';

// import 'package:image_picker_web/image_picker_web.dart';
import 'package:radio_group_v2/radio_group_v2.dart';
import 'package:radio_group_v2/radio_group_v2.dart' as v2;

import 'package:intl/intl.dart';

class Registration extends StatefulWidget {
  const Registration({super.key});

  @override
  State<Registration> createState() => _RegistrationState();
}

class _RegistrationState extends State<Registration> {
  bool _obsecurePassword = true;
  bool _obsecureConfirmPassword = true;
  final DepartmentService _departmentService = DepartmentService();
  final DesignationService _designationService = DesignationService();

  List<Department> departments = [];
  List<Designation> designations = [];

  Department? selectedDepartment;
  Designation? selectedDesignation;

  final TextEditingController name = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController confirmPassword = TextEditingController();
  final TextEditingController cell = TextEditingController();
  final TextEditingController address = TextEditingController();

  final RadioGroupController genderController = RadioGroupController();

  final DateTimeFieldPickerPlatform dob = DateTimeFieldPickerPlatform.material;

  String? selectedGender;
  DateTime? selectedDOB;
  XFile? selectedImage;
  Uint8List? webImage;

  final ImagePicker _picker = ImagePicker();

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loadDepartments();
  }
  Future<void> _loadDepartments() async {
    departments = await _departmentService.getDepartments();
    print(departments.toString());
    setState(() {});
  }
  Future<void> _loadDesignations(int departmentId) async {
    designations = await _designationService.getDesignations(departmentId);
    print(designations.toString());
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16.0),

        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              // crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,

              children: [
                TextField(
                  controller: name,
                  decoration: InputDecoration(
                    labelText: "Full Name",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                ),

                SizedBox(height: 20.0),

                TextField(
                  controller: email,
                  decoration: InputDecoration(
                    labelText: "Email",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                ),

                SizedBox(height: 20.0),

                TextField(
                  controller: password,
                  decoration: InputDecoration(
                    labelText: "Password",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.password),
                  ),
                  obscureText: true,
                ),

                SizedBox(height: 20.0),

                TextField(
                  controller: confirmPassword,
                  decoration: InputDecoration(
                    labelText: "Confirm Password",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                ),

                SizedBox(height: 20.0),

                TextField(
                  controller: cell,
                  decoration: InputDecoration(
                    labelText: "Cell",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.call),
                  ),
                ),

                SizedBox(height: 20.0),

                TextField(
                  controller: address,
                  decoration: InputDecoration(
                    labelText: "Address",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.maps_home_work_rounded),
                  ),
                ),
                SizedBox(height: 20.0),

                DateTimeFormField(
                  decoration: const InputDecoration(labelText: 'Date of Birth'),
                  mode: DateTimeFieldPickerMode.date,
                  pickerPlatform: dob,

                  onChanged: (DateTime? value) {
                    setState(() {
                      selectedDOB = value;
                    });
                  },
                ),

                SizedBox(height: 20.0),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Gender',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      v2.RadioGroup(
                        controller: genderController,
                        values: ['Male', 'Female', 'Other'],
                        indexOfDefault: 0,
                        orientation: RadioGroupOrientation.horizontal,
                        onChanged: (newValue) {
                          selectedGender = newValue.toString();
                        },
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 20.0),

                DropdownButtonFormField<Department>(
                value: selectedDepartment,
                  decoration: const InputDecoration(
                  labelText: 'Department',
                  ),
                  items: departments.map((dept) {
                    return DropdownMenuItem(value: dept, child: Text(dept.name));
                  }).toList(),
                  onChanged: (value) {
                  setState(() => selectedDepartment = value);
                  if (value != null) _loadDesignations(value.id);
                  }
                ),

                SizedBox(height: 20.0),

                DropdownButtonFormField<Designation>(
                  value: selectedDesignation,
                  decoration: const InputDecoration(
                    labelText: 'Designation',
                  ),
                  items: designations.map((designation) {
                    return DropdownMenuItem(
                      value: designation,
                      child: Text(designation.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => selectedDesignation = value);
                  },
                ),

                SizedBox(height: 20.0),

                TextButton.icon(
                  icon: Icon(Icons.image),
                  label: Text('Upload Image'),
                  onPressed: pickImage,
                ),
                if (kIsWeb && webImage != null)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.memory(
                      webImage!,
                      height: 100,
                      width: 100,
                      fit: BoxFit.cover,
                    ),
                  )
                else if (kIsWeb && selectedImage != null)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.file(
                      File(selectedImage!.path),
                      height: 100,
                      width: 100,
                      fit: BoxFit.cover,
                    ),
                  ),

                SizedBox(height: 20.0),

                ElevatedButton(
                  onPressed: () {
                    _register();
                  },
                  child: Text(
                    "Registration",
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontFamily: GoogleFonts.lato().fontFamily,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.grey,
                  ),
                ),
                SizedBox(height: 20.0),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );
                  },
                  child: Text(
                    'Login',
                    style: TextStyle(
                      color: Colors.purple,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> pickImage() async {
    if (kIsWeb) {
      var pickedImage = await ImagePickerWeb.getImageAsBytes();
      if (pickedImage != null) {
        setState(() {
          webImage = pickedImage;
        });
      }
    } else {
      final XFile? pickedImage = await _picker.pickImage(
        source: ImageSource.gallery,
      );
      if (pickedImage != null) {
        setState(() {
          selectedImage = pickedImage;
        });
      }
    }
  }

  //individual image picker for web and mobile
  // Future<void> pickImage() async {
  //   final picker = ImagePickerService();
  //
  //   if (kIsWeb) {
  //     final imageBytes = await picker.pickImageBytes();
  //     if (imageBytes != null) {
  //       setState(() {
  //         webImage = imageBytes;
  //       });
  //     }
  //   } else {
  //     final file = await picker.pickImageFile();
  //     if (file != null) {
  //       setState(() {
  //         selectedImage = XFile(file.path);
  //       });
  //     }
  //   }
  // }

  // void _register() async {
  //   //validation for form
  //   if (_formKey.currentState!.validate()) {
  //     if (password.text != confirmPassword.text) {
  //       ScaffoldMessenger.of(
  //         context,
  //       ).showSnackBar(SnackBar(content: Text('Password does not match')));
  //       return;
  //     }
  //
  //     //validation for image
  //     if (kIsWeb) {
  //       if (webImage == null) {
  //         ScaffoldMessenger.of(
  //           context,
  //         ).showSnackBar(SnackBar(content: Text('Please select an image')));
  //         return;
  //       }
  //     } else {
  //       if (selectedImage == null) {
  //         ScaffoldMessenger.of(
  //           context,
  //         ).showSnackBar(SnackBar(content: Text('Please select an image')));
  //         return;
  //       }
  //     }
  //
  //     final user = {
  //       "name": name.text,
  //       "email": email.text,
  //       "password": password.text,
  //       "phone": cell.text,
  //     };
  //     final employee = {
  //       "name": name.text,
  //       "email": email.text,
  //       "phone": cell.text,
  //       "gender": selectedGender,
  //       "address": address.text,
  //       "dateOfBirth": selectedDOB?.toIso8601String() ?? "",
  //     };
  //     final apiService = AuthService();
  //
  //     bool success = false;
  //     if(kIsWeb && webImage != null){
  //       success = await apiService.registerEmployee(
  //         user: user,
  //         employee: employee,
  //         photoBytes: webImage,
  //       );
  //     }
  //     else if(selectedImage != null){
  //       success = await apiService.registerEmployee(
  //         user: user,
  //         employee: employee,
  //         photofile: File(selectedImage!.path),
  //       );
  //     }
  //
  //     if (success) {
  //       ScaffoldMessenger.of(
  //         context,
  //       ).showSnackBar(SnackBar(content: Text('Registration successful')));
  //     Navigator.push(
  //       context,
  //       MaterialPageRoute(builder: (context) => LoginPage()),
  //     );
  //     } else {
  //       ScaffoldMessenger.of(
  //         context,
  //       ).showSnackBar(SnackBar(content: Text('Registration failed')));
  //     }
  //
  //
  //   }
  // }

  void _register() async {
    // ✅ Check if the form (text fields) is valid
    if (_formKey.currentState!.validate()) {
      // ✅ Check if password and confirm password match
      if (password.text != confirmPassword.text) {
        // Show an error message if passwords don’t match
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Password does not match')));
        return; // stop further execution
      }
      // ✅ Validate that a department is selected
      if (selectedDepartment == null ||
      selectedDesignation == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Department or Designation cannot be empty.')));
        return; // stop further execution
      }

      // ✅ Validate that the user has selected an image
      if (kIsWeb) {
        // On Web → check if webImage (Uint8List) is selected
        if (webImage == null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Please select an image.')));
          return; // stop further execution
        }
      } else {
        // On Mobile/Desktop → check if image file is selected
        if (selectedImage == null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Please select an image.')));
          return; // stop further execution
        }
      }

      // ✅ Prepare User object (basic login info)
      final user = {
        "name": name.text,
        "email": email.text,
        "phone": cell.text,
        "password": password.text,
      };

      // ✅ Prepare employee object (extra personal info)
      final employee = {
        "name": name.text,
        "email": email.text,
        "phone": cell.text,
        "gender": selectedGender ?? "Other",
        // fallback if null
        "address": address.text,
        "dateOfBirth": selectedDOB != null
            ? DateFormat('yyyy-MM-dd').format(selectedDOB!)
            : "",
        // convert DateTime to ISO string
        "department": selectedDepartment!.id,
        "designation": selectedDesignation!.id,
      };

      print(employee);

      // ✅ Initialize your API Service
      final apiService = AuthService();

      // ✅ Track API call success or failure
      bool success = false;

      // ✅ Send registration request (different handling for Web vs Mobile)
      if (kIsWeb && webImage != null) {
        // For Web → send photo as bytes
        success = await apiService.registerEmployee(
          user: user,
          employee: employee,
          photoBytes: webImage!, // safe to use ! because already checked above
        );
      } else if (selectedImage != null) {
        // For Mobile → send photo as file
        success = await apiService.registerEmployee(
          user: user,
          employee: employee,
          photoFile: File(
            selectedImage!.path,
          ), // safe to use ! because already checked above
        );
      }

      // ✅ Handle the API response
      if (success) {
        // Show success message
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Registration Successful')));

        // Redirect user to Login Page after successful registration
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Registration failed')));
      }
    }
  }
}
