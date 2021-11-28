import 'package:flutter/material.dart';

import 'package:shiny/models/dataModel.dart';
import 'package:shiny/models/recipe.dart';
import 'package:shiny/models/styles.dart';
import 'package:shiny/screens/selected_recipe.dart';

class FavoriteCard extends StatelessWidget {
  final String id;
  final int index;
  final Function showAd;

  const FavoriteCard(
      {required this.id, required this.index, required this.showAd});

  @override
  Widget build(BuildContext context) {
    void toSelectedRecipeScreen() {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => SelectedRecipeScreen(
            recipeId: id,
            index: index,
          ),
        ),
      );
    }

    Future<void> _showMyDialog() async {
      return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (_) {
          return AlertDialog(
            title: Text(
              'تأكيد حذفك للعنصر',
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 18),
            ),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text(
                    'يمكنك إعادة اضافتة لاحقا من الصنف الذي ينتمي إليه',
                    textAlign: TextAlign.right,
                    style: TextStyle(fontSize: 10),
                  ),
                  //Text('Would you like to approve of this message?'),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text('تراجع'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                onPressed: () {
                  DataModel().removeFavorited(id);
                  DataModel().showSnakBare(false, context);
                  Navigator.of(context).pop();
                },
                child: Text("موافقة"),
                color: Colors.pink,
              ),
            ],
          );
        },
      );
    }

    void toSelectedRecipe() {
      showAd();
      toSelectedRecipeScreen();
    }

    Recipe recipe = DataModel().selectedRecipe(id);
    final width = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Stack(alignment: Alignment.center, children: [
        GestureDetector(
          onTap: () {
            toSelectedRecipe();
          },
          child: Container(
            width: width,
            height: 200,
            decoration: BoxDecoration(
              color: colors[index].withOpacity(0.7),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                SizedBox(
                  height: 60,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      recipe.steps,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
        Positioned(
          child: Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: colors[index],
              borderRadius: BorderRadius.circular(20),
            ),
            child: IconButton(
              icon: Icon(
                Icons.delete,
                color: Colors.white,
                size: 25,
              ),
              onPressed: () async {
                _showMyDialog();
                //Provider.of<DataModel>(context, listen: false)
                //.removeFavorited(id);
                //DataModel().removeFavorited(id);
              },
            ),
          ),
          top: 6,
          left: 6,
        ),
        Positioned(
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            decoration: BoxDecoration(
              color: colors[index],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              recipe.title,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white),
            ),
          ),
          top: 10,
          right: 10,
        ),
        Positioned(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              color: colors[index],
            ),
            child: InkWell(
              onTap: toSelectedRecipe,
              child: Center(
                child: Text(
                  'المزيد',
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
        ),
      ]),
    );
  }
}
