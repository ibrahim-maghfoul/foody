import 'package:flutter/material.dart';
import 'package:shiny/models/recipe.dart';
import 'package:shiny/models/styles.dart';
import 'package:shiny/screens/choosen_recipies.dart';

//import 'package:girly_care/screens/recipes_page.dart'
//

class FirstCategoryCard extends StatelessWidget {
  final Category category;
  final int index;
  FirstCategoryCard({required this.category, required this.index});
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    void toRecipiesScreen() {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => RecipiesListScreen(
                  chosenCategory: category.category,
                )),
      );
    }

    return Container(
      margin: EdgeInsets.only(top: 50),
      child: InkWell(
        onTap: toRecipiesScreen,
        splashColor: Colors.grey,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Stack(
            overflow: Overflow.visible,
            alignment: Alignment.center,
            children: [
              Container(
                margin: EdgeInsets.only(top: 5),
                height: 250,
                width: width / 2 - 30,
                //color: Colors.red,
                decoration: BoxDecoration(
                  color: colors[index].withOpacity(0.7),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: Container(
                        margin: EdgeInsets.only(top: 20),
                        padding: EdgeInsets.all(20),
                        child: Text(
                          category.description,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 18, fontFamily: 'somar'),
                        ),
                      ),
                    ),
                    Container(
                      height: 35,
                      width: 90,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          color: colors[index]),
                      //margin: EdgeInsets.only(bottom: 50),
                      child: Center(
                        child: Text(
                          category.title,
                          style: TextStyle(
                            fontSize: 20,
                            fontFamily: 'monadi',
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                child: Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    color: colors[index],
                  ),
                  //margin: EdgeInsets.only(bottom: 240),
                ),
                top: -50,
              ),
              Positioned(
                child: Container(
                  padding: const EdgeInsets.all(4.0),
                  height: 80,
                  width: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40),
                    color: Colors.white,
                  ),
                  //margin: EdgeInsets.only(bottom: 240),
                  child: Image.asset(category.image),
                ),
                top: -40,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SecondCategoryCard extends StatelessWidget {
  final Category category;
  final int index;
  SecondCategoryCard({required this.category, required this.index});
  @override
  Widget build(BuildContext context) {
    void toRecipiesScreen() {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => RecipiesListScreen(
                  chosenCategory: category.category,
                )),
      );
    }

    final width = MediaQuery.of(context).size.width;
    return InkWell(
      onTap: toRecipiesScreen,
      splashColor: Colors.grey,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              margin: EdgeInsets.only(top: 5),
              height: 300,
              width: width / 2 - 30,
              decoration: BoxDecoration(
                color: colors[index].withOpacity(0.7),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Container(
                  padding: EdgeInsets.all(20),
                  margin: EdgeInsets.only(top: 150),
                  child: Text(
                    category.description,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, fontFamily: 'somar'),
                  ),
                ),
              ),
            ),
            Container(
              height: 100,
              width: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: colors[index],
              ),
              margin: EdgeInsets.only(bottom: 140),
            ),
            Container(
              padding: const EdgeInsets.all(4.0),
              height: 80,
              width: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(40),
                color: Colors.white,
              ),
              margin: EdgeInsets.only(bottom: 140),
              child: Image.asset(category.image),
            ),
            Container(
              height: 35,
              width: 90,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: colors[index],
              ),
              margin: EdgeInsets.only(top: 40),
              child: Center(
                child: Text(
                  category.title,
                  style: TextStyle(
                    fontSize: 20,
                    fontFamily: 'monadi',
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
