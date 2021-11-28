import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:foody/api/firebase_api.dart';
import 'package:foody/models/recipe_model.dart';

class RecipesProvider extends ChangeNotifier {
  var _recipesSnapshot = <DocumentSnapshot>[];
  String _errorMessage = '';
  int documentLimit = 15;
  bool _hasNext = true;
  bool _isFetchingRecipes = false;
  static bool chaged = true;
  bool isFirstTime = true;

  String get errorMessage => _errorMessage;

  bool get hasNext => _hasNext;

  List<Recipe> get recipes => _recipesSnapshot.map((snap) {
        final recipe = snap.data();
        return Recipe(
            title: (recipe as dynamic)["title"],
            id: (recipe as dynamic)["id"],
            image: (recipe as dynamic)["image"],
            note: (recipe as dynamic)["note"],
            tips: (recipe as dynamic)["tips"],
            categorie: (recipe as dynamic)["categorie"],
            difficulty: (recipe as dynamic)["difficulty"],
            nutritions: (recipe as dynamic)["nutritions"],
            instructions: (recipe as dynamic)["instructions"],
            ingredients: (recipe as dynamic)["ingredients"],
            methods: (recipe as dynamic)["methods"],
            rate: (recipe as dynamic)["rate"]);
      }).toList();
  Recipe selectedRecipeFromDocs(dynamic recipe) {
    return Recipe(
        title: (recipe as dynamic)["title"],
        id: (recipe as dynamic)["id"],
        image: (recipe as dynamic)["image"],
        note: (recipe as dynamic)["note"],
        tips: (recipe as dynamic)["tips"],
        categorie: (recipe as dynamic)["categorie"],
        difficulty: (recipe as dynamic)["difficulty"],
        nutritions: (recipe as dynamic)["nutritions"],
        instructions: (recipe as dynamic)["instructions"],
        ingredients: (recipe as dynamic)["ingredients"],
        methods: (recipe as dynamic)["methods"],
        rate: (recipe as dynamic)["rate"]);
  }

  Future fetchNextRecipes(String category) async {
    if (_isFetchingRecipes) return;
    print(chaged);
    _errorMessage = '';
    _isFetchingRecipes = true;

    try {
      if (chaged) {
        _recipesSnapshot = [];
        if (!isFirstTime) {
          _recipesSnapshot = [];
          isFirstTime = true;
          chaged = false;
        }
      }
      final snap = await FirebaseApi.getRecipes(
        category,
        documentLimit,
        startAfter: _recipesSnapshot.isNotEmpty ? _recipesSnapshot.last : null,
      );
      _recipesSnapshot.addAll(snap.docs);
      if (snap.docs.length < documentLimit) _hasNext = false;
      notifyListeners();
    } catch (error) {
      _errorMessage = error.toString();
      notifyListeners();
    }
    _isFetchingRecipes = false;
  }
}
