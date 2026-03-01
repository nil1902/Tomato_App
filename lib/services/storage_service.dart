import 'dart:io';
import 'dart:convert';
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
          
      // Ensure we use the freshly created bucket for admin images!
      final actualBucketName = bucketName.contains('images') ? 'admin_bucket' : bucketName;
      
      debugPrint('📤 Uploading file: $finalFileName to bucket: $actualBucketName');

      final bytes = await file.readAsBytes();
      final extension = file.name.split('.').last.toLowerCase();
      
      String contentType = 'application/octet-stream';
      if (['jpg', 'jpeg'].contains(extension)) contentType = 'image/jpeg';
      else if (extension == 'png') contentType = 'image/png';
      else if (extension == 'gif') contentType = 'image/gif';
      else if (extension == 'webp') contentType = 'image/webp';

      // ==========================================
      // Step 1: Request Upload Strategy
      // ==========================================
      final strategyUrl = '${ApiConstants.baseUrl}/api/storage/buckets/$actualBucketName/upload-strategy';
      final strategyResponse = await http.post(
        Uri.parse(strategyUrl),
        headers: {
          ..._headers,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'filename': finalFileName,
          'contentType': contentType,
          'size': bytes.length,
        }),
      );

      if (strategyResponse.statusCode != 200 && strategyResponse.statusCode != 201) {
        debugPrint('📤 Strategy Request Failed: ${strategyResponse.statusCode} - ${strategyResponse.body}');
        return null;
      }

      final strategy = jsonDecode(strategyResponse.body);
      final method = strategy['method'];

      // ==========================================
      // Step 2: Perform the actual upload based on method
      // ==========================================
      if (method == 'presigned') {
        // Presigned S3 Upload
        final req = http.MultipartRequest('POST', Uri.parse(strategy['uploadUrl']));
        
        // Add S3 policy fields first!
        if (strategy['fields'] != null) {
          final fieldsMap = Map<String, dynamic>.from(strategy['fields']);
          fieldsMap.forEach((k, v) => req.fields[k] = v.toString());
        }
        
        req.files.add(http.MultipartFile.fromBytes('file', bytes, filename: finalFileName));

        final s3Stream = await req.send();
        final s3Response = await http.Response.fromStream(s3Stream);
        
        if (s3Response.statusCode >= 400) {
          debugPrint('📤 S3 Direct Upload Failed: ${s3Response.statusCode} - ${s3Response.body}');
          return null;
        }

        // ==========================================
        // Step 3: Confirm if required
        // ==========================================
        if (strategy['confirmRequired'] == true && strategy['confirmUrl'] != null) {
          String confirmUrlStr = strategy['confirmUrl'].toString();
          if (!confirmUrlStr.startsWith('http')) {
            confirmUrlStr = '${ApiConstants.baseUrl}$confirmUrlStr';
          }
          
          final confirmResponse = await http.post(
            Uri.parse(confirmUrlStr),
            headers: {
              ..._headers,
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'size': bytes.length,
              'contentType': contentType,
            }),
          );
          
          if (confirmResponse.statusCode >= 400) {
            debugPrint('📤 Upload Confirmation Failed: ${confirmResponse.statusCode} - ${confirmResponse.body}');
            return null;
          }
        }
      } else if (method == 'direct') {
        // Direct API upload
        final req = http.MultipartRequest(
          'POST', 
          Uri.parse('${ApiConstants.baseUrl}/api/storage/buckets/$actualBucketName/objects')
        );
        req.headers.addAll(_headers);
        req.files.add(http.MultipartFile.fromBytes('file', bytes, filename: finalFileName));
        
        final directStream = await req.send();
        final directResponse = await http.Response.fromStream(directStream);
        
        if (directResponse.statusCode >= 400) {
          debugPrint('📤 Direct Upload Failed: ${directResponse.statusCode} - ${directResponse.body}');
          return null;
        }
      } else {
        debugPrint('📤 Unknown upload method: $method');
        return null;
      }

      // If all passed, return the public access URL
      final publicUrl = '${ApiConstants.baseUrl}/api/storage/buckets/$actualBucketName/files/$finalFileName';
      debugPrint('📤 File uploaded successfully! $publicUrl');
      return publicUrl;

    } catch (e) {
      debugPrint('📤 Upload Exception: $e');
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
