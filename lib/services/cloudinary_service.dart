import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class CloudinaryService {
  static const String _cloudName = 'drno3xmuy';
  static const String _uploadPreset = 'my_unsigned_preset';
  static const String _cloudinaryUrl =
      'https://api.cloudinary.com/v1_1/$_cloudName/image/upload';

  Future<String?> uploadImage(File imageFile) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse(_cloudinaryUrl));

      request.fields['upload_preset'] = _uploadPreset;
      request.files.add(
        await http.MultipartFile.fromPath('file', imageFile.path),
      );

      final response = await request.send();
      final responseData = await http.Response.fromStream(response);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(responseData.body);
        return data['secure_url'];
      } else {
        print('Cloudinary Upload Error: ${responseData.body}');
        return null;
      }
    } catch (e) {
      print('Cloudinary Service Error: $e');
      return null;
    }
  }
}
