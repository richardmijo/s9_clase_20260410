import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../models/landmark.dart';
import '../../models/map_route.dart';
import '../../services/advanced_map_service.dart';
import '../../services/map_service.dart';

class AdvancedMapScreen extends StatefulWidget {
  const AdvancedMapScreen({super.key});

  @override
  State<AdvancedMapScreen> createState() => _AdvancedMapScreenState();
}

class _AdvancedMapScreenState extends State<AdvancedMapScreen> {
  late final MapController _mapController;

  MapRoute? _selectedRoute;
  String _currentTileUrl = MapService.getDefaultTileUrl();
  double _zoomLevel = 14.0;

  // Capas visibles
  bool _showRoutes = true;
  bool _showLandmarks = true;
  bool _showCampusPolygon = true;
  bool _showCoverageCircle = true;

  // Filtro de categorías
  String _selectedCategory = 'all';

  // Simulación
  Timer? _simulationTimer;
  int _currentSimIndex = 0;
  bool _isSimulating = false;
  LatLng? _simulatedPosition;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  @override
  void dispose() {
    _simulationTimer?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  void _selectRoute(MapRoute route) {
    setState(() {
      _selectedRoute = route;
      _zoomLevel = route.zoomSuggested;
    });
    _mapController.move(route.centerCamera, route.zoomSuggested);
    _stopSimulation();
  }

  void _startSimulation() {
    if (_selectedRoute == null || _selectedRoute!.points.isEmpty) return;
    _stopSimulation();
    setState(() {
      _isSimulating = true;
      _currentSimIndex = 0;
      _simulatedPosition = _selectedRoute!.points[0];
    });

    _simulationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_currentSimIndex < _selectedRoute!.points.length - 1) {
        setState(() {
          _currentSimIndex++;
          _simulatedPosition = _selectedRoute!.points[_currentSimIndex];
        });
        _mapController.move(_simulatedPosition!, _zoomLevel);
      } else {
        _stopSimulation();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Simulación de recorrido finalizada con éxito.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    });
  }

  void _stopSimulation() {
    _simulationTimer?.cancel();
    _simulationTimer = null;
    setState(() {
      _isSimulating = false;
      _simulatedPosition = null;
      _currentSimIndex = 0;
    });
  }

  List<Landmark> get _filteredLandmarks {
    if (_selectedCategory == 'all') {
      return AdvancedMapService.landmarks;
    }
    return AdvancedMapService.landmarks
        .where((l) => l.category == _selectedCategory)
        .toList();
  }

  Widget _getCategoryIcon(String category) {
    switch (category) {
      case 'academic':
        return const Icon(Icons.school, color: Colors.blue);
      case 'transport':
        return const Icon(Icons.directions_bus, color: Colors.orange);
      case 'recreation':
        return const Icon(Icons.local_play, color: Colors.green);
      case 'culture':
        return const Icon(Icons.museum, color: Colors.teal);
      default:
        return const Icon(Icons.location_on, color: Colors.red);
    }
  }

  Widget _getMarkerWidget(String category, bool isUide) {
    Color markerColor;
    IconData iconData;

    if (isUide) {
      markerColor = Colors.red.shade700;
      iconData = Icons.account_balance;
    } else {
      switch (category) {
        case 'academic':
          markerColor = Colors.blue.shade600;
          iconData = Icons.school;
          break;
        case 'transport':
          markerColor = Colors.orange.shade700;
          iconData = Icons.directions_bus;
          break;
        case 'recreation':
          markerColor = Colors.green.shade600;
          iconData = Icons.star;
          break;
        case 'culture':
          markerColor = Colors.teal.shade600;
          iconData = Icons.museum;
          break;
        default:
          markerColor = Colors.red.shade500;
          iconData = Icons.location_on;
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: markerColor,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Icon(iconData, color: Colors.white, size: isUide ? 22 : 18),
    );
  }

  void _showLayersBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 50,
                      height: 5,
                      margin: const EdgeInsets.only(bottom: 15),
                      decoration: const BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                    ),
                  ),
                  const Text(
                    'Configuración de Capas',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    title: const Text('Ver trazados de rutas'),
                    value: _showRoutes,
                    onChanged: (val) {
                      setState(() => _showRoutes = val);
                      setSheetState(() {});
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Ver puntos de interés (Landmarks)'),
                    value: _showLandmarks,
                    onChanged: (val) {
                      setState(() => _showLandmarks = val);
                      setSheetState(() {});
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Ver geocerca del Campus UIDE'),
                    value: _showCampusPolygon,
                    onChanged: (val) {
                      setState(() => _showCampusPolygon = val);
                      setSheetState(() {});
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Ver radio de cobertura UIDE (800m)'),
                    value: _showCoverageCircle,
                    onChanged: (val) {
                      setState(() => _showCoverageCircle = val);
                      setSheetState(() {});
                    },
                  ),
                  const Divider(height: 24),
                  const Text(
                    'Estilo del Plano (Mapa)',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  DropdownButton<String>(
                    value: _currentTileUrl,
                    isExpanded: true,
                    items: MapService.mapStyles.entries.map((entry) {
                      return DropdownMenuItem<String>(
                        value: entry.value,
                        child: Text(entry.key),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      if (newValue != null) {
                        setState(() => _currentTileUrl = newValue);
                        setSheetState(() {});
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCategoryFilters() {
    final categories = {
      'all': 'Todos',
      'academic': 'Academia',
      'recreation': 'Recreación',
      'transport': 'Transporte',
      'culture': 'Cultura',
    };
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: categories.entries.map((entry) {
          final isSelected = _selectedCategory == entry.key;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: FilterChip(
              label: Text(entry.value),
              selected: isSelected,
              selectedColor: Colors.blue.shade100,
              checkmarkColor: Colors.blue.shade900,
              onSelected: (selected) {
                setState(() {
                  _selectedCategory = selected ? entry.key : 'all';
                });
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFloatingControls() {
    return Positioned(
      right: 16,
      top: 120,
      child: Column(
        children: [
          FloatingActionButton.small(
            heroTag: 'layersBtn',
            backgroundColor: Colors.white,
            foregroundColor: Colors.blue.shade900,
            onPressed: _showLayersBottomSheet,
            child: const Icon(Icons.layers),
          ),
          const SizedBox(height: 8),
          FloatingActionButton.small(
            heroTag: 'zoomInBtn',
            backgroundColor: Colors.white,
            foregroundColor: Colors.blue.shade900,
            onPressed: () {
              setState(() {
                _zoomLevel = (_zoomLevel + 1).clamp(3.0, 18.0);
              });
              _mapController.move(_mapController.camera.center, _zoomLevel);
            },
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 8),
          FloatingActionButton.small(
            heroTag: 'zoomOutBtn',
            backgroundColor: Colors.white,
            foregroundColor: Colors.blue.shade900,
            onPressed: () {
              setState(() {
                _zoomLevel = (_zoomLevel - 1).clamp(3.0, 18.0);
              });
              _mapController.move(_mapController.camera.center, _zoomLevel);
            },
            child: const Icon(Icons.remove),
          ),
          const SizedBox(height: 8),
          FloatingActionButton.small(
            heroTag: 'centerBtn',
            backgroundColor: Colors.white,
            foregroundColor: Colors.blue.shade900,
            onPressed: () {
              _mapController.move(MapService.uideCoordinates, 15.0);
              setState(() {
                _zoomLevel = 15.0;
              });
            },
            child: const Icon(Icons.my_location),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoColumn(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: Colors.blueGrey, size: 20),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Colors.black54),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildActiveRouteCard() {
    final route = _selectedRoute!;
    return Card(
      elevation: 8,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [Colors.white, Colors.blue.shade50.withOpacity(0.8)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.directions, color: route.color, size: 28),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    route.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    setState(() {
                      _selectedRoute = null;
                      _stopSimulation();
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              route.description,
              style: const TextStyle(fontSize: 12, color: Colors.black87),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildInfoColumn(
                  Icons.route,
                  'Distancia',
                  '${route.distanceKm.toStringAsFixed(1)} km',
                ),
                _buildInfoColumn(
                  Icons.timer,
                  'Tiempo aprox.',
                  '${route.durationMinutes} min',
                ),
                _buildInfoColumn(Icons.traffic, 'Estado', 'Despejado'),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isSimulating
                        ? _stopSimulation
                        : _startSimulation,
                    icon: Icon(_isSimulating ? Icons.stop : Icons.play_arrow),
                    label: Text(
                      _isSimulating
                          ? 'Detener Simulación'
                          : 'Simular Recorrido',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isSimulating
                          ? Colors.red
                          : Colors.blue.shade800,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (_isSimulating && _simulatedPosition != null) ...[
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'Vehículo en punto ${_currentSimIndex + 1} de ${route.points.length}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade900,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: _currentSimIndex / (route.points.length - 1),
                backgroundColor: Colors.grey.shade300,
                color: route.color,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRouteSelectorCarousel() {
    return Container(
      height: 130,
      margin: const EdgeInsets.only(bottom: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: AdvancedMapService.routes.length,
        itemBuilder: (context, index) {
          final route = AdvancedMapService.routes[index];
          return Container(
            width: 260,
            margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                onTap: () => _selectRoute(route),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.directions, color: route.color, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              route.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        route.description,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.black54,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${route.distanceKm} km',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: route.color,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            '${route.durationMinutes} min',
                            style: const TextStyle(fontSize: 11),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mapa Sofisticado (UIDE)')),
      body: Stack(
        children: [
          // 1. Capa de Mapa
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: MapService.uideCoordinates,
              initialZoom: _zoomLevel,
              minZoom: 3.0,
              maxZoom: 18.0,
              onPositionChanged: (camera, hasGesture) {
                if (hasGesture) {
                  setState(() {
                    _zoomLevel = camera.zoom;
                  });
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: _currentTileUrl,
                userAgentPackageName: 'ec.edu.uide.s9_clase_20260410',
              ),
              if (_showCampusPolygon)
                PolygonLayer(
                  polygons: <Polygon<Object>>[
                    Polygon<Object>(
                      points: AdvancedMapService.uideCampusPolygon,
                      color: Colors.blue.withOpacity(0.15),
                      borderColor: Colors.blue,
                      borderStrokeWidth: 3,
                    ),
                  ],
                ),
              if (_showCoverageCircle)
                CircleLayer(
                  circles: [
                    CircleMarker(
                      point: MapService.uideCoordinates,
                      color: Colors.green.withOpacity(0.12),
                      borderColor: Colors.green.shade600,
                      borderStrokeWidth: 2,
                      useRadiusInMeter: true,
                      radius: 800,
                    ),
                  ],
                ),
              if (_showRoutes)
                PolylineLayer(
                  polylines: AdvancedMapService.routes.map((route) {
                    final isSelected = _selectedRoute?.id == route.id;
                    if (_selectedRoute == null) {
                      return Polyline(
                        points: route.points,
                        color: route.color.withOpacity(0.5),
                        strokeWidth: 4.0,
                      );
                    } else if (isSelected) {
                      return Polyline(
                        points: route.points,
                        color: route.color,
                        strokeWidth: 6.0,
                      );
                    } else {
                      return Polyline(
                        points: route.points,
                        color: Colors.grey.withOpacity(0.2),
                        strokeWidth: 2.0,
                      );
                    }
                  }).toList(),
                ),
              if (_showLandmarks)
                MarkerLayer(
                  markers: [
                    if (_isSimulating && _simulatedPosition != null)
                      Marker(
                        point: _simulatedPosition!,
                        width: 50,
                        height: 50,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.indigo.shade900,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black38,
                                blurRadius: 6,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.directions_car,
                            color: Colors.white,
                            size: 26,
                          ),
                        ),
                      ),
                    ..._filteredLandmarks.map((l) {
                      final isUide =
                          l.coordinates == MapService.uideCoordinates;
                      return Marker(
                        point: l.coordinates,
                        width: 44,
                        height: 44,
                        child: GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Row(
                                  children: [
                                    _getCategoryIcon(l.category),
                                    const SizedBox(width: 8),
                                    Expanded(child: Text(l.name)),
                                  ],
                                ),
                                content: Text(l.description),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Cerrar'),
                                  ),
                                  if (isUide)
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        _mapController.move(
                                          l.coordinates,
                                          16.0,
                                        );
                                      },
                                      child: const Text('Enfocar UIDE'),
                                    ),
                                ],
                              ),
                            );
                          },
                          child: _getMarkerWidget(l.category, isUide),
                        ),
                      );
                    }).toList(),
                  ],
                ),
            ],
          ),

          // 2. Chips de Filtrado (Parte Superior)
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                margin: const EdgeInsets.only(top: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: _buildCategoryFilters(),
              ),
            ),
          ),

          // 3. Controles Flotantes
          _buildFloatingControls(),

          // 4. Panel de Ruta o Carrusel de Selección (Parte Inferior)
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              child: _selectedRoute != null
                  ? _buildActiveRouteCard()
                  : _buildRouteSelectorCarousel(),
            ),
          ),
        ],
      ),
    );
  }
}
