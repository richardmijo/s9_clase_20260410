import 'package:flutter/material.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  double _zoomLevel = 15.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Módulo Mapas (flutter_map)'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Integración con flutter_map y OpenStreetMap',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'En esta sección cargaremos el widget FlutterMap, configuraremos el TileLayer para el mapa de fondo y colocaremos marcadores interactivos.',
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 16),

            // Map Placeholder
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade300, width: 2),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.map_outlined,
                      size: 64,
                      color: Colors.blue,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Espacio para FlutterMap',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Ubicación: Campus UIDE (Quito)\nZoom: ${_zoomLevel.toStringAsFixed(1)}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.black87),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Mock controls
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      if (_zoomLevel < 18.0) _zoomLevel += 1.0;
                    });
                  },
                  icon: const Icon(Icons.zoom_in),
                  label: const Text('Acercar'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      if (_zoomLevel > 3.0) _zoomLevel -= 1.0;
                    });
                  },
                  icon: const Icon(Icons.zoom_out),
                  label: const Text('Alejar'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Centrando en el Campus UIDE (Simulado)')),
                    );
                  },
                  icon: const Icon(Icons.my_location),
                  label: const Text('Centrar UIDE'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
