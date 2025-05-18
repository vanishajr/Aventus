import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/supply_report.dart';

class GeminiService {
  static const String apiKey = 'AIzaSyC1qocmB93ZAXA2WBQN532yEcLfIEQj3voY';
  static const String baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent';

  static Future<Map<String, dynamic>> generateSupplyInsights(SupplyReport report) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl?key=$apiKey'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'contents': [{
            'parts': [{
              'text': '''Analyze this supply status data and provide insights:
              
Number of people: ${report.numberOfPeople}
Supplies:
${report.supplies.entries.map((e) => '''
${e.value['name']}:
- Remaining: ${e.value['remaining']}
- Required: ${e.value['required']}
- Days left: ${e.value['days']}
- Status: ${e.value['status']}
''').join('\n')}

Most urgent item: ${report.mostUrgent} (${report.mostUrgentStatus})
Next shipment due in: ${report.nextShipmentDue} days

Please provide:
1. Key insights and trends
2. Recommendations for optimization
3. Risk assessment
4. Suggested actions
5. Supply chain efficiency analysis'''
            }]
          }],
          'generationConfig': {
            'temperature': 0.7,
            'topK': 40,
            'topP': 0.95,
            'maxOutputTokens': 1000,
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['candidates'][0]['content']['parts'][0]['text'];
        
        // Parse the response into structured sections
        final sections = _parseAIResponse(text);
        return sections;
      } else {
        throw Exception('Failed to generate insights: ${response.statusCode}');
      }
    } catch (e) {
      print('Error generating insights: $e');
      return {
        'insights': 'Unable to generate insights at this time.',
        'recommendations': 'Please check your supply data manually.',
        'risks': 'Manual risk assessment recommended.',
        'actions': 'Continue with standard supply management procedures.',
        'efficiency': 'Supply chain analysis unavailable.',
      };
    }
  }

  static Map<String, String> _parseAIResponse(String text) {
    final sections = {
      'insights': '',
      'recommendations': '',
      'risks': '',
      'actions': '',
      'efficiency': '',
    };

    var currentSection = '';
    final lines = text.split('\n');

    for (final line in lines) {
      if (line.toLowerCase().contains('key insights')) {
        currentSection = 'insights';
      } else if (line.toLowerCase().contains('recommendations')) {
        currentSection = 'recommendations';
      } else if (line.toLowerCase().contains('risk')) {
        currentSection = 'risks';
      } else if (line.toLowerCase().contains('suggested actions')) {
        currentSection = 'actions';
      } else if (line.toLowerCase().contains('supply chain')) {
        currentSection = 'efficiency';
      } else if (currentSection.isNotEmpty && line.trim().isNotEmpty) {
        sections[currentSection] = '${sections[currentSection]}\n$line'.trim();
      }
    }

    return sections;
  }
} 