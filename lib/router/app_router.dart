import 'package:go_router/go_router.dart';
import '../screens/home/home_screen.dart';
import '../screens/sqlite/sqlite_screen.dart';
import '../screens/fcm/fcm_screen.dart';
import '../screens/map/map_screen.dart';
import '../screens/map/advanced_map_screen.dart';
import '../screens/minio/minio_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/sqlite',
      name: 'sqlite',
      builder: (context, state) => const SqliteScreen(),
    ),
    GoRoute(
      path: '/fcm',
      name: 'fcm',
      builder: (context, state) => const FcmScreen(),
    ),
    GoRoute(
      path: '/map',
      name: 'map',
      builder: (context, state) => const MapScreen(),
    ),
    GoRoute(
      path: '/map-advanced',
      name: 'map-advanced',
      builder: (context, state) => const AdvancedMapScreen(),
    ),
    GoRoute(
      path: '/minio',
      name: 'minio',
      builder: (context, state) => const MinioScreen(),
    ),
  ],
);
