import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../models/plant.dart';

class PlantService {
  static String get _base {
    if (kIsWeb) {
      final origin = Uri.base.origin;
      // In dev (localhost), forward to the local backend
      if (origin.contains('localhost') || origin.contains('127.0.0.1')) {
        return 'http://localhost:8000';
      }
      return origin; // Production: same host serves the API
    }
    return 'https://plant-scanner-d8hg.onrender.com'; // APK production URL
  }

  static Future<Plant> identify(XFile imageFile) async {
    final req = http.MultipartRequest('POST', Uri.parse('$_base/identify'));

    if (kIsWeb) {
      final bytes = await imageFile.readAsBytes();
      req.files.add(http.MultipartFile.fromBytes('file', bytes, filename: imageFile.name));
    } else {
      req.files.add(await http.MultipartFile.fromPath('file', imageFile.path));
    }

    final streamed = await req.send().timeout(const Duration(seconds: 40));
    final res = await http.Response.fromStream(streamed);

    if (res.statusCode != 200) throw Exception('Error del servidor: ${res.statusCode}');

    final json = jsonDecode(res.body) as Map<String, dynamic>;
    if (json['error'] != null) throw Exception(json['error']);

    return Plant.fromJson(json);
  }
}
