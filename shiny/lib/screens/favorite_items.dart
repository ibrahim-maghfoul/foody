import 'dart:async';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:shiny/components/favorite_card.dart';
import 'package:shiny/models/ad_helper.dart';
import 'package:shiny/models/dataModel.dart';
import 'package:shiny/models/styles.dart';
import 'package:shiny/screens/selected_recipe.dart';

class FavoriteRecipeScreen extends StatefulWidget {
  @override
  _FavoriteRecipeScreenState createState() => _FavoriteRecipeScreenState();
}

class _FavoriteRecipeScreenState extends State<FavoriteRecipeScreen> {
  InterstitialAd? _interstitialAd;
  int _numInterstitialLoadAttempts = 0;

  @override
  void initState() {
    super.initState();
    _createInterstitialAd();
  }

  void _createInterstitialAd() {
    InterstitialAd.load(
        adUnitId: ShowAds.interstialId,
        request: AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            print('$ad loaded');
            _interstitialAd = ad;
            _numInterstitialLoadAttempts = 0;
          },
          onAdFailedToLoad: (LoadAdError error) {
            print('InterstitialAd failed to load: $error.');
            _numInterstitialLoadAttempts += 1;
            _interstitialAd = null;
            if (_numInterstitialLoadAttempts <= maxFailedLoadAttempts) {
              _createInterstitialAd();
            }
          },
        ));
  }

  void _showInterstitialAd() {
    if (_interstitialAd == null) {
      print('Warning: attempt to show interstitial before loaded.');
      return;
    }
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) =>
          print('ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        print('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
        _createInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        print('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        _createInterstitialAd();
      },
    );
    _interstitialAd!.show();
    _interstitialAd = null;
  }

  @override
  void dispose() {
    super.dispose();
    _interstitialAd?.dispose();
  }

  bool isEmpty = false;

  @override
  Widget build(BuildContext context) {
    Future<void> _showMyDialog() async {
      return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (_) {
          return AlertDialog(
            title: Text(
              'تأكيد حذفك لجميع العناصر',
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 18),
            ),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text(
                    'يمكنك إعادة اضافة العناصر لاحقا من الاصناف التي تنتمي إليها',
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
              TextButton(
                onPressed: () {
                  DataModel().removeAllFavorite();
                  DataModel().showSnakBare(false, context);
                  Navigator.of(context).pop();
                },
                child: Text("موافقة"),
                style: TextButton.styleFrom(
                  primary: Colors.pink,
                  onSurface: Colors.red,
                ),
              ),
            ],
          );
        },
      );
    }

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: FaIcon(FontAwesomeIcons.trash),
        onPressed: () {
          if (!isEmpty) _showMyDialog();
        },
      ),
      body: Consumer<DataModel>(
        builder: (context, model, child) {
          return FutureBuilder<List<String>>(
            future: model.favoritedItems(),
            builder:
                (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
              if (!snapshot.hasData) {
                // show loading while waiting for real data
                return Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (snapshot.data?.length != 0) {
                return ListView.builder(
                  physics: BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(8),
                  itemCount: snapshot.data?.length,
                  itemBuilder: (BuildContext context, int index) {
                    return FavoriteCard(
                        showAd: _showInterstitialAd,
                        id: snapshot.data![index],
                        index: index % colors.length);
                  },
                );
              } else {
                isEmpty = true;
                return Center(
                    child: Text(
                  "سلة المفضلة فارغة يمكنك إضافة بعض العناصر",
                  style: TextStyle(color: Colors.grey),
                ));
              }
            },
          );
        },
      ),
    );
  }
}
