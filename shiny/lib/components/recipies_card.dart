import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:shiny/models/dataModel.dart';
import 'package:shiny/models/recipe.dart';
import 'package:shiny/models/styles.dart';
import 'package:shiny/screens/selected_recipe.dart';

class SecondRecipeCard extends StatelessWidget {
  final Recipe recipe;
  final int index;
  final Function showAd;
  SecondRecipeCard(
      {required this.recipe, required this.index, required this.showAd});
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    int colorIndex = index % colors.length;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
      child: Stack(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => SelectedRecipeScreen(
                    recipeId: recipe.id,
                    index: colorIndex,
                  ),
                ),
              );

              showAd();
            },
            child: Container(
              width: width,
              height: 200,
              decoration: BoxDecoration(
                color: colors[colorIndex].withOpacity(0.7),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(150),
                  topRight: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      recipe.title,
                      style: TextStyle(
                          color: Colors.grey[700],
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monadi',
                          fontSize: 18),
                      textAlign: TextAlign.right,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 70, right: 20),
                    child: Text(
                      recipe.steps,
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w100,
                          fontFamily: 'somar',
                          fontSize: 15),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                color: colors[colorIndex],
              ),
              child: Center(
                child: Text(
                  recipe.subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monadi',
                      fontSize: 15),
                ),
              ),
            ),
            bottom: 15,
            right: 20,
          ),
          Positioned(
            child: Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                color: colors[colorIndex],
              ),
              child: IconButton(
                icon: Icon(Icons.favorite),
                onPressed: () {
                  showAd();
                  Provider.of<DataModel>(context, listen: false)
                      .addToFavorite(recipe.id);
                  DataModel().showSnakBare(true, context);
                },
                color: Colors.white,
                iconSize: 30,
              ),
            ),
            left: 15,
            top: 30,
          ),
          Positioned(
            child: Container(
              height: 15,
              width: 15,
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(10)),
            ),
            bottom: 10,
            left: 10,
          )
        ],
      ),
    );
  }
}

class FirstRecipeCard extends StatelessWidget {
  final Recipe recipe;
  final int index;
  final Function showAd;
  FirstRecipeCard(
      {required this.recipe, required this.index, required this.showAd});
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    int colorIndex = index % colors.length;
    void toSelectedRecipeScreen() {
      //ShowAds().loadInterstitial();

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => SelectedRecipeScreen(
            recipeId: recipe.id,
            index: colorIndex,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
      child: Stack(
        children: [
          GestureDetector(
            onTap: () {
              toSelectedRecipeScreen();
              showAd();
            },
            child: Container(
              width: width,
              height: 200,
              decoration: BoxDecoration(
                color: colors[colorIndex].withOpacity(0.7),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(150),
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Container(
                        width: width / 2,
                        child: Text(
                          recipe.title,
                          style: TextStyle(
                              color: Colors.grey[700],
                              fontWeight: FontWeight.bold,
                              fontFamily: 'monadi',
                              fontSize: 18),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10, right: 80),
                      child: Container(
                        child: Text(
                          recipe.steps,
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w100,
                              fontFamily: 'somar',
                              fontSize: 15),
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),
                  ]),
            ),
          ),
          Positioned(
            child: InkWell(
              onTap: toSelectedRecipeScreen,
              splashColor: Colors.grey,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                //height: 35,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(45),
                  color: colors[colorIndex],
                ),
                child: Center(
                  child: Text(
                    recipe.subtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monadi',
                        fontSize: 15),
                  ),
                ),
              ),
            ),
            bottom: 15,
            left: 20,
          ),
          Positioned(
            child: Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                color: colors[colorIndex],
              ),
              child: IconButton(
                icon: Icon(Icons.favorite),
                onPressed: () {
                  showAd();
                  Provider.of<DataModel>(context, listen: false)
                      .addToFavorite(recipe.id);
                  DataModel().showSnakBare(true, context);
                },
                color: Colors.white,
                iconSize: 30,
              ),
            ),
            right: 15,
            top: 30,
          ),
          Positioned(
            child: Container(
              height: 15,
              width: 15,
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(10)),
            ),
            bottom: 10,
            right: 10,
          )
        ],
      ),
    );
  }
}
