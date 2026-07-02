import 'package:flutter/material.dart';
import '../../data/services/firebase_discovery_service.dart';
import '../../domain/models/element_nature.dart';
import '../../domain/models/category.dart';
import '../../domain/models/subcategory.dart';
import '../widgets/animal_card.dart';
import '../widgets/category_filter_chip.dart';
import '../widgets/discovery_app_bar.dart';
import '../widgets/error_view.dart';
import '../widgets/section_header.dart';
import 'animal_detail_page.dart';

class DiscoveryScreen extends StatefulWidget {
  const DiscoveryScreen({Key? key}) : super(key: key);

  @override
  State<DiscoveryScreen> createState() => _DiscoveryScreenState();
}

class _DiscoveryScreenState extends State<DiscoveryScreen> {
  final FirebaseDiscoveryService _firebaseService = FirebaseDiscoveryService();

  List<ElementNature> _allElements = [];
  List<SubCategory> _subCategories = [];
  String? _selectedSubCategoryId;
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
      // Charger les éléments de type "Animal"
      final elements = await _firebaseService.getElementsByType('Animal');

      // Charger les sous-catégories
      final subCategories = await _firebaseService.getSubCategories();

      setState(() {
        _allElements = elements;
        _subCategories = subCategories;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors du chargement: $e';
        _isLoading = false;
      });
    }
  }

  List<ElementNature> get _filteredElements {
    if (_selectedSubCategoryId == null) {
      return _allElements;
    }
    return _allElements
        .where((element) => element.subCategoryId == _selectedSubCategoryId)
        .toList();
  }

  void _onSubcategorySelected(String? subCategoryId) {
    setState(() {
      _selectedSubCategoryId = subCategoryId;
    });
  }

  void _onViewAllPressed() {
    setState(() {
      _selectedSubCategoryId = null;
    });
  }

  void _onAnimalTap(ElementNature animal) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AnimalDetailScreen(
          animal: animal,
          subCategories: _subCategories,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: DiscoveryAppBar(
        onMenuPressed: () {
          // TODO: Implémenter le menu
        },
        onSearchPressed: () {
          // TODO: Implémenter la recherche
        },
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? _buildErrorView()
          : _buildContent(),
    );
  }

  Widget _buildErrorView() {
    return  ErrorView(
      message: _errorMessage ?? "Une erreur est survenue.",
      onRetry: _loadData,
    );
  }

  Widget _buildContent() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(
                title: 'Find by Categories',
                onViewAllPressed: _onViewAllPressed,
              ),
              const SizedBox(height: 20),
              if (_subCategories.isNotEmpty)
                _buildSubCategoryFilters(),
              const SizedBox(height: 30),
              _buildAnimalsGrid(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubCategoryFilters() {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _subCategories.length,
        itemBuilder: (context, index) {
          final subCategory = _subCategories[index];
          final isSelected = _selectedSubCategoryId == subCategory.id;

          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: CategoryFilterChip(
              label: subCategory.name,
              isSelected: isSelected,
              onSelected: (selected) {
                _onSubcategorySelected(selected ? subCategory.id : null);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildAnimalsGrid() {
    if (_filteredElements.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off, size: 80, color: Colors.grey[300]),
              const SizedBox(height: 16),
              Text(
                'Aucun animal trouvé',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Essayez un autre filtre',
                style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              ),
            ],
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        childAspectRatio: 0.9,
      ),
      itemCount: _filteredElements.length,
      itemBuilder: (context, index) {
        final animal = _filteredElements[index];

        // Chercher la sous-catégorie en utilisant le champ 'key'
        final subCategory = _subCategories.firstWhere(
              (sc) => sc.key != null && sc.key == animal.subCategoryId,
          orElse: () => SubCategory(
            id: '',
            name: 'Unknown',
            categoryId: '',
            description: '',
            key: animal.subCategoryId, // Utiliser le subCategoryId comme fallback
          ),
        );

        return AnimalCard(
          animal: animal,
          subCategoryId: subCategory.key ?? animal.subCategoryId, // Utiliser key ou subCategoryId en fallback
          onTap: () => _onAnimalTap(animal),
        );
      },
    );
  }
}