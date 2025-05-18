import 'dart:math';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';


class LocationCluster {
  final List<LatLng> points;
  final LatLng center;
  final int size;
  final double priority;
  final Color color;
  final String name;
  final double radius;

  LocationCluster({
    required this.points,
    required this.center,
    required this.size,
    required this.priority,
    required this.color,
    required this.name,
    required this.radius,
  });
}

class ClusteringService {
  static const double _earthRadius = 6371.0; // Earth's radius in kilometers
  static const double _epsilon = 1.5; // 1.5 km radius for clustering
  static const int _minPoints = 2; // Minimum points to form a cluster
  static const double _minClusterRadius = 0.5; // Minimum cluster radius in km
  static const double _maxClusterRadius = 2.0; // Maximum cluster radius in km

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

  static List<LocationCluster> clusterLocations(List<LatLng> points) {
    if (points.isEmpty) return [];

    List<int> labels = List.filled(points.length, -1);
    int currentCluster = 0;

    for (int i = 0; i < points.length; i++) {
      if (labels[i] != -1) continue;

      List<int> neighbors = _getNeighbors(points, i, _epsilon);

      // Include the point itself in the neighbor count
      if (neighbors.length + 1 >= _minPoints) {
        labels[i] = currentCluster;
        List<int> seedSet = List.from(neighbors);
        int seedIndex = 0;

        while (seedIndex < seedSet.length) {
          int currentPoint = seedSet[seedIndex];

          if (labels[currentPoint] == -1) {
            labels[currentPoint] = currentCluster;
            List<int> currentNeighbors = _getNeighbors(points, currentPoint, _epsilon);
            
            // Add new neighbors to seedSet if they're not already included
            for (int neighbor in currentNeighbors) {
              if (!seedSet.contains(neighbor) && labels[neighbor] == -1) {
                seedSet.add(neighbor);
              }
            }
          }

          seedIndex++;
        }
        currentCluster++;
      } else {
        // For points that don't have enough neighbors, create a single-point cluster
        labels[i] = currentCluster++;
      }
    }

    // Group points by their cluster labels
    Map<int, List<LatLng>> clusters = {};
    for (int i = 0; i < points.length; i++) {
      clusters.putIfAbsent(labels[i], () => []).add(points[i]);
    }

    return clusters.entries.map((entry) {
      final clusterPoints = entry.value;
      final center = LatLng(
        clusterPoints.map((p) => p.latitude).reduce((a, b) => a + b) / clusterPoints.length,
        clusterPoints.map((p) => p.longitude).reduce((a, b) => a + b) / clusterPoints.length,
      );

      final size = clusterPoints.length;
      final priority = _calculatePriority(size);
      final color = _getPriorityColor(priority);
      
      // Calculate radius as the maximum distance from center to any point
      double maxDistance = 0;
      for (var point in clusterPoints) {
        final distance = _calculateDistance(center, point);
        if (distance > maxDistance) {
          maxDistance = distance;
        }
      }

      // Clamp the radius between min and max values
      final clampedRadius = maxDistance.clamp(_minClusterRadius, _maxClusterRadius);

      // Generate simple cluster name
      final name = 'Cluster ${entry.key + 1}';

      return LocationCluster(
        points: clusterPoints,
        center: center,
        size: size,
        priority: priority,
        color: color,
        name: name,
        radius: clampedRadius,
      );
    }).toList();
  }

  static double _calculatePriority(int size) {
    // Convert size directly to priority levels:
    // 7+ points = 1.0 (high)
    // 4-6 points = 0.5 (medium)
    // <4 points = 0.0 (low)
    if (size >= 7) {
      return 1.0;
    } else if (size >= 4) {
      return 0.5;
    } else {
      return 0.0;
    }
  }

  static Color _getPriorityColor(double score) {
    if (score >= 1.0) {
      return Colors.red; // High priority (7+ points)
    } else if (score >= 0.5) {
      return Colors.orange; // Medium priority (4-6 points)
    } else {
      return Colors.green; // Low priority (<4 points)
    }
  }
}
