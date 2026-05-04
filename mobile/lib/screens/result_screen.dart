import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../models/plant.dart';

class ResultScreen extends StatelessWidget {
  final Plant plant;
  final String imagePath;

  const ResultScreen({super.key, required this.plant, required this.imagePath});

  void _share() {
    final cLabel = plant.confidence == 'high' ? 'Alta' : plant.confidence == 'medium' ? 'Media' : 'Baja';
    final text = '''
🌿 ${plant.name}
🔬 ${plant.scientificName}
📊 Confianza: $cLabel

${plant.description}

💧 Agua: ${plant.care.water}
☀️ Luz: ${plant.care.light}
🌡 Temperatura: ${plant.care.temperature}

Identificado con Plant Scanner 🌱
'''.trim();
    Share.share(text, subject: 'Planta identificada: ${plant.name}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),
      body: CustomScrollView(
        slivers: [
          _appBar(context),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _headerCard(),
                const SizedBox(height: 12),
                _card('Descripción', Icons.info_outline, _description()),
                const SizedBox(height: 12),
                _card('Cuidados', Icons.spa, _care()),
                const SizedBox(height: 12),
                _toxicityCard(),
                if (plant.tips.isNotEmpty) ...[const SizedBox(height: 12), _card('Tips', Icons.tips_and_updates, _tips())],
                if ((plant.wikipedia?.summary ?? '').isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _card('Wikipedia', Icons.menu_book, _wiki()),
                ],
                const SizedBox(height: 12),
                _shareButton(),
                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  SliverAppBar _appBar(BuildContext context) => SliverAppBar(
        expandedHeight: 280,
        pinned: true,
        backgroundColor: const Color(0xFF2E7D32),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: _share,
            tooltip: 'Compartir',
          ),
        ],
        flexibleSpace: FlexibleSpaceBar(
          background: Stack(
            fit: StackFit.expand,
            children: [
              kIsWeb
                  ? Image.network(imagePath, fit: BoxFit.cover)
                  : Image.file(File(imagePath), fit: BoxFit.cover),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.transparent, Colors.black.withOpacity(0.4)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ],
          ),
        ),
      );

  Widget _headerCard() {
    final cColor = plant.confidence == 'high'
        ? Colors.green
        : plant.confidence == 'medium'
            ? Colors.orange
            : Colors.red;
    final cLabel = plant.confidence == 'high' ? 'Alta' : plant.confidence == 'medium' ? 'Media' : 'Baja';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(
              child: Text(plant.name,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20))),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: cColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: cColor),
              ),
              child: Text(cLabel, style: TextStyle(color: cColor, fontWeight: FontWeight.bold, fontSize: 12)),
            ),
          ]),
          const SizedBox(height: 4),
          Text(plant.scientificName,
              style: const TextStyle(fontSize: 14, color: Colors.grey, fontStyle: FontStyle.italic)),
        ]),
      ),
    );
  }

  Widget _card(String title, IconData icon, Widget content) => Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Icon(icon, color: const Color(0xFF2E7D32)),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ]),
            const Divider(),
            content,
          ]),
        ),
      );

  Widget _description() => Text(plant.description, style: const TextStyle(fontSize: 14, height: 1.5));

  Widget _care() => Column(children: [
        _careRow(Icons.water_drop, 'Agua', plant.care.water, Colors.blue),
        _careRow(Icons.wb_sunny, 'Luz', plant.care.light, Colors.amber),
        _careRow(Icons.grass, 'Suelo', plant.care.soil, Colors.brown),
        _careRow(Icons.thermostat, 'Temperatura', plant.care.temperature, Colors.orange),
        _careRow(Icons.opacity, 'Humedad', plant.care.humidity, Colors.teal),
        _careRow(Icons.science, 'Fertilizante', plant.care.fertilizer, Colors.green),
      ]);

  Widget _careRow(IconData icon, String label, String value, Color color) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              Text(value, style: const TextStyle(fontSize: 13, color: Colors.grey)),
            ]),
          ),
        ]),
      );

  Widget _toxicityCard() {
    final toxic = plant.toxicity.toLowerCase().contains('tóxico') || plant.toxicity.toLowerCase().contains('toxic');
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: toxic ? Colors.red.shade50 : Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(children: [
          Icon(toxic ? Icons.warning_amber : Icons.check_circle,
              color: toxic ? Colors.red : Colors.green, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Toxicidad',
                  style: TextStyle(fontWeight: FontWeight.bold, color: toxic ? Colors.red : Colors.green)),
              Text(plant.toxicity, style: const TextStyle(fontSize: 13)),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _tips() => Column(
        children: plant.tips.asMap().entries.map((e) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: 24, height: 24,
              alignment: Alignment.center,
              decoration: const BoxDecoration(color: Color(0xFF2E7D32), shape: BoxShape.circle),
              child: Text('${e.key + 1}',
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(e.value, style: const TextStyle(fontSize: 13))),
          ]),
        )).toList(),
      );

  Widget _wiki() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (plant.wikipedia!.image.isNotEmpty) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              plant.wikipedia!.image,
              height: 150, width: double.infinity, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const SizedBox(),
            ),
          ),
          const SizedBox(height: 12),
        ],
        Text(plant.wikipedia!.summary,
            style: const TextStyle(fontSize: 13, height: 1.5), maxLines: 6, overflow: TextOverflow.ellipsis),
      ]);

  Widget _shareButton() => SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: _share,
          icon: const Icon(Icons.share),
          label: const Text('Compartir resultado'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2E7D32),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      );
}
