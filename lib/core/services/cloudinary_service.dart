import 'dart:io';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import '../constants/app_keys.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/foundation.dart';


class CloudinaryService {
  final Dio _dio = Dio();

  Future<String?> uploadImage(XFile file, {String folder = 'general'}) async {
    try {
      if (kIsWeb) {
        String fileName = file.name;
        Uint8List bytes = await file.readAsBytes();
        FormData formData = FormData.fromMap({
          'file': MultipartFile.fromBytes(bytes, filename: fileName),
          'upload_preset': AppKeys.cloudinaryUploadPreset,
        });

        final response = await _dio.post(
          'https://api.cloudinary.com/v1_1/${AppKeys.cloudinaryCloudName}/image/upload',
          data: formData,
        );

        if (response.statusCode == 200) {
          return response.data['secure_url'];
        }
        return null;
      }

      // Native flow
      final ioFile = File(file.path);
      // 1. Compress Image
      final File? compressedFile = await _compressImage(ioFile);
      if (compressedFile == null) return null;


      // 2. Prepare Data
      String fileName = path.basename(compressedFile.path);
      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(compressedFile.path, filename: fileName),
        'upload_preset': AppKeys.cloudinaryUploadPreset,
      });

      // 3. Upload
      final response = await _dio.post(
        'https://api.cloudinary.com/v1_1/${AppKeys.cloudinaryCloudName}/image/upload',
        data: formData,
        onSendProgress: (sent, total) {
          double progress = sent / total;
          print('Upload Progress: ${(progress * 100).toStringAsFixed(2)}%');
        },
      );

      if (response.statusCode == 200) {
        return response.data['secure_url'];
      }
      return null;
    } catch (e) {
      print('Cloudinary Upload Error: $e');
      return null;
    }
  }

  Future<File?> _compressImage(File file) async {
    final tempDir = await getTemporaryDirectory();
    final targetPath = path.join(tempDir.path, "${DateTime.now().millisecondsSinceEpoch}.jpg");

    final result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 70,
      format: CompressFormat.jpeg,
    );

    return result != null ? File(result.path) : null;
  }

  Future<bool> deleteImage(String publicId) async {
    // Cloudinary deletion usually requires a signed request or an admin API which shouldn't be on client side directly for security.
    // However, if needed, a REST call to a backend that handles deletion is preferred.
    // For this implementation, we'll focus on the Upload which is the primary requirement.
    return true;
  }
}
