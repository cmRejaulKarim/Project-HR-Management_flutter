import 'dart:io';
import 'package:date_field/date_field.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hr_management/entity/department.dart';
import 'package:hr_management/entity/designation.dart';
import 'package:hr_management/pages/loginpage.dart';
import 'package:hr_management/service/auth_service.dart';
import 'package:hr_management/service/department_service.dart';
import 'package:hr_management/service/designation_service.dart';
// NOTE: Removed unused import 'package:hr_management/utils/image_picker_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:radio_group_v2/radio_group_v2.dart';
import 'package:radio_group_v2/radio_group_v2.dart' as v2;
import 'package:intl/intl.dart';

class Registration extends StatefulWidget {
  const Registration({super.key});

  @override
  State<Registration> createState() => _RegistrationState();
}

class _RegistrationState extends State<Registration> {
  // Define a deep, rich color for the theme accents
  final Color deepPrimary = Colors.indigo.shade800;

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
    // FIX: Set default gender directly instead of accessing genderController.value
    // which causes the "lost track" error because the widget hasn't been built yet.
    selectedGender = 'Male';
    _loadDepartments();
  }

  Future<void> _loadDepartments() async {
    departments = await _departmentService.getDepartments();
    print("Loaded departments: ${departments.length}");
    setState(() {});
  }

  Future<void> _loadDesignations(int departmentId) async {
    // Clear previous selection
    selectedDesignation = null;
    designations = await _designationService.getDesignations(departmentId);
    print("Loaded designations: ${designations.length}");
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Darker background for "deep color" effect
      backgroundColor: Colors.blueGrey.shade900,
      body: Center(
        // Use SingleChildScrollView to prevent overflow on small screens
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 550, // Max width for a clean look on desktop/web
            ),
            child: Card(
              // Card view with elevation and rounded corners
              color: Colors.white,
              elevation: 12,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // --- Title Section ---
                      Icon(
                        Icons.person_add,
                        size: 60,
                        color: deepPrimary,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'HRMS New Employee Registration',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: deepPrimary,
                          fontFamily: GoogleFonts.lato().fontFamily,
                        ),
                      ),
                      const SizedBox(height: 30),

                      // --- Input Fields with custom styling and validation ---

                      _buildTextField(
                        controller: name,
                        label: 'Full Name',
                        icon: Icons.person,
                        keyboardType: TextInputType.text,
                        validator: (value) => value!.isEmpty ? 'Full name is required' : null,
                      ),
                      const SizedBox(height: 20.0),

                      _buildTextField(
                        controller: email,
                        label: 'Email',
                        icon: Icons.email,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) => !RegExp(r'\S+@\S+\.\S+').hasMatch(value!) ? 'Enter a valid email' : null,
                      ),
                      const SizedBox(height: 20.0),

                      _buildPasswordField(
                        controller: password,
                        label: 'Password',
                        icon: Icons.password,
                        obscureText: _obsecurePassword,
                        onToggle: () {
                          setState(() => _obsecurePassword = !_obsecurePassword);
                        },
                        validator: (value) => value!.length < 6 ? 'Password must be at least 6 characters' : null,
                      ),
                      const SizedBox(height: 20.0),

                      _buildPasswordField(
                        controller: confirmPassword,
                        label: 'Confirm Password',
                        icon: Icons.lock,
                        obscureText: _obsecureConfirmPassword,
                        onToggle: () {
                          setState(() => _obsecureConfirmPassword = !_obsecureConfirmPassword);
                        },
                        validator: (value) {
                          if (value!.isEmpty) return 'Confirm password is required';
                          // Note: Final match check is done in _register()
                          return null;
                        },
                      ),
                      const SizedBox(height: 20.0),

                      _buildTextField(
                        controller: cell,
                        label: 'Cell (Phone)',
                        icon: Icons.call,
                        keyboardType: TextInputType.phone,
                        validator: (value) => value!.isEmpty ? 'Phone number is required' : null,
                      ),
                      const SizedBox(height: 20.0),

                      _buildTextField(
                        controller: address,
                        label: 'Address',
                        icon: Icons.maps_home_work_rounded,
                        keyboardType: TextInputType.streetAddress,
                        validator: (value) => value!.isEmpty ? 'Address is required' : null,
                      ),
                      const SizedBox(height: 20.0),

                      // --- Date of Birth ---
                      // Re-implemented to use custom decoration and validation
                      DateTimeFormField(
                        decoration: _buildInputDecoration(
                          label: 'Date of Birth (MM/DD/YYYY)',
                          icon: Icons.calendar_today,
                        ),
                        mode: DateTimeFieldPickerMode.date,
                        pickerPlatform: dob,
                        validator: (value) => value == null ? 'Date of Birth is required' : null,
                        onChanged: (DateTime? value) {
                          setState(() {
                            selectedDOB = value;
                          });
                        },
                      ),

                      const SizedBox(height: 20.0),

                      // --- Gender Radio Group ---
                      // Styled using a local Theme to set the active color
                      Theme(
                        data: Theme.of(context).copyWith(
                          primaryColor: deepPrimary,
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Gender',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, color: Colors.grey.shade700),
                              ),
                              v2.RadioGroup(
                                controller: genderController,
                                values: const ['Male', 'Female', 'Other'],
                                indexOfDefault: 0,
                                orientation: RadioGroupOrientation.horizontal,
                                onChanged: (newValue) {
                                  selectedGender = newValue.toString();
                                },
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20.0),

                      // --- Department Dropdown ---
                      DropdownButtonFormField<Department>(
                        value: selectedDepartment,
                        decoration: _buildInputDecoration(
                          label: 'Department',
                          icon: Icons.business,
                        ),
                        items: departments.map((dept) {
                          return DropdownMenuItem(
                            value: dept,
                            child: Text(dept.name),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() => selectedDepartment = value);
                          if (value != null) _loadDesignations(value.id);
                        },
                        validator: (value) => value == null ? 'Department is required' : null,
                      ),

                      const SizedBox(height: 20.0),

                      // --- Designation Dropdown ---
                      DropdownButtonFormField<Designation>(
                        value: selectedDesignation,
                        decoration: _buildInputDecoration(
                          label: 'Designation',
                          icon: Icons.badge,
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
                        validator: (value) => value == null ? 'Designation is required' : null,
                        hint: Text(selectedDepartment == null ? 'Select Department first' : 'Select Designation'),
                      ),

                      const SizedBox(height: 30.0),

                      // --- Upload Image Button and Preview ---
                      TextButton.icon(
                        icon: const Icon(Icons.cloud_upload, size: 28),
                        label: const Text('Upload Profile Image', style: TextStyle(fontSize: 16)),
                        onPressed: pickImage,
                        style: TextButton.styleFrom(
                          foregroundColor: deepPrimary,
                        ),
                      ),

                      // Image Preview (Styled with ClipOval)
                      if (kIsWeb && webImage != null)
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: ClipOval(
                            child: Image.memory(
                              webImage!,
                              height: 120,
                              width: 120,
                              fit: BoxFit.cover,
                            ),
                          ),
                        )
                      else if (!kIsWeb && selectedImage != null)
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: ClipOval(
                            child: Image.file(
                              File(selectedImage!.path),
                              height: 120,
                              width: 120,
                              fit: BoxFit.cover,
                            ),
                          ),
                        )
                      else
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Icon(Icons.account_circle, size: 120, color: Colors.grey.shade300),
                        ),


                      const SizedBox(height: 20.0),

                      // --- Registration Button ---
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _register, // Direct reference to the logic
                          style: ElevatedButton.styleFrom(
                            backgroundColor: deepPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 15.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            elevation: 5,
                          ),
                          child: Text(
                            "Registration",
                            style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              fontFamily: GoogleFonts.lato().fontFamily,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20.0),

                      // --- Login Link ---
                      TextButton(
                        onPressed: () {
                          // Use pushReplacement to navigate and prevent back button issues
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => LoginPage()),
                          );
                        },
                        child: Text(
                          'Already have an account? Login Here',
                          style: TextStyle(
                            color: deepPrimary,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                            decorationColor: deepPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- Widget Helper Functions for consistent styling ---

  InputDecoration _buildInputDecoration({required String label, required IconData icon, String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide(color: deepPrimary, width: 2.0),
      ),
      prefixIcon: Icon(icon, color: deepPrimary),
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required TextInputType keyboardType,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: _buildInputDecoration(label: label, icon: icon),
      keyboardType: keyboardType,
      validator: validator,
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool obscureText,
    required VoidCallback onToggle,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      decoration: _buildInputDecoration(label: label, icon: icon).copyWith(
        suffixIcon: IconButton(
          icon: Icon(
            obscureText ? Icons.visibility : Icons.visibility_off,
            color: deepPrimary,
          ),
          onPressed: onToggle,
        ),
      ),
    );
  }


  // --- Image Picker Logic ---
  Future<void> pickImage() async {
    if (kIsWeb) {
      var pickedImage = await ImagePickerWeb.getImageAsBytes();
      if (pickedImage != null) {
        setState(() {
          webImage = pickedImage;
          selectedImage = null; // Clear mobile/desktop selection
        });
      }
    } else {
      final XFile? pickedImage = await _picker.pickImage(
        source: ImageSource.gallery,
      );
      if (pickedImage != null) {
        setState(() {
          selectedImage = pickedImage;
          webImage = null; // Clear web selection
        });
      }
    }
  }

  // --- Registration Logic ---
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
      if (selectedDepartment == null || selectedDesignation == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Department or Designation cannot be empty.')),
        );
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
