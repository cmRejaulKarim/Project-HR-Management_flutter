// import 'dart:typed_data';
// import 'dart:io' if (dart.library.html) 'dart:html'; // Required for conditional platform detection
//
// import 'image_picker_service_mobile.dart'
// if (dart.library.html) 'image_picker_service_web.dart';
//
// /// Abstract class defining the image picking contract
// abstract class ImagePickerService {
//   Future<File?> pickImageFile();
//   Future<Uint8List?> pickImageBytes();
//
//   // This factory chooses the right implementation depending on platform
//   factory ImagePickerService() => getImagePickerService();
// }
//
//
// // // lib/utils/image_picker_service.dart
// // import 'dart:typed_data';
// // import 'dart:io';
// // import 'package:flutter/foundation.dart';
// // import 'image_picker_service_web.dart'
// // if (dart.library.io) 'image_picker_service_mobile.dart';
// //
// //
// // abstract class ImagePickerService {
// //   Future<File?> pickImageFile();
// //   Future<Uint8List?> pickImageBytes();
// //
// //   factory ImagePickerService() {
// //     if (kIsWeb) {
// //       return _ImagePickerServiceWeb();
// //     } else {
// //       return _ImagePickerServiceMobile();
// //     }
// //   }
// // }
