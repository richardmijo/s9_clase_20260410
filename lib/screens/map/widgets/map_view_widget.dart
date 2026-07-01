import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

// Widget reutilizable que encapsula el mapa para poder usarlo en cualquier pantalla
class MapViewWidget extends StatelessWidget {
  final MapController? mapController;
  final LatLng center;
  final double zoom;
  final String tileUrl;
  final List<Marker> markers;
  final Function(MapCamera camera, bool hasGesture)? onPositionChanged;

  const MapViewWidget({
    super.key,
    this.mapController,
    required this.center,
    required this.zoom,
    required this.tileUrl,
    this.markers = const [],
    this.onPositionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blue.shade200, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: FlutterMap(
          mapController: mapController,
          options: MapOptions(
            initialCenter: center, // Coordenada inicial de centrado
            initialZoom: zoom, // Zoom inicial
            minZoom: 3.0,
            maxZoom: 18.0,
            onPositionChanged:
                onPositionChanged, // Evento de cambio de posición (zoom/arrastre)
          ),
          children: [
            // Capa 1: Mosaico de fondo (TileLayer)
            TileLayer(
              urlTemplate: tileUrl,
              userAgentPackageName: 'ec.edu.uide.s9_clase_20260410',
            ),
            // Capa 2: Dibujo de marcadores/pines en el mapa (MarkerLayer)
            if (markers.isNotEmpty) MarkerLayer(markers: markers),
          ],
        ),
      ),
    );
  }
}
