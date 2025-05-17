import 'dart:math';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationCluster {
  final List<LatLng> points;
  final LatLng center;
  final int size;

  LocationCluster({
    required this.points,
    required this.center,
    required this.size,
  });
}

class ClusteringService {
  static const double _earthRadius = 6371.0; // Earth's radius in kilometers
  static const double _epsilon = 1.5; // 1.5 km radius for clustering
  static const int _minPoints = 2; // Minimum points to form a cluster

  // Calculate distance between two points using Haversine formula
  static double _calculateDistance(LatLng point1, LatLng point2) {
    final lat1 = point1.latitude * pi / 180;
    final lon1 = point1.longitude * pi / 180;
    final lat2 = point2.latitude * pi / 180;
    final lon2 = point2.longitude * pi / 180;

    final dLat = lat2 - lat1;
    final dLon = lon2 - lon1;

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return _earthRadius * c;
  }

  // Find neighbors within epsilon distance
  static List<int> _getNeighbors(List<LatLng> points, int pointIndex, double epsilon) {
    List<int> neighbors = [];
    for (int i = 0; i < points.length; i++) {
      if (i != pointIndex &&
          _calculateDistance(points[pointIndex], points[i]) <= epsilon) {
        neighbors.add(i);
      }
    }
    return neighbors;
  }

  // DBSCAN clustering algorithm
  static List<LocationCluster> clusterLocations(List<LatLng> points) {
    if (points.isEmpty) return [];

    List<int> labels = List.filled(points.length, -1);
    int currentCluster = 0;

    // For each point
    for (int i = 0; i < points.length; i++) {
      if (labels[i] != -1) continue;

      List<int> neighbors = _getNeighbors(points, i, _epsilon);

      if (neighbors.length < _minPoints - 1) {
        labels[i] = -1; // Mark as noise
        continue;
      }

      // Start a new cluster
      labels[i] = currentCluster;

      // Process neighbors
      List<int> seedSet = List.from(neighbors);
      int seedIndex = 0;

      while (seedIndex < seedSet.length) {
        int currentPoint = seedSet[seedIndex];

        // Point was previously marked as noise
        if (labels[currentPoint] == -1) {
          labels[currentPoint] = currentCluster;
        }
        // Point was not yet processed
        else if (labels[currentPoint] == -1) {
          labels[currentPoint] = currentCluster;
          List<int> currentNeighbors = _getNeighbors(points, currentPoint, _epsilon);

          if (currentNeighbors.length >= _minPoints - 1) {
            seedSet.addAll(currentNeighbors.where((n) => !seedSet.contains(n)));
          }
        }

        seedIndex++;
      }

      currentCluster++;
    }

    // Group points into clusters
    Map<int, List<LatLng>> clusters = {};
    for (int i = 0; i < points.length; i++) {
      if (labels[i] != -1) {
        clusters.putIfAbsent(labels[i], () => []).add(points[i]);
      }
    }

    // Create LocationCluster objects
    return clusters.entries.map((entry) {
      final clusterPoints = entry.value;
      final center = LatLng(
        clusterPoints.map((p) => p.latitude).reduce((a, b) => a + b) / clusterPoints.length,
        clusterPoints.map((p) => p.longitude).reduce((a, b) => a + b) / clusterPoints.length,
      );

      return LocationCluster(
        points: clusterPoints,
        center: center,
        size: clusterPoints.length,
      );
    }).toList();
  }
} 