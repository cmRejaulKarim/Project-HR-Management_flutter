// // lib/utils/image_picker_service_web.dart
// import 'dart:io';
// import 'dart:typed_data';
// import 'image_picker_service.dart';
// import 'package:image_picker_web/image_picker_web.dart';
//
// class ImagePickerServiceWeb implements ImagePickerService {
//   @override
//   Future<Uint8List?> pickImageBytes() async {
//     return await ImagePickerWeb.getImageAsBytes();
//   }
//
//   @override
//   Future<File?> pickImageFile() async {
//     // File is not available on web, so return null
//     return null;
//   }
// }
//
// ImagePickerService getImagePickerService() => ImagePickerServiceWeb();
//
//
//
// // // lib/utils/image_picker_service_web.dart
// // import 'dart:io';
// // import 'dart:typed_data';
// // import 'image_picker_service.dart';
// // import 'package:image_picker_web/image_picker_web.dart';
// //
// // class _ImagePickerServiceWeb implements ImagePickerService {
// //   @override
// //   Future<Uint8List?> pickImageBytes() async {
// //     return await ImagePickerWeb.getImageAsBytes();
// //   }
// //
// //   @override
// //   Future<File?> pickImageFile() async {
// //     // Web does not return File directly
// //     return null;
// //   }
// // }
