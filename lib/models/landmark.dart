import 'package:latlong2/latlong.dart';

class Landmark {
  final String name;
  final LatLng coordinates;
  final String category; // 'academic', 'culture', 'transport', 'recreation'
  final String description;

  const Landmark({
    required this.name,
    required this.coordinates,
    required this.category,
    required this.description,
  });
}
