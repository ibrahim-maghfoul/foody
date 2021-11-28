import 'package:flutter/material.dart';
import 'package:shiny/components/daily_recipe_card.dart';
import 'package:shiny/models/dataModel.dart';
import 'package:shiny/models/recipe.dart';

class DailyRecipeScreen extends StatefulWidget {
  @override
  _DailyRecipeScreenState createState() => _DailyRecipeScreenState();
}

class _DailyRecipeScreenState extends State<DailyRecipeScreen> {
  @override
  Widget build(BuildContext context) {
    //Recipe recipe = DataModel().recipies[randomNumber];
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 20,
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 30, vertical: 2),
              height: 60,
              width: double.infinity,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: Colors.pink[200]),
              child: Center(
                  child: Text(
                'وصفة اليوم',
                style: TextStyle(color: Colors.white, fontSize: 17),
              )),
            ),
            FutureBuilder<Recipe>(
              future: DataModel().randomRecipe(),
              builder: (BuildContext context, AsyncSnapshot<Recipe> snapshot) {
                if (!snapshot.hasData) {
                  // show loading while waiting for real data
                  return Center(child: CircularProgressIndicator());
                }

                return DailyRecipeCard(
                    recipe: snapshot.data ?? DataModel().recipies[0]);
              },
            ),
          ],
        ),
      ),
    );
  }
}
