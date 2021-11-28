import 'package:flutter/material.dart';
import 'package:shiny/components/category_card.dart';
import 'package:shiny/models/dataModel.dart';
import 'package:shiny/models/recipe.dart';

class CategoriesScreen extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<CategoriesScreen> {
  List<Category> category = DataModel().categories;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    for (int i = 0; i < 4; i++)
                      if (i % 2 == 0)
                        FirstCategoryCard(
                          index: i,
                          category: category[i],
                        )
                      else
                        SecondCategoryCard(
                          index: i,
                          category: category[i],
                        )
                  ],
                ),
                Column(
                  children: [
                    for (int i = 4; i < 8; i++)
                      if (i % 2 == 0)
                        SecondCategoryCard(
                          index: i,
                          category: category[i],
                        )
                      else
                        FirstCategoryCard(
                          index: i,
                          category: category[i],
                        )
                  ],
                ),
              ],
            ),
            SizedBox(
              height: 20,
            )
          ],
        ),
      ),
    );
  }
}
