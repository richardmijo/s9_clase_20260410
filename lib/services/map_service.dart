import 'package:latlong2/latlong.dart';

// Capa de Datos / Servicio: Abstrae la configuración, coordenadas y lógica del mapa
// fuera de las pantallas (Presentation Layer) siguiendo principios de Arquitectura Limpia.
class MapService {
  // Coordenadas predeterminadas (Campus UIDE en Quito)
  static const LatLng uideCoordinates = LatLng(-0.2095, -78.4358);

  // Mosaicos (Tiles) disponibles para el mapa
  static const Map<String, String> mapStyles = {
    'Estándar (OpenStreetMap)': 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
    'Claro (CartoDB Positron - Grayscale)': 'https://a.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png',
    'Colorido (OSM Hot)': 'https://a.tile.openstreetmap.fr/hot/{z}/{x}/{y}.png',
    'Oscuro (CartoDB Dark Matter)': 'https://a.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png',
  };

  // Retorna la URL del mosaico por defecto
  static String getDefaultTileUrl() {
    return mapStyles.values.first;
  }
}
