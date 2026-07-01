import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import '../../services/map_service.dart';        // Importar la capa de datos/servicio del mapa
import 'widgets/map_view_widget.dart';        // Importar la vista modularizada del mapa

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  // Controlador para mover o enfocar el mapa por código
  late final MapController _mapController;

  // Zoom dinámico controlado en pantalla
  double _zoomLevel = 15.0;

  // URL del mosaico actual consumida desde MapService
  String _currentTileUrl = MapService.getDefaultTileUrl();

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  // Mueve la cámara y el zoom al campus de la UIDE consumiendo MapService
  void _centerOnUIDE() {
    _mapController.move(MapService.uideCoordinates, 16.0);
    setState(() {
      _zoomLevel = 16.0;
    });
  }

  // Acerca el mapa mediante código
  void _zoomIn() {
    if (_zoomLevel < 18.0) {
      _zoomLevel += 1.0;
      _mapController.move(_mapController.camera.center, _zoomLevel);
    }
  }

  // Aleja el mapa mediante código
  void _zoomOut() {
    if (_zoomLevel > 3.0) {
      _zoomLevel -= 1.0;
      _mapController.move(_mapController.camera.center, _zoomLevel);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Módulo Mapas (flutter_map)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.explore),
            tooltip: 'Mapa Avanzado',
            onPressed: () => context.push('/map-advanced'),
          ),
        ],
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
              'Arrastra para moverte, usa pellizco para zoom. Puedes alternar el proveedor de mapas y ver cómo se redibujan las coordenadas.',
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 12),

            // Selector del estilo/tipo de mapa consumiendo los estilos del MapService
            Row(
              children: [
                const Icon(Icons.layers, color: Colors.blue),
                const SizedBox(width: 8),
                const Text(
                  'Estilo:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButton<String>(
                    value: _currentTileUrl,
                    isExpanded: true,
                    items: MapService.mapStyles.entries.map((entry) {
                      return DropdownMenuItem<String>(
                        value: entry.value,
                        child: Text(
                          entry.key,
                          style: const TextStyle(fontSize: 13),
                        ),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      if (newValue != null) {
                        setState(() {
                          _currentTileUrl = newValue;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Contenedor principal que renderiza el Mapa real reutilizando MapViewWidget
            Expanded(
              child: MapViewWidget(
                mapController: _mapController,
                center: MapService.uideCoordinates, // Consumido desde MapService
                zoom: _zoomLevel,
                tileUrl: _currentTileUrl,
                onPositionChanged: (camera, hasGesture) {
                  if (hasGesture) {
                    setState(() {
                      _zoomLevel = camera.zoom;
                    });
                  }
                },
                markers: [
                  Marker(
                    point: MapService.uideCoordinates, // Consumido desde MapService
                    width: 60,
                    height: 60,
                    child: GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('¡Bienvenido al Campus UIDE (Quito)!'),
                          ),
                        );
                      },
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 40,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Mostrar el nivel de zoom actual
            Center(
              child: Text(
                'Nivel de Zoom Actual: ${_zoomLevel.toStringAsFixed(1)}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
            const SizedBox(height: 12),

            // Controles programáticos del Mapa (Zoom In, Zoom Out, Centrar)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _zoomIn,
                  icon: const Icon(Icons.zoom_in),
                  label: const Text('Acercar'),
                ),
                ElevatedButton.icon(
                  onPressed: _zoomOut,
                  icon: const Icon(Icons.zoom_out),
                  label: const Text('Alejar'),
                ),
                ElevatedButton.icon(
                  onPressed: _centerOnUIDE,
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
