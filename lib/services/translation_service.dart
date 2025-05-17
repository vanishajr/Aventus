import 'dart:convert';
import 'package:http/http.dart' as http;

class TranslationService {
  static const String apiKey = 'AIzaSyDPDvczczqFLxjtcly7_ZYCHt59l_abqkY';
  static const String baseUrl = 'https://translation.googleapis.com/language/translate/v2';

  static final Map<String, String> supportedLanguages = {
    'en': 'English',
    'hi': 'Hindi',
    'kn': 'Kannada',
  };

  static Future<String> translateText(String text, String targetLanguage) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl?key=$apiKey'),
        body: {
          'q': text,
          'target': targetLanguage,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data']['translations'][0]['translatedText'];
      } else {
        throw Exception('Translation failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Translation error: $e');
    }
  }
} 