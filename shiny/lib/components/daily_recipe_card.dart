import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:shiny/models/ad_helper.dart';
import 'package:shiny/models/dataModel.dart';
import 'package:shiny/models/recipe.dart';
import 'package:shiny/models/styles.dart';
import 'package:shiny/screens/selected_recipe.dart';

class DailyRecipeCard extends StatefulWidget {
  Recipe recipe;
  DailyRecipeCard({required this.recipe});

  @override
  _DailyRecipeCardState createState() => _DailyRecipeCardState();
}

class _DailyRecipeCardState extends State<DailyRecipeCard> {
  static final AdRequest request = AdRequest(
    keywords: <String>['foo', 'bar'],
    contentUrl: 'http://foo.com/bar.html',
    nonPersonalizedAds: true,
  );

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
        request: request,
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

  @override
  Widget build(BuildContext context) {
    Random random = new Random();
    int randomNumber = random.nextInt(colors.length);

    return Stack(
      children: [
        Center(
          child: Container(
            margin: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colors[randomNumber].withOpacity(0.7),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: EdgeInsets.all(30),
            child: Consumer<DataModel>(
              builder: (context, model, child) {
                return Column(
                  children: [
                    Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                        child: Text(widget.recipe.title),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(60),
                          color: colors[randomNumber],
                        )),
                    SizedBox(
                      height: 50,
                    ),
                    Text(
                      widget.recipe.steps,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 17),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 30),
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        border:
                            Border.all(color: colors[randomNumber], width: 3),
                        borderRadius: BorderRadius.circular(60),
                        color: Colors.white,
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.favorite,
                          color: colors[randomNumber],
                          size: 30,
                        ),
                        onPressed: () {
                          Provider.of<DataModel>(context, listen: false)
                              .addToFavorite(widget.recipe.id);
                          DataModel().showSnakBare(true, context);
                          _showInterstitialAd();
                        },
                      ),
                    )
                  ],
                );
              },
            ),
          ),
        ),
        Positioned(
          child: Container(
            height: 20,
            width: 20,
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(20)),
          ),
          bottom: 30,
          left: 30,
        ),
        Positioned(
          child: Container(
            height: 20,
            width: 20,
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(20)),
          ),
          bottom: 30,
          right: 30,
        ),
        Positioned(
          child: Container(
            height: 20,
            width: 20,
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(20)),
          ),
          top: 30,
          left: 30,
        ),
        Positioned(
          child: Container(
            height: 20,
            width: 20,
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(20)),
          ),
          top: 30,
          right: 30,
        ),
      ],
    );
  }
}
