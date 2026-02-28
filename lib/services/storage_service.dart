import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'api_constants.dart';

class StorageService {
  final String _accessToken;

  StorageService(this._accessToken);

  Map<String, String> get _headers => {
        'Authorization': 'Bearer $_accessToken',
      };

  /// Upload a file to InsForge storage bucket
  /// Returns the public URL of the uploaded file
  Future<String?> uploadFile({
    required dynamic file,
    required String bucketName,
    String? fileName,
  }) async {
    try {
      // Generate filename if not provided
      final String finalFileName = fileName ?? 
          '${DateTime.now().millisecondsSinceEpoch}_${file.name}';
      
      debugPrint('📤 Uploading file: $finalFileName to bucket: $bucketName');

      // Read file bytes
      final bytes = await file.readAsBytes();
      
      // Determine content type based on file extension
      final extension = file.name.split('.').last.toLowerCase();
      String contentType = 'application/octet-stream';
      if (extension == 'jpg' || extension == 'jpeg') {
        contentType = 'image/jpeg';
      } else if (extension == 'png') {
        contentType = 'image/png';
      } else if (extension == 'gif') {
        contentType = 'image/gif';
      } else if (extension == 'webp') {
        contentType = 'image/webp';
      }

      // Upload to InsForge storage
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/api/storage/buckets/$bucketName/files/$finalFileName'),
        headers: {
          ..._headers,
          'Content-Type': contentType,
        },
        body: bytes,
      );

      debugPrint('📤 Upload Response: ${response.statusCode}');
      debugPrint('📤 Upload Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Construct the public URL
        final publicUrl = '${ApiConstants.baseUrl}/api/storage/buckets/$bucketName/files/$finalFileName';
        debugPrint('📤 File uploaded successfully: $publicUrl');
        return publicUrl;
      } else {
        debugPrint('📤 Upload failed: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('📤 Upload Error: $e');
      return null;
    }
  }

  /// Delete a file from InsForge storage bucket
  Future<bool> deleteFile({
    required String bucketName,
    required String fileName,
  }) async {
    try {
      debugPrint('🗑️ Deleting file: $fileName from bucket: $bucketName');

      final response = await http.delete(
        Uri.parse('${ApiConstants.baseUrl}/api/storage/buckets/$bucketName/files/$fileName'),
        headers: _headers,
      );

      debugPrint('🗑️ Delete Response: ${response.statusCode}');

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      debugPrint('🗑️ Delete Error: $e');
      return false;
    }
  }

  /// Get public URL for a file
  String getFileUrl({
    required String bucketName,
    required String fileName,
  }) {
    return '${ApiConstants.baseUrl}/api/storage/buckets/$bucketName/files/$fileName';
  }

  /// Download file bytes
  Future<Uint8List?> downloadFile({
    required String bucketName,
    required String fileName,
  }) async {
    try {
      debugPrint('📥 Downloading file: $fileName from bucket: $bucketName');

      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/api/storage/buckets/$bucketName/files/$fileName'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        debugPrint('📥 File downloaded successfully');
        return response.bodyBytes;
      } else {
        debugPrint('📥 Download failed: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('📥 Download Error: $e');
      return null;
    }
  }
}
