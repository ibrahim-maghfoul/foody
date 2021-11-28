import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:shiny/models/dataModel.dart';
import 'package:shiny/models/recipe.dart';
import 'package:shiny/models/styles.dart';
import 'package:shiny/screens/selected_recipe.dart';

class WeightCard extends StatelessWidget {
  final Recipe recipe;
  final int index;
  final Function showAd;
  WeightCard({required this.recipe, required this.index, required this.showAd});
  @override
  Widget build(BuildContext context) {
    int colorIndex = index % colors.length;
    bool isAddShowen = false;
    void toSelectedRecipeScreen() {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => SelectedRecipeScreen(
                recipeId: recipe.id,
                index: colorIndex,
              )));
    }

    final width = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      child: Stack(
        alignment: AlignmentDirectional.center,
        overflow: Overflow.visible,
        children: [
          GestureDetector(
            onTap: () {
              showAd();
              toSelectedRecipeScreen();
            },
            child: Container(
              padding: EdgeInsets.all(8),
              width: width / 2,
              //height: 300,
              decoration: BoxDecoration(
                  color: colors[colorIndex].withOpacity(0.7),
                  borderRadius: BorderRadius.circular(20)),
              child: Column(
                //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 20, horizontal: 5),
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: colors[colorIndex]),
                      child: Text(
                        recipe.title,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: Colors.white),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        recipe.steps,
                        maxLines: 9,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                    child: Text(
                      'المزيد',
                      style: TextStyle(color: Colors.white),
                    ),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(40),
                        color: colors[colorIndex]),
                  )
                ],
              ),
            ),
          ),
          Positioned(
            child: CircleAvatar(
              radius: 20,
              backgroundColor: colors[colorIndex],
              child: IconButton(
                onPressed: () {
                  Provider.of<DataModel>(context, listen: false)
                      .addToFavorite(recipe.id);
                  DataModel().showSnakBare(true, context);
                  if (!isAddShowen) showAd();
                  isAddShowen = true;
                },
                icon: Icon(
                  Icons.favorite,
                  color: Colors.white,
                ),
              ),
            ),
            top: -15,
            left: -15,
          ),
          Positioned(
            child: Container(
              height: 15,
              width: 15,
              decoration: BoxDecoration(
                  color: colors[colorIndex],
                  borderRadius: BorderRadius.circular(20)),
            ),
            bottom: 10,
            left: 10,
          ),
          Positioned(
            child: Container(
              height: 15,
              width: 15,
              decoration: BoxDecoration(
                  color: colors[colorIndex],
                  borderRadius: BorderRadius.circular(20)),
            ),
            bottom: 10,
            right: 10,
          ),
          Positioned(
            child: Container(
              height: 15,
              width: 15,
              decoration: BoxDecoration(
                  color: colors[colorIndex],
                  borderRadius: BorderRadius.circular(20)),
            ),
            top: 10,
            right: 10,
          ),
        ],
      ),
    );
  }
}
