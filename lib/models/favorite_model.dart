import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
part 'favorite_model.g.dart';

@HiveType(typeId: 0)
class FavoriteRecipe {
  @HiveField(0)
  late String title;
  @HiveField(1)
  late String image;
  @HiveField(2)
  late String id;
  @HiveField(3)
  late String note;
  @HiveField(4)
  late String tips;
  @HiveField(5)
  late String categorie;
  @HiveField(6)
  late String difficulty;
  @HiveField(7)
  late List nutritions;
  @HiveField(8)
  late List instructions;
  @HiveField(9)
  late List ingredients;
  @HiveField(10)
  late List methods;
  @HiveField(11)
  late int rate;

  FavoriteRecipe({
    this.title = '',
    this.id = '',
    this.image = '',
    this.note = '',
    this.tips = '',
    this.categorie = '',
    this.difficulty = '',
    this.nutritions = const [],
    this.instructions = const [],
    this.ingredients = const [],
    this.methods = const [],
    this.rate = 5,
  });
}

class FavoriteModel extends ChangeNotifier {
  var isFavorite = false;
  final favoriteBox = Hive.box("favorite");
  Box getBox() {
    return favoriteBox;
  }

  bool getFavoriteStatus() => isFavorite;
  void switchFavorite(String id) {
    List ids = [];
    // favoriteBox.add(favoriteItem);
    for (int i = 0; i < getBox().length; i++) {
      var fav = favoriteBox.getAt(i) as FavoriteRecipe;
      ids.add(fav.id);
    }
    if (!ids.contains(id)) {
      isFavorite = false;
    } else {
      isFavorite = true;
    }

    isFavorite = !isFavorite;
    notifyListeners();
  }

  void addToFavorite(
      String title,
      String image,
      String id,
      String note,
      String tips,
      String categorie,
      String difficulty,
      List nutritions,
      List instructions,
      List ingredients,
      List methods,
      int rate,
      BuildContext context) {
    FavoriteRecipe favoriteItem = FavoriteRecipe(
      title: title,
      image: image,
      id: id,
      note: note,
      tips: tips,
      categorie: categorie,
      difficulty: difficulty,
      nutritions: nutritions,
      instructions: instructions,
      ingredients: ingredients,
      methods: methods,
      rate: rate,
    );
    var itemindex;
    List ids = [];
    // favoriteBox.add(favoriteItem);
    for (int i = 0; i < getBox().length; i++) {
      var fav = favoriteBox.getAt(i) as FavoriteRecipe;
      ids.add(fav.id);
    }
    if (!ids.contains(favoriteItem.id)) {
      print("Added!");
      favoriteBox.add(favoriteItem);
      showSnakBare(true, context);

      isFavorite = false;
    } else {
      print("element exist!");
      itemindex = ids.indexOf(favoriteItem.id);
      print(itemindex);
      isFavorite = true;
      showSnakBare(false, context);
      Hive.box('favorite').deleteAt(itemindex);
    }

    notifyListeners();
  }

  void clearBox() {
    Hive.box('favorite').clear();
    notifyListeners();
  }

  Future<Box> openBox() async {
    return Hive.openBox('favorite');
  }

  void showSnakBare(bool addORremove, BuildContext context) {
    final snackBar = SnackBar(
      // animation: Animation,
      // width: 120,
      behavior: SnackBarBehavior.floating,
      backgroundColor: (addORremove)
          ? Colors.green[300]?.withOpacity(0.8)
          : Colors.red[300]?.withOpacity(0.8),
      content: (addORremove)
          ? Text(
              "Added to favorite basket!",
              textAlign: TextAlign.center,
            )
          : Text(
              "Remouved from favorite basket!",
              textAlign: TextAlign.center,
            ),
      duration: Duration(milliseconds: 1000),
    );
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
    Scaffold.of(context);
  }
}
