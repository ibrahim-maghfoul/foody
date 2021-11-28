import 'dart:math';

import 'package:flutter/material.dart';

import 'package:shiny/models/dataModel.dart';
import 'package:shiny/models/recipe.dart';
import 'package:shiny/models/styles.dart';

class SelectedRecipeCard extends StatelessWidget {
  final String id;
  final int index;
  final Function showAd;

  SelectedRecipeCard(
      {required this.id, required this.index, required this.showAd});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    Recipe recipe = DataModel().selectedRecipe(id);
    Random random = new Random();
    int randomNumber = 1;

    randomNumber = random.nextInt(4) + 1;

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.topCenter,
            children: [
              Container(
                margin: EdgeInsets.only(top: 60, left: 10, right: 10),
                width: width,
                //height: 500,
                decoration: BoxDecoration(
                  color: colors[index].withOpacity(0.7),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(80),
                    topRight: Radius.circular(80),
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: [
                    SizedBox(
                      height: 100,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: colors[index],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 20),
                        child: Text(
                          recipe.title,
                          style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'monadi',
                              fontSize: 15),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        recipe.steps,
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w100,
                            fontFamily: 'somar',
                            fontSize: 25),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(
                      height: 100,
                    )
                  ],
                ),
              ),
              Container(
                height: 140,
                width: 140,
                decoration: BoxDecoration(
                    border: Border.all(color: colors[index], width: 10),
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(90)),
                child: Image(
                  image: AssetImage(
                      'lib/assets/images/avatars/girl$randomNumber.png'),
                ),
              ),
              Container(
                height: 140,
                width: 140,
                decoration: BoxDecoration(
                    border: Border.all(color: colors[index], width: 10),
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(90)),
              ),
              Positioned(
                child: Container(
                  height: 20,
                  width: 20,
                  decoration: BoxDecoration(
                      color: colors[index],
                      borderRadius: BorderRadius.circular(20)),
                ),
                bottom: 15,
                right: 15,
              ),
              Positioned(
                child: Container(
                  height: 20,
                  width: 20,
                  decoration: BoxDecoration(
                      color: colors[index],
                      borderRadius: BorderRadius.circular(20)),
                ),
                bottom: 15,
                left: 15,
              ),
              Positioned(
                child: Container(
                  height: 70,
                  width: 70,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: colors[index], width: 3),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: IconButton(
                      splashColor: Colors.grey,
                      color: colors[index],
                      icon: Icon(
                        Icons.favorite,
                        size: 50,
                      ),
                      onPressed: () {
                        DataModel().showSnakBare(true, context);
                        showAd();
                      }),
                ),
                bottom: 30,
              )
            ],
          )
        ],
      ),
    );
  }
}
