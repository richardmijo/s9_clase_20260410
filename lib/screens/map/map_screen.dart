import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart'; // Importar biblioteca flutter_map
import 'package:latlong2/latlong.dart';       // Importar biblioteca latlong2 para coordenadas LatLng

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  // Controlador del mapa para realizar acciones por código (como mover o hacer zoom)
  late final MapController _mapController;

  // Coordenadas geográficas del Campus UIDE (Quito, Ecuador)
  final LatLng _uideCoords = const LatLng(-0.2095, -78.4358);

  // Zoom inicial del mapa
  double _zoomLevel = 15.0;

  // URL base de los mosaicos del mapa. Por defecto usamos OpenStreetMap.
  String _currentTileUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

  /*
   * EXPLICACIÓN PEDAGÓGICA PARA CLASE:
   * Los mapas en flutter_map se cargan en cuadritos o imágenes llamadas "tiles" (mosaicos).
   * La URL del servidor contiene 3 variables obligatorias:
   * - {z}: Zoom actual.
   * - {x}: Posición horizontal del mosaico.
   * - {y}: Posición vertical del mosaico.
   *
   * Aquí definimos diferentes servidores/estilos para que los estudiantes vean
   * cómo cambia el aspecto del mapa cambiando una sola URL.
   */
  final Map<String, String> _mapStyles = {
    'Estándar (OpenStreetMap)': 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
    'Claro (CartoDB Positron - ¡Ideal para proyectores!)': 'https://a.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png',
    'Colorido (OSM Hot)': 'https://a.tile.openstreetmap.fr/hot/{z}/{x}/{y}.png',
    'Oscuro (CartoDB Dark Matter)': 'https://a.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png',
  };

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

  // Mueve la cámara y el zoom al campus de la UIDE
  void _centerOnUIDE() {
    _mapController.move(_uideCoords, 16.0);
    setState(() {
      _zoomLevel = 16.0;
    });
  }

  // Incrementa el zoom actual mediante código
  void _zoomIn() {
    if (_zoomLevel < 18.0) {
      _zoomLevel += 1.0;
      _mapController.move(_mapController.camera.center, _zoomLevel);
    }
  }

  // Reduce el zoom actual mediante código
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

            // Selector del estilo/tipo de mapa
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
                    items: _mapStyles.entries.map((entry) {
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

            // Contenedor principal que renderiza el Mapa real de FlutterMap
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blue.shade200, width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: _uideCoords, // Punto de inicio
                      initialZoom: _zoomLevel,    // Zoom de inicio
                      minZoom: 3.0,
                      maxZoom: 18.0,
                      onPositionChanged: (position, hasGesture) {
                        if (hasGesture) {
                          setState(() {
                            _zoomLevel = position.zoom;
                          });
                        }
                      },
                    ),
                    children: [
                      // 1. Capa de Mosaicos (Carga el mapa visual de fondo)
                      TileLayer(
                        urlTemplate: _currentTileUrl, // URL del servidor de mapas
                        userAgentPackageName: 'ec.edu.uide.s9_clase_20260410', // Identificación obligatoria
                      ),

                      // 2. Capa de Marcadores (Puntos/Pines de geolocalización)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: _uideCoords,
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
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Mostrar el nivel de zoom actual para los estudiantes
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
