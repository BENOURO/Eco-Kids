import 'package:flutter/material.dart';
import '../../data/services/ecosystem_service.dart';
import '../../domain/models/ecosystem.dart';
import '../widgets/ecosystem_card.dart';

class EcosystemsPage extends StatefulWidget {
  @override
  _EcosystemsPageState createState() => _EcosystemsPageState();
}

class _EcosystemsPageState extends State<EcosystemsPage> {
  final EcosystemService _ecosystemService = EcosystemService();
  List<Ecosystem> _ecosystems = [];
  Map<String, Map<String, int>> _elementsCounts = {};
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final ecosystems = await _ecosystemService.getAllEcosystems();

      // Charger les compteurs pour chaque écosystème
      final counts = <String, Map<String, int>>{};
      for (final ecosystem in ecosystems) {
        final count = await _ecosystemService.getEcosystemElementsCount(ecosystem.id);
        counts[ecosystem.id] = count;
      }

      setState(() {
        _ecosystems = ecosystems;
        _elementsCounts = counts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors du chargement: $e';
        _isLoading = false;
      });
    }
  }

  Color _getEcosystemColor(int index) {
    final colors = [
      Color(0xFF4FC3F7), // Bleu clair - Aquatique
      Color(0xFF81C784), // Vert - Forêt
      Color(0xFFFFD54F), // Jaune - Désert
      Color(0xFF9575CD), // Violet - Montagne
      Color(0xFFFF8A65), // Orange - Savane
      Color(0xFF4DB6AC), // Turquoise - Tropical
    ];
    return colors[index % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      body: _isLoading
          ? Center(
        child: CircularProgressIndicator(
          color: Color(0xFF4FC3F7),
        ),
      )
          : _errorMessage != null
          ? _buildErrorView()
          : RefreshIndicator(
        onRefresh: _loadData,
        child: CustomScrollView(
          slivers: [
            // App Bar personnalisée
            SliverAppBar(
              expandedHeight: 200,
              floating: false,
              pinned: true,
              backgroundColor: Color(0xFF4FC3F7),
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  'Écosystèmes',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF29B6F6),
                        Color(0xFF4FC3F7),
                      ],
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: -50,
                        bottom: -30,
                        child: Opacity(
                          opacity: 0.2,
                          child: Icon(
                            Icons.public,
                            size: 200,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Positioned(
                        left: 20,
                        bottom: 70,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Explorez',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              '${_ecosystems.length} écosystèmes',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.search, color: Colors.white),
                  onPressed: () {
                    // TODO: Implémenter la recherche
                  },
                ),
              ],
            ),

            // Message d'introduction
            SliverToBoxAdapter(
              child: Container(
                margin: EdgeInsets.all(20),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF81C784).withOpacity(0.2),
                      Color(0xFF4FC3F7).withOpacity(0.2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: Color(0xFF4FC3F7).withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.info_outline,
                        color: Color(0xFF4FC3F7),
                        size: 28,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Découvrez les différents écosystèmes et leurs habitants',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[800],
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Liste des écosystèmes
            _ecosystems.isEmpty
                ? SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.nature_outlined,
                      size: 80,
                      color: Colors.grey[300],
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Aucun écosystème trouvé',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            )
                : SliverPadding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    final ecosystem = _ecosystems[index];
                    final counts = _elementsCounts[ecosystem.id] ??
                        {'animals': 0, 'plants': 0, 'total': 0};

                    return Padding(
                      padding: EdgeInsets.only(bottom: 16),
                      child: EcosystemCard(
                        ecosystem: ecosystem,
                        color: _getEcosystemColor(index),
                        animalCount: counts['animals'] ?? 0,
                        plantCount: counts['plants'] ?? 0,
                        onTap: () async {
                          await Navigator.pushNamed(
                            context,
                            '/ecosystem-detail',
                            arguments: ecosystem.id,
                          );
                          _loadData();
                        },
                      ),
                    );
                  },
                  childCount: _ecosystems.length,
                ),
              ),
            ),
          ],
        ),
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
            SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadData,
              icon: Icon(Icons.refresh),
              label: Text('Réessayer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF4FC3F7),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}