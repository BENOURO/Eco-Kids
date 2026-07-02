import 'package:flutter/material.dart';
import '../../domain/models/element_nature.dart';
import '../../data/services/wikepidea_api_service.dart';

class WikipediaDetailScreen extends StatefulWidget {
  final ElementNature animal;

  const WikipediaDetailScreen({Key? key, required this.animal})
      : super(key: key);

  @override
  State<WikipediaDetailScreen> createState() => _WikipediaDetailScreenState();
}

class _WikipediaDetailScreenState extends State<WikipediaDetailScreen> {
  final WikipediaApiService _wikiService = WikipediaApiService();

  bool isLoading = true;
  Map<String, dynamic>? wikiData;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadWikipediaData();
  }

  Future<void> _loadWikipediaData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      print('=== DEBUG WIKIPEDIA ===');
      print('animal.name: "${widget.animal.name}"');
      print('animal.wikipediaSource: "${widget.animal.wikipediaSource}"');
      print('animal.wikipediaSource est vide? ${widget.animal.wikipediaSource.isEmpty}');

      // Utiliser wikipediaSource de l'animal si disponible, sinon utiliser le nom
      String searchTerm = widget.animal.wikipediaSource.isNotEmpty
          ? widget.animal.wikipediaSource
          : widget.animal.name;

      // Nettoyer le terme de recherche
      searchTerm = searchTerm.trim();

      print('Terme de recherche Wikipedia: "$searchTerm"');

      final data = await _wikiService.getWikipediaInfo(searchTerm);

      print('Données reçues de Wikipedia:');
      if (data != null) {
        print('  - title: ${data['title']}');
        print('  - description: ${data['description']}');
        print('  - thumbnail: ${data['thumbnail']?['source']}');
        print('  - extract length: ${data['extract']?.toString().length ?? 0} caractères');
      } else {
        print('  - Aucune donnée reçue (null)');
      }

      setState(() {
        wikiData = data;
        isLoading = false;
        if (data == null) {
          errorMessage = 'Aucune information trouvée sur Wikipedia pour "$searchTerm"';
        }
      });
    } catch (e) {
      print('❌ Erreur Wikipedia: $e');
      setState(() {
        isLoading = false;
        errorMessage = 'Erreur lors du chargement: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black87,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: const [
            Icon(Icons.language, color: Colors.white, size: 24),
            SizedBox(width: 8),
            Text(
              'Wikipedia',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(
          color: Colors.black87,
        ),
      )
          : errorMessage != null
          ? _buildErrorView()
          : _buildContent(),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              errorMessage!,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Essayez avec un autre nom ou vérifiez l\'orthographe',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadWikipediaData,
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black87,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image principale de Wikipedia
          if (wikiData?['thumbnail']?['source'] != null)
            Container(
              width: double.infinity,
              height: 250,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(
                    wikiData!['thumbnail']['source'],
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Titre
                Text(
                  wikiData?['title'] ?? widget.animal.name,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),

                // Description courte
                if (wikiData?['description'] != null)
                  Text(
                    wikiData!['description'],
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                const SizedBox(height: 20),

                // Extrait (résumé)
                if (wikiData?['extract'] != null)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      wikiData!['extract'],
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey[800],
                        height: 1.6,
                      ),
                      textAlign: TextAlign.justify,
                    ),
                  ),
                const SizedBox(height: 24),

                // Lien vers article complet
                if (wikiData?['content_urls']?['desktop']?['page'] != null)
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: const Icon(
                        Icons.open_in_browser,
                        color: Colors.black87,
                      ),
                      title: const Text(
                        'Lire l\'article complet',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: const Text(
                        'Ouvrir dans le navigateur',
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        // TODO: Implémenter url_launcher
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Ouverture du lien...'),
                          ),
                        );
                      },
                    ),
                  ),

                const SizedBox(height: 16),

                // Coordonnées géographiques si disponibles
                if (wikiData?['coordinates'] != null)
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.location_pin,
                            color: Colors.red,
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Coordonnées',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Lat: ${wikiData!['coordinates']['lat'].toStringAsFixed(4)}°',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                ),
                              ),
                              Text(
                                'Lon: ${wikiData!['coordinates']['lon'].toStringAsFixed(4)}°',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 24),

                // Source et licence
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.amber[200]!,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 20,
                        color: Colors.amber[800],
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Source: Wikipedia - Licence Creative Commons',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.amber[900],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}