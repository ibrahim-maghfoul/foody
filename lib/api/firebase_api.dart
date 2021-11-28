import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseApi {
  // static Future uploadRecipes() async {
  //   final currentRecipes = await getRecipes(1);

  //   if (currentRecipes.docs.isEmpty) {
  //     final refRecipes = FirebaseFirestore.instance.collection('Recipes');

  //     for (final recipe in List.of(Recipe)) {
  //       await refRecipes.add(recipe);
  //     }
  //   }
  // }

  static Future<QuerySnapshot> getRecipes(
    String category,
    int limit, {
    DocumentSnapshot? startAfter,
  }) async {
    final refRecipes = FirebaseFirestore.instance
        .collection('recipies')
        .where("categorie", isEqualTo: category)
        .limit(limit);

    if (startAfter == null) {
      return refRecipes.get();
    } else {
      return refRecipes.startAfterDocument(startAfter).get();
    }
  }
}
