// // lib/utils/image_picker_service_mobile.dart
// import 'dart:typed_data';
// import 'dart:io';
// import 'package:image_picker/image_picker.dart';
//
// import 'image_picker_service.dart';
//
// class ImagePickerServiceMobile implements ImagePickerService {
//   final ImagePicker _picker = ImagePicker();
//
//   @override
//   Future<File?> pickImageFile() async {
//     final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);
//     return picked != null ? File(picked.path) : null;
//   }
//
//   @override
//   Future<Uint8List?> pickImageBytes() async {
//     final file = await pickImageFile();
//     return file?.readAsBytes();
//   }
// }
//
// ImagePickerService getImagePickerService() => ImagePickerServiceMobile();
//
//
// // // lib/utils/image_picker_service_mobile.dart
// // import 'dart:io';
// // import 'package:image_picker/image_picker.dart';
// // import 'image_picker_service.dart';
// //
// // class _ImagePickerServiceMobile implements ImagePickerService {
// //   final ImagePicker _picker = ImagePicker();
// //
// //   @override
// //   Future<File?> pickImageFile() async {
// //     final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);
// //     return picked != null ? File(picked.path) : null;
// //   }
// //
// //   @override
// //   Future<List<int>?> pickImageBytes() async {
// //     final file = await pickImageFile();
// //     return file?.readAsBytes();
// //   }
// // }
