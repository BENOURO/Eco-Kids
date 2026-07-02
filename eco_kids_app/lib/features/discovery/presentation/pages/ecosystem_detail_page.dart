import 'package:flutter/material.dart';
import '../../data/services/ecosystem_service.dart';
import '../../domain/models/ecosystem.dart';
import '../../domain/models/element_nature.dart';

class EcosystemDetailPage extends StatefulWidget {
  final String ecosystemId;

  EcosystemDetailPage({required this.ecosystemId});

  @override
  _EcosystemDetailPageState createState() => _EcosystemDetailPageState();
}

class _EcosystemDetailPageState extends State<EcosystemDetailPage>
    with SingleTickerProviderStateMixin {
  final EcosystemService _ecosystemService = EcosystemService();

  Ecosystem? _ecosystem;
  List<ElementNature> _animals = [];
  List<ElementNature> _plants = [];

  bool _isLoading = true;
  String? _errorMessage;

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadEcosystem();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadEcosystem() async {
    setState(() => _isLoading = true);

    try {
      final data = await _ecosystemService.getEcosystemWithData(widget.ecosystemId);

      setState(() {
        _ecosystem = data['ecosystem'];
        _animals = data['animals'];
        _plants = data['plants'];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur: $e';
        _isLoading = false;
      });
    }
  }

  Color _getEcosystemColor() {
    if (_ecosystem == null) return Color(0xFF4FC3F7);

    final name = _ecosystem!.name.toLowerCase();

    if (name.contains('forêt') || name.contains('forest')) {
      return Color(0xFF81C784);
    } else if (name.contains('océan') || name.contains('mer') || name.contains('ocean')) {
      return Color(0xFF4FC3F7);
    } else if (name.contains('désert') || name.contains('desert')) {
      return Color(0xFFFFD54F);
    } else if (name.contains('montagne') || name.contains('mountain')) {
      return Color(0xFF9575CD);
    } else if (name.contains('savane') || name.contains('savanna')) {
      return Color(0xFFFF8A65);
    } else if (name.contains('jungle') || name.contains('tropical')) {
      return Color(0xFF4DB6AC);
    }

    return Color(0xFF4FC3F7);
  }

  IconData _getEcosystemIcon() {
    if (_ecosystem == null) return Icons.public;

    final name = _ecosystem!.name.toLowerCase();

    if (name.contains('forêt') || name.contains('forest')) {
      return Icons.forest;
    } else if (name.contains('océan') || name.contains('mer') || name.contains('ocean')) {
      return Icons.waves;
    } else if (name.contains('désert') || name.contains('desert')) {
      return Icons.wb_sunny;
    } else if (name.contains('montagne') || name.contains('mountain')) {
      return Icons.terrain;
    } else if (name.contains('savane') || name.contains('savanna')) {
      return Icons.grass;
    } else if (name.contains('jungle') || name.contains('tropical')) {
      return Icons.nature_people;
    }

    return Icons.public;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Color(0xFFF5F5F5),
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF4FC3F7),
          ),
        ),
      );
    }

    if (_ecosystem == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Erreur'),
          backgroundColor: Color(0xFF4FC3F7),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 80,
                color: Colors.grey[400],
              ),
              SizedBox(height: 16),
              Text(
                _errorMessage ?? 'Écosystème non trouvé',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final ecosystemColor = _getEcosystemColor();
    final icon = _getEcosystemIcon();
    final totalElements = _animals.length + _plants.length;

    return Scaffold(
      backgroundColor: ecosystemColor.withOpacity(0.1),
      body: SafeArea(
        child: Column(
          children: [
            // HEADER avec icône
            Container(
              height: MediaQuery.of(context).size.height * 0.35,
              child: Stack(
                children: [
                  // Fond dégradé
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          ecosystemColor,
                          ecosystemColor.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                  // Motif de fond
                  Positioned(
                    right: -50,
                    top: -50,
                    child: Opacity(
                      opacity: 0.15,
                      child: Icon(
                        icon,
                        size: 250,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  // Bouton retour
                  Positioned(
                    top: 16,
                    left: 16,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ),
                  // Badge compteur
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.eco, color: Colors.white, size: 18),
                          SizedBox(width: 6),
                          Text(
                            '$totalElements espèces',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Icône principale
                  Center(
                    child: Hero(
                      tag: widget.ecosystemId,
                      child: Container(
                        padding: EdgeInsets.all(40),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          icon,
                          size: 100,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  // Indicateurs
                  Positioned(
                    bottom: 20,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        3,
                            (index) => Container(
                          margin: EdgeInsets.symmetric(horizontal: 4),
                          width: index == 0 ? 8 : 6,
                          height: index == 0 ? 8 : 6,
                          decoration: BoxDecoration(
                            color: index == 0
                                ? Colors.white
                                : Colors.white.withOpacity(0.5),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // CONTENU
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    SizedBox(height: 24),
                    // Titre
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          Text(
                            _ecosystem!.name,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 16),
                          // Statistiques
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildStatCard(
                                icon: Icons.pets,
                                count: _animals.length,
                                label: 'Animaux',
                                color: Colors.orange,
                              ),
                              SizedBox(width: 16),
                              _buildStatCard(
                                icon: Icons.local_florist,
                                count: _plants.length,
                                label: 'Plantes',
                                color: Colors.green,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    // Onglets
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(25),
                      ),
                      margin: EdgeInsets.symmetric(horizontal: 24),
                      child: TabBar(
                        controller: _tabController,
                        indicator: BoxDecoration(
                          color: ecosystemColor,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        labelColor: Colors.white,
                        unselectedLabelColor: Colors.grey[600],
                        labelStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                        tabs: [
                          Tab(text: 'Description'),
                          Tab(text: 'Animaux'),
                          Tab(text: 'Plantes'),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    // Contenu des onglets
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildDescriptionTab(ecosystemColor),
                          _buildAnimalsTab(),
                          _buildPlantsTab(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required int count,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          SizedBox(height: 4),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionTab(Color color) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: color.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Text(
              _ecosystem!.description,
              style: TextStyle(
                fontSize: 15,
                height: 1.6,
                color: Colors.grey[800],
              ),
              textAlign: TextAlign.justify,
            ),
          ),
          SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildAnimalsTab() {
    if (_animals.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.pets,
              size: 80,
              color: Colors.grey[300],
            ),
            SizedBox(height: 16),
            Text(
              'Aucun animal dans cet écosystème',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: _animals.length,
      itemBuilder: (context, index) {
        final animal = _animals[index];
        return _buildElementCard(animal, Colors.orange);
      },
    );
  }

  Widget _buildPlantsTab() {
    if (_plants.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_florist,
              size: 80,
              color: Colors.grey[300],
            ),
            SizedBox(height: 16),
            Text(
              'Aucune plante dans cet écosystème',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: _plants.length,
      itemBuilder: (context, index) {
        final plant = _plants[index];
        return _buildElementCard(plant, Colors.green);
      },
    );
  }

  Widget _buildElementCard(ElementNature element, Color accentColor) {
    return GestureDetector(
      onTap: () {
        // Navigation vers la page de détail
        if (element.type == 'Animal') {
          Navigator.pushNamed(context, '/animal-detail', arguments: element.id);
        } else {
          Navigator.pushNamed(context, '/plant-detail', arguments: element.id);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: accentColor.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(13),
                    topRight: Radius.circular(13),
                  ),
                ),
                child: element.imageUrl.isNotEmpty &&
                    !element.imageUrl.startsWith('assets/')
                    ? ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(13),
                    topRight: Radius.circular(13),
                  ),
                  child: Image.network(
                    element.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Icon(
                          element.type == 'Animal'
                              ? Icons.pets
                              : Icons.local_florist,
                          size: 40,
                          color: accentColor,
                        ),
                      );
                    },
                  ),
                )
                    : Center(
                  child: Icon(
                    element.type == 'Animal'
                        ? Icons.pets
                        : Icons.local_florist,
                    size: 40,
                    color: accentColor,
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                element.name,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}