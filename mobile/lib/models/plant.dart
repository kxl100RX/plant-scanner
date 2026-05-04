class PlantCare {
  final String water;
  final String light;
  final String soil;
  final String temperature;
  final String humidity;
  final String fertilizer;

  const PlantCare({
    required this.water,
    required this.light,
    required this.soil,
    required this.temperature,
    required this.humidity,
    required this.fertilizer,
  });

  factory PlantCare.fromJson(Map<String, dynamic> json) => PlantCare(
        water: json['water'] ?? '',
        light: json['light'] ?? '',
        soil: json['soil'] ?? '',
        temperature: json['temperature'] ?? '',
        humidity: json['humidity'] ?? '',
        fertilizer: json['fertilizer'] ?? '',
      );
}

class PlantWikipedia {
  final String summary;
  final String image;
  final String url;

  const PlantWikipedia({
    required this.summary,
    required this.image,
    required this.url,
  });

  factory PlantWikipedia.fromJson(Map<String, dynamic> json) => PlantWikipedia(
        summary: json['summary'] ?? '',
        image: json['image'] ?? '',
        url: json['url'] ?? '',
      );
}

class Plant {
  final String name;
  final String scientificName;
  final String confidence;
  final String description;
  final PlantCare care;
  final String toxicity;
  final List<String> tips;
  final PlantWikipedia? wikipedia;

  const Plant({
    required this.name,
    required this.scientificName,
    required this.confidence,
    required this.description,
    required this.care,
    required this.toxicity,
    required this.tips,
    this.wikipedia,
  });

  factory Plant.fromJson(Map<String, dynamic> json) => Plant(
        name: json['name'] ?? 'Planta desconocida',
        scientificName: json['scientific_name'] ?? '',
        confidence: json['confidence'] ?? 'low',
        description: json['description'] ?? '',
        care: PlantCare.fromJson(json['care'] ?? {}),
        toxicity: json['toxicity'] ?? '',
        tips: List<String>.from(json['tips'] ?? []),
        wikipedia: json['wikipedia'] != null
            ? PlantWikipedia.fromJson(json['wikipedia'])
            : null,
      );
}
