// المسار: lib/features/projects/cloudinary_service.dart   (ملف جديد)
//
// بيرفع الصور من الموبايل لـ Cloudinary مباشرة (Unsigned upload) ويرجّع رابط https لكل صورة.
// الرابط ده هو اللي بيتخزن في Firestore جوه projects/{id}.images
//
// مهم جداً: مفيش API Secret هنا ولا في أي مكان في التطبيق.
// الـ unsigned upload محتاج بس cloud name + اسم upload preset (مش أسرار).

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

class CloudinaryException implements Exception {
  CloudinaryException(this.message);
  final String message;
  @override
  String toString() => message;
}

class CloudinaryService {
  static const cloudName = 'c3mnpwey';

  /// لازم تعمل Upload Preset بالاسم ده (Unsigned) من لوحة Cloudinary
  static const uploadPreset = 'proven_projects';

  static final _uri =
      Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');

  /// يرفع صورة واحدة ويرجّع secure_url
  Future<String> uploadImage(Uint8List bytes, {required String filename}) async {
    try {
      final request = http.MultipartRequest('POST', _uri)
        ..fields['upload_preset'] = uploadPreset
        ..files.add(
          http.MultipartFile.fromBytes('file', bytes, filename: filename),
        );

      final streamed = await request.send().timeout(const Duration(seconds: 90));
      final body = await streamed.stream.bytesToString();
      final json = jsonDecode(body) as Map<String, dynamic>;

      if (streamed.statusCode != 200) {
        final msg = (json['error'] is Map ? json['error']['message'] : null) ??
            'Upload failed (${streamed.statusCode}).';
        throw CloudinaryException('$msg');
      }
      final url = json['secure_url'];
      if (url is! String || url.isEmpty) {
        throw CloudinaryException('Upload failed: no image URL returned.');
      }
      return url;
    } on CloudinaryException {
      rethrow;
    } on TimeoutException {
      throw CloudinaryException('Upload timed out. Check your internet.');
    } catch (_) {
      throw CloudinaryException('Could not upload the image. Check your internet.');
    }
  }

  /// يرفع كل الصور مع بعض ويحافظ على الترتيب (الأولى = Cover)
  Future<List<String>> uploadAll(List<Uint8List> images) {
    return Future.wait([
      for (var i = 0; i < images.length; i++)
        uploadImage(images[i], filename: 'project_$i.jpg'),
    ]);
  }
}