import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class MapRoute {
  final String id;
  final String name;
  final String description;
  final List<LatLng> points;
  final double distanceKm;
  final int durationMinutes;
  final Color color;
  final LatLng centerCamera;
  final double zoomSuggested;

  const MapRoute({
    required this.id,
    required this.name,
    required this.description,
    required this.points,
    required this.distanceKm,
    required this.durationMinutes,
    required this.color,
    required this.centerCamera,
    required this.zoomSuggested,
  });
}
