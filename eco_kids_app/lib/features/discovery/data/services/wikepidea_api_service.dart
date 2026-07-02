import 'dart:convert';
import 'package:http/http.dart' as http;

class WikipediaApiService {
  // Essayer d'abord l'API anglaise, puis française en fallback
  final String baseUrlEn = "https://en.wikipedia.org/api/rest_v1/page/summary/";
  final String baseUrlFr = "https://fr.wikipedia.org/api/rest_v1/page/summary/";

  Future<Map<String, dynamic>?> getWikipediaInfo(String title) async {
    try {
      print('🔍 Recherche Wikipedia pour: "$title"');

      // Essayer d'abord en anglais
      final resultEn = await _fetchFromUrl(baseUrlEn, title);
      if (resultEn != null) {
        print('✅ Trouvé sur Wikipedia EN');
        return resultEn;
      }

      print('⚠️ Non trouvé en anglais, essai en français...');

      // Si non trouvé en anglais, essayer en français
      final resultFr = await _fetchFromUrl(baseUrlFr, title);
      if (resultFr != null) {
        print('✅ Trouvé sur Wikipedia FR');
        return resultFr;
      }

      print('❌ Non trouvé ni en EN ni en FR');
      return null;

    } catch (e) {
      print("❌ Wikipedia API exception : $e");
      return null;
    }
  }

  Future<Map<String, dynamic>?> _fetchFromUrl(String baseUrl, String title) async {
    try {
      final url = Uri.parse("$baseUrl$title");
      print('   Tentative: $url');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Vérifier que ce n'est pas une page de désambiguïsation
        if (data['type'] == 'disambiguation') {
          print('   ⚠️ Page de désambiguïsation ignorée');
          return null;
        }
        return data;
      } else if (response.statusCode == 404) {
        print('   ℹ️ 404 - Page non trouvée');
        return null;
      } else {
        print("   ⚠️ Erreur HTTP: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("   ❌ Erreur: $e");
      return null;
    }
  }
}