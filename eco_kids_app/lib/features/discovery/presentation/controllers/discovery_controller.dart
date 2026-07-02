import 'package:flutter/material.dart';
import '../../domain/models/element_nature.dart';
import '../../data/services/firebase_discovery_service.dart';
import '../../data/services/wikepidea_api_service.dart';

class DiscoveryController extends ChangeNotifier {
  final FirebaseDiscoveryService firebaseService;
  final WikipediaApiService wikipediaService;

  DiscoveryController({
    required this.firebaseService,
    required this.wikipediaService,
  });

  List<ElementNature> animals = [];
  bool isLoading = false;

  Future<void> loadAnimals() async {
    isLoading = true;
    notifyListeners();

    animals = await firebaseService.getElementsByType("Animal");


    isLoading = false;
    notifyListeners();
  }

  Future<Map<String, dynamic>?> getWikipediaInfo(String title) async {
    return await wikipediaService.getWikipediaInfo(title);
  }
}
