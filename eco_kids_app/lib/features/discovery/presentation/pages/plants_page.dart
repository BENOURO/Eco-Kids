import 'package:flutter/material.dart';
import '../../data/services/plant_service.dart';
import '../../domain/models/element_nature.dart';
import '../../domain/models/subcategory.dart';
import '../widgets/plant_card.dart';
import 'plant_detail_page.dart';

class PlantsPage extends StatefulWidget {
  @override
  _PlantsPageState createState() => _PlantsPageState();
}

class _PlantsPageState extends State<PlantsPage> {
  final PlantService _plantService = PlantService();
  List<ElementNature> _plants = [];
  List<ElementNature> _filteredPlants = [];
  List<SubCategory> _subcategories = [];
  String? _selectedSubcategoryKey;
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
      final data = await _plantService.getPlantDiscoveryData();

      setState(() {
        _plants = data['plants'] as List<ElementNature>;
        _subcategories = data['subcategories'] as List<SubCategory>;
        _filteredPlants = _plants;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors du chargement: $e';
        _isLoading = false;
      });
    }
  }

  void _filterBySubcategory(String? subcategoryKey) {
    setState(() {
      _selectedSubcategoryKey = subcategoryKey;
      if (subcategoryKey == null) {
        _filteredPlants = _plants;
      } else {
        _filteredPlants = _plants
            .where((p) => p.subCategoryId == subcategoryKey)
            .toList();
      }
    });
  }

  void _onPlantTap(ElementNature plant) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlantDetailPage(
          plant: plant,
          subCategories: _subcategories,
        ),
      ),
    );
  }

  int get _discoveredCount => _plants.length; // Tous visibles pour l'instant

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE8F5E9),
      body: _isLoading
          ? Center(
        child: CircularProgressIndicator(
          color: Color(0xFF4CAF50),
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
              expandedHeight: 210,
              floating: false,
              pinned: true,
              backgroundColor: Color(0xFF4CAF50),
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  'Plantes',
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
                        Color(0xFF66BB6A),
                        Color(0xFF4CAF50),
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
                            Icons.eco,
                            size: 200,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Positioned(
                        left: 20,
                        bottom: 80,
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Collection',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              '${_plants.length} plantes',
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

            // Section des catégories
            SliverToBoxAdapter(
              child: Container(
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(20),
                      child: Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Catégories',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          if (_selectedSubcategoryKey != null)
                            TextButton(
                              onPressed: () =>
                                  _filterBySubcategory(null),
                              child: Text(
                                'Voir tout',
                                style: TextStyle(
                                  color: Color(0xFF4CAF50),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Container(
                      height: 50,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        children: [
                          Padding(
                            padding: EdgeInsets.only(right: 10),
                            child: FilterChip(
                              label: Text('Toutes'),
                              selected: _selectedSubcategoryKey == null,
                              onSelected: (selected) {
                                if (selected)
                                  _filterBySubcategory(null);
                              },
                              backgroundColor: Colors.grey[200],
                              selectedColor: Color(0xFF4CAF50),
                              labelStyle: TextStyle(
                                color: _selectedSubcategoryKey == null
                                    ? Colors.white
                                    : Colors.black87,
                                fontWeight: FontWeight.w600,
                              ),
                              checkmarkColor: Colors.white,
                            ),
                          ),
                          ..._subcategories.map((subcat) {
                            final isSelected =
                                _selectedSubcategoryKey == subcat.key;
                            return Padding(
                              padding: EdgeInsets.only(right: 10),
                              child: FilterChip(
                                label: Text(subcat.name),
                                selected: isSelected,
                                onSelected: (selected) {
                                  if (selected) {
                                    _filterBySubcategory(subcat.key);
                                  }
                                },
                                backgroundColor: Colors.grey[200],
                                selectedColor: Color(0xFF4CAF50),
                                labelStyle: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.black87,
                                  fontWeight: FontWeight.w600,
                                ),
                                checkmarkColor: Colors.white,
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // Grille des plantes
            _filteredPlants.isEmpty
                ? SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search_off,
                      size: 80,
                      color: Colors.grey[300],
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Aucune plante trouvée',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Essayez un autre filtre',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
            )
                : SliverPadding(
              padding: EdgeInsets.all(16),
              sliver: SliverGrid(
                gridDelegate:
                SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.9,
                ),
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    final plant = _filteredPlants[index];
                    return PlantCard(
                      plant: plant,
                      subCategories: _subcategories,
                      onTap: () => _onPlantTap(plant),
                    );
                  },
                  childCount: _filteredPlants.length,
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
                backgroundColor: Color(0xFF4CAF50),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}