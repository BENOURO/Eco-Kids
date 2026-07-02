import 'package:flutter/material.dart';
import 'package:translator/translator.dart';
import 'package:video_player/video_player.dart';
import '../../domain/models/ecosystem.dart';
import '../../data/services/wikepidea_api_service.dart';

class EcosystemWikipediaDetailPage extends StatefulWidget {
  final Ecosystem ecosystem;

  const EcosystemWikipediaDetailPage({Key? key, required this.ecosystem})
      : super(key: key);

  @override
  State<EcosystemWikipediaDetailPage> createState() =>
      _EcosystemWikipediaDetailPageState();
}

class _EcosystemWikipediaDetailPageState
    extends State<EcosystemWikipediaDetailPage> {
  final WikipediaApiService _wikiService = WikipediaApiService();
  final GoogleTranslator _translator = GoogleTranslator();

  bool isLoading = true;
  bool isTranslating = false;
  Map<String, dynamic>? wikiData;
  Map<String, dynamic>? translatedData;
  String? errorMessage;
  bool showTranslation = false;
  VideoPlayerController? _videoController;
  bool _isVideoLoading = false;

  @override
  void initState() {
    super.initState();
    _loadWikipediaData();
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _loadWikipediaData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      print('=== DEBUG WIKIPEDIA ECOSYSTEM ===');
      print('ecosystem.name: "${widget.ecosystem.name}"');

      String searchTerm = widget.ecosystem.name.trim();
      print('Terme de recherche Wikipedia: "$searchTerm"');

      final data = await _wikiService.getWikipediaInfo(searchTerm);

      setState(() {
        wikiData = data;
        isLoading = false;
        if (data == null) {
          errorMessage =
          'Aucune information trouvée sur Wikipedia pour "$searchTerm"';
        }
      });

      // Charger la vidéo si disponible
      if (data != null) {
        await _loadVideoIfAvailable();
      }
    } catch (e) {
      print('❌ Erreur Wikipedia: $e');
      setState(() {
        isLoading = false;
        errorMessage = 'Erreur lors du chargement: $e';
      });
    }
  }

  Future<void> _loadVideoIfAvailable() async {
    // Note: Wikipedia ne fournit pas directement de vidéos via l'API REST
    // Cette méthode pourrait être étendue pour chercher des vidéos sur Commons
    // Pour l'instant, on affiche un placeholder
    print('ℹ️ Recherche de vidéo Wikipedia...');
  }

  Future<void> _translateContent() async {
    if (wikiData == null) return;

    setState(() {
      isTranslating = true;
    });

    try {
      Map<String, dynamic> translated = {};

      // Traduire le titre
      if (wikiData?['title'] != null) {
        final titleTranslation = await _translator.translate(
          wikiData!['title'],
          to: 'fr',
        );
        translated['title'] = titleTranslation.text;
      }

      // Traduire la description
      if (wikiData?['description'] != null) {
        final descTranslation = await _translator.translate(
          wikiData!['description'],
          to: 'fr',
        );
        translated['description'] = descTranslation.text;
      }

      // Traduire l'extrait
      if (wikiData?['extract'] != null) {
        final extractTranslation = await _translator.translate(
          wikiData!['extract'],
          to: 'fr',
        );
        translated['extract'] = extractTranslation.text;
      }

      setState(() {
        translatedData = translated;
        showTranslation = true;
        isTranslating = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Traduction terminée'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print('❌ Erreur de traduction: $e');
      setState(() {
        isTranslating = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Erreur de traduction: $e'),
          backgroundColor: Colors.red,
        ),
      );
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
        actions: [
          if (wikiData != null && !isLoading)
            IconButton(
              icon: Icon(
                showTranslation ? Icons.translate : Icons.g_translate,
                color: Colors.white,
              ),
              onPressed: () {
                if (showTranslation) {
                  setState(() {
                    showTranslation = false;
                  });
                } else {
                  if (translatedData == null) {
                    _translateContent();
                  } else {
                    setState(() {
                      showTranslation = true;
                    });
                  }
                }
              },
              tooltip:
              showTranslation ? 'Voir original' : 'Traduire en français',
            ),
        ],
      ),
      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(
          color: Colors.black87,
        ),
      )
          : errorMessage != null
          ? _buildErrorView()
          : Stack(
        children: [
          _buildContent(),
          if (isTranslating)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text(
                          'Traduction en cours...',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
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
    final displayData = showTranslation && translatedData != null
        ? translatedData!
        : wikiData!;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bannière de traduction
          if (showTranslation && translatedData != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: Colors.blue[50],
              child: Row(
                children: [
                  Icon(Icons.translate, color: Colors.blue[700], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Version traduite en français',
                      style: TextStyle(
                        color: Colors.blue[900],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Zone vidéo/image
          _buildMediaSection(),

          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Badge type d'écosystème
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.public, color: Colors.green[700], size: 16),
                      const SizedBox(width: 6),
                      Text(
                        'Écosystème',
                        style: TextStyle(
                          color: Colors.green[900],
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Titre
                Text(
                  displayData['title'] ?? widget.ecosystem.name,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),

                // Description courte
                if (displayData['description'] != null)
                  Text(
                    displayData['description'],
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                const SizedBox(height: 20),

                // Extrait (résumé)
                if (displayData['extract'] != null)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      displayData['extract'],
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
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'URL: ${wikiData!['content_urls']['desktop']['page']}'),
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

  Widget _buildMediaSection() {
    // Si une vidéo est chargée
    if (_videoController != null && _videoController!.value.isInitialized) {
      return Container(
        width: double.infinity,
        height: 250,
        color: Colors.black,
        child: Stack(
          alignment: Alignment.center,
          children: [
            AspectRatio(
              aspectRatio: _videoController!.value.aspectRatio,
              child: VideoPlayer(_videoController!),
            ),
            // Contrôles de lecture
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.black54,
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        _videoController!.value.isPlaying
                            ? Icons.pause
                            : Icons.play_arrow,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        setState(() {
                          if (_videoController!.value.isPlaying) {
                            _videoController!.pause();
                          } else {
                            _videoController!.play();
                          }
                        });
                      },
                    ),
                    Expanded(
                      child: VideoProgressIndicator(
                        _videoController!,
                        allowScrubbing: true,
                        colors: const VideoProgressColors(
                          playedColor: Colors.white,
                          bufferedColor: Colors.white30,
                          backgroundColor: Colors.white10,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Sinon, afficher l'image Wikipedia ou un placeholder
    if (wikiData?['thumbnail']?['source'] != null) {
      return Container(
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
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withOpacity(0.3),
              ],
            ),
          ),
          alignment: Alignment.bottomRight,
          padding: const EdgeInsets.all(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.image, color: Colors.white, size: 16),
                SizedBox(width: 6),
                Text(
                  'Photo Wikipedia',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Placeholder si aucune image/vidéo
    return Container(
      width: double.infinity,
      height: 250,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.green[400]!,
            Colors.green[700]!,
          ],
        ),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.videocam_off,
            size: 80,
            color: Colors.white70,
          ),
          SizedBox(height: 16),
          Text(
            'Aucune vidéo disponible',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Les médias Wikipedia ne sont pas toujours disponibles',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}