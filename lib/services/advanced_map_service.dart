import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../models/landmark.dart';
import '../models/map_route.dart';

class AdvancedMapService {
  // Polígono del Campus de la UIDE (Límites aproximados para fines didácticos)
  static final List<LatLng> uideCampusPolygon = [
    const LatLng(-3.9712, -79.2005),
    const LatLng(-3.9710, -79.1980),
    const LatLng(-3.9730, -79.1982),
    const LatLng(-3.9738, -79.2000),
    const LatLng(-3.9725, -79.2008),
  ];

  // Puntos de interés (Landmarks) en Loja
  static final List<Landmark> landmarks = [
    const Landmark(
      name: 'Campus UIDE Loja',
      coordinates: LatLng(-3.9721857, -79.1992771),
      category: 'academic',
      description: 'Universidad Internacional del Ecuador, extensión Loja.',
    ),
    const Landmark(
      name: 'Parque Recreacional Jipiro',
      coordinates: LatLng(-3.978500, -79.200800),
      category: 'recreation',
      description: 'Famoso parque temático de Loja con réplicas de monumentos mundiales.',
    ),
    const Landmark(
      name: 'Terminal Terrestre Reina del Cisne',
      coordinates: LatLng(-3.975500, -79.208200),
      category: 'transport',
      description: 'Principal terminal de autobuses de enlace provisional y nacional.',
    ),
    const Landmark(
      name: 'Puerta de la Ciudad',
      coordinates: LatLng(-3.989300, -79.202500),
      category: 'culture',
      description: 'Monumento histórico emblemático que simboliza la entrada a la ciudad.',
    ),
    const Landmark(
      name: 'Supermaxi Loja',
      coordinates: LatLng(-3.985200, -79.202800),
      category: 'recreation',
      description: 'Centro comercial y supermercado principal del sector norte.',
    ),
    const Landmark(
      name: 'Parque Central de Loja',
      coordinates: LatLng(-3.999722, -79.203889),
      category: 'culture',
      description: 'Plaza principal rodeada de la Catedral, Municipio y Gobernación.',
    ),
    const Landmark(
      name: 'Catedral Metropolitana de Loja',
      coordinates: LatLng(-3.999400, -79.203600),
      category: 'culture',
      description: 'Una de las iglesias más grandes y hermosas del sur del país.',
    ),
  ];

  // Rutas disponibles
  static final List<MapRoute> routes = [
    MapRoute(
      id: 'ruta_uide_centro',
      name: 'Ruta Académica (UIDE - Parque Central)',
      description: 'Recorrido directo desde el Campus de la UIDE hasta el centro histórico de la ciudad por la Av. Salvador Bustamante Celi.',
      distanceKm: 3.6,
      durationMinutes: 12,
      color: Colors.teal.shade700,
      centerCamera: const LatLng(-3.9859, -79.2015),
      zoomSuggested: 14.2,
      points: [
        const LatLng(-3.9721857, -79.1992771), // UIDE
        const LatLng(-3.975000, -79.199800),
        const LatLng(-3.978200, -79.200500),  // Cerca de Jipiro
        const LatLng(-3.982500, -79.201200),
        const LatLng(-3.987000, -79.201800),  // Cerca de Puerta de la Ciudad
        const LatLng(-3.992200, -79.202300),
        const LatLng(-3.997500, -79.202800),
        const LatLng(-3.999722, -79.203889),  // Parque Central
      ],
    ),
    MapRoute(
      id: 'ruta_uide_terminal',
      name: 'Ruta de Enlace (UIDE - Terminal)',
      description: 'Acceso directo para estudiantes al terminal terrestre, cruzando el sector de Jipiro.',
      distanceKm: 1.8,
      durationMinutes: 6,
      color: Colors.orange.shade800,
      centerCamera: const LatLng(-3.9738, -79.2038),
      zoomSuggested: 15.0,
      points: [
        const LatLng(-3.9721857, -79.1992771), // UIDE
        const LatLng(-3.971500, -79.202000),
        const LatLng(-3.971200, -79.204500),
        const LatLng(-3.973000, -79.206500),
        const LatLng(-3.975500, -79.208200),  // Terminal Terrestre
      ],
    ),
    MapRoute(
      id: 'ruta_uide_puerta',
      name: 'Ruta Turística (UIDE - Puerta Ciudad)',
      description: 'Conexión turística entre el campus norte y la emblemática Puerta de la Ciudad.',
      distanceKm: 2.3,
      durationMinutes: 8,
      color: Colors.purple.shade700,
      centerCamera: const LatLng(-3.9807, -79.2008),
      zoomSuggested: 14.5,
      points: [
        const LatLng(-3.9721857, -79.1992771), // UIDE
        const LatLng(-3.975000, -79.200100),
        const LatLng(-3.978000, -79.201000),
        const LatLng(-3.982000, -79.201500),
        const LatLng(-3.985000, -79.202000),
        const LatLng(-3.989300, -79.202500),  // Puerta de la Ciudad
      ],
    ),
  ];
}
