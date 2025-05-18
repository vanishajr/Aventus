import 'package:flutter/material.dart';
import 'gemini_service.dart';
import '../models/supply_report.dart';

class SupplyAssistantService {
  // Standard daily requirements per person
  static const double waterPerPersonPerDay = 3.0; // gallons
  static const int mealsPerPersonPerDay = 3;
  static const int medicalKitsPerPersonPerWeek = 1;
  static const int clothingSetsPerPersonPerMonth = 1;

  static Future<Map<String, dynamic>> calculateSupplies({
    required int numberOfPeople,
    required Map<String, double> supplies,
  }) async {
    // Calculate days supplies will last
    Map<String, Map<String, dynamic>> results = {};
    List<Map<String, dynamic>> priorityList = [];

    // Water calculation (Highest priority)
    double waterDays = supplies['water']! / (waterPerPersonPerDay * numberOfPeople);
    results['water'] = {
      'days': waterDays.toStringAsFixed(1),
      'status': waterDays < 3 ? 'Critical' : waterDays < 7 ? 'Low' : 'Adequate',
      'priority': 1,
      'name': 'Water',
      'remaining': '${supplies['water']!.toStringAsFixed(1)} gallons',
      'required': '${(waterPerPersonPerDay * numberOfPeople).toStringAsFixed(1)} gallons/day'
    };
    priorityList.add({...results['water']!, 'type': 'water'});

    // Food calculation (Second priority)
    double foodDays = supplies['food']! / (mealsPerPersonPerDay * numberOfPeople);
    results['food'] = {
      'days': foodDays.toStringAsFixed(1),
      'status': foodDays < 3 ? 'Critical' : foodDays < 7 ? 'Low' : 'Adequate',
      'priority': 2,
      'name': 'Food',
      'remaining': '${supplies['food']!.toStringAsFixed(0)} meals',
      'required': '${(mealsPerPersonPerDay * numberOfPeople)} meals/day'
    };
    priorityList.add({...results['food']!, 'type': 'food'});

    // Medical supplies calculation (Third priority)
    double medicalDays = (supplies['medical']! / numberOfPeople) * 7;
    results['medical'] = {
      'days': medicalDays.toStringAsFixed(1),
      'status': medicalDays < 7 ? 'Critical' : medicalDays < 14 ? 'Low' : 'Adequate',
      'priority': 3,
      'name': 'Medical Supplies',
      'remaining': '${supplies['medical']!.toStringAsFixed(0)} kits',
      'required': '${numberOfPeople} kits/week'
    };
    priorityList.add({...results['medical']!, 'type': 'medical'});

    // Clothing calculation (Fourth priority)
    double clothingDays = (supplies['clothing']! / numberOfPeople) * 30;
    results['clothing'] = {
      'days': clothingDays.toStringAsFixed(1),
      'status': clothingDays < 14 ? 'Critical' : clothingDays < 30 ? 'Low' : 'Adequate',
      'priority': 4,
      'name': 'Clothing',
      'remaining': '${supplies['clothing']!.toStringAsFixed(0)} sets',
      'required': '${numberOfPeople} sets/month'
    };
    priorityList.add({...results['clothing']!, 'type': 'clothing'});

    // Other supplies (if provided)
    if (supplies.containsKey('others')) {
      double otherDays = supplies['others']! / numberOfPeople;
      results['others'] = {
        'days': otherDays.toStringAsFixed(1),
        'status': otherDays < 7 ? 'Critical' : otherDays < 14 ? 'Low' : 'Adequate',
        'priority': 5,
        'name': 'Other Supplies',
        'remaining': '${supplies['others']!.toStringAsFixed(0)} units',
        'required': '${numberOfPeople} units/week'
      };
      priorityList.add({...results['others']!, 'type': 'others'});
    }

    // Sort by priority (status first, then priority number)
    priorityList.sort((a, b) {
      int statusCompare = _getStatusPriority(a['status']) - _getStatusPriority(b['status']);
      if (statusCompare != 0) return statusCompare;
      return (a['priority'] as int) - (b['priority'] as int);
    });

    // Find earliest resupply needed
    double earliestResupply = double.parse(priorityList[0]['days']);

    final baseResults = {
      'supplies': results,
      'priorityList': priorityList,
      'nextShipmentDue': earliestResupply.toStringAsFixed(1),
      'mostUrgent': priorityList[0]['name'],
      'mostUrgentStatus': priorityList[0]['status'],
    };

    try {
      // Create a temporary SupplyReport for AI analysis
      final tempReport = SupplyReport(
        timestamp: DateTime.now(),
        numberOfPeople: numberOfPeople,
        supplies: results,
        nextShipmentDue: earliestResupply.toStringAsFixed(1),
        mostUrgent: priorityList[0]['name'],
        mostUrgentStatus: priorityList[0]['status'],
      );

      // Get AI insights
      final aiInsights = await GeminiService.generateSupplyInsights(tempReport);
      
      // Add AI insights to results
      return {
        ...baseResults,
        'aiInsights': aiInsights,
      };
    } catch (e) {
      print('Error getting AI insights: $e');
      return baseResults;
    }
  }

  static int _getStatusPriority(String status) {
    switch (status) {
      case 'Critical':
        return 0;
      case 'Low':
        return 1;
      case 'Adequate':
        return 2;
      default:
        return 3;
    }
  }
} 