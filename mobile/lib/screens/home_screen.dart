import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/plant.dart';
import '../services/plant_service.dart';
import 'result_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _loading = false;
  final _picker = ImagePicker();

  Future<void> _scan(ImageSource source) async {
    final xfile = await _picker.pickImage(source: source, maxWidth: 1024, maxHeight: 1024, imageQuality: 85);
    if (xfile == null) return;

    setState(() => _loading = true);
    try {
      final plant = await PlantService.identify(xfile);
      if (!mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ResultScreen(plant: plant, imagePath: xfile.path)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),
      body: SafeArea(
        child: Column(
          children: [
            _header(),
            Expanded(child: _body()),
            _buttons(),
          ],
        ),
      ),
    );
  }

  Widget _header() => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1B5E20), Color(0xFF4CAF50)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: const Column(
          children: [
            Icon(Icons.eco, color: Colors.white, size: 64),
            SizedBox(height: 8),
            Text('Plant Scanner', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text('Identificá cualquier planta al instante', style: TextStyle(color: Colors.white70, fontSize: 14)),
          ],
        ),
      );

  Widget _body() {
    if (_loading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFF2E7D32)),
            SizedBox(height: 16),
            Text('Identificando planta...', style: TextStyle(color: Color(0xFF2E7D32), fontSize: 16)),
          ],
        ),
      );
    }
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.green.withOpacity(0.2), blurRadius: 24, spreadRadius: 6)],
            ),
            child: const Icon(Icons.local_florist, size: 96, color: Color(0xFF4CAF50)),
          ),
          const SizedBox(height: 32),
          const Text('¿Qué planta es esta?',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20))),
          const SizedBox(height: 8),
          const Text('Sacá una foto o elegí una de tu galería',
              style: TextStyle(fontSize: 14, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buttons() => Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            Expanded(child: _btn(Icons.camera_alt, 'Cámara', ImageSource.camera, filled: true)),
            const SizedBox(width: 16),
            Expanded(child: _btn(Icons.photo_library, 'Galería', ImageSource.gallery, filled: false)),
          ],
        ),
      );

  Widget _btn(IconData icon, String label, ImageSource source, {required bool filled}) => ElevatedButton.icon(
        onPressed: _loading ? null : () => _scan(source),
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: filled ? const Color(0xFF2E7D32) : Colors.white,
          foregroundColor: filled ? Colors.white : const Color(0xFF2E7D32),
          padding: const EdgeInsets.symmetric(vertical: 16),
          side: filled ? null : const BorderSide(color: Color(0xFF2E7D32), width: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
}
