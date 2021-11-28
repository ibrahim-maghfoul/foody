import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shiny/components/weight_card.dart';
import 'package:shiny/models/ad_helper.dart';
import 'package:shiny/models/dataModel.dart';
import 'package:shiny/screens/selected_recipe.dart';

class BodyWieght extends StatefulWidget {
  @override
  _BodyWieghtState createState() => _BodyWieghtState();
}

class _BodyWieghtState extends State<BodyWieght> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
      padding: const EdgeInsets.all(8.0),
      child: GridView.count(
        physics: BouncingScrollPhysics(),
        crossAxisCount: 2,
        childAspectRatio: (1 / 2.1),
        controller: new ScrollController(keepScrollOffset: false),
        //shrinkWrap: true,
        scrollDirection: Axis.vertical,
        children:
            List.generate(DataModel().listOfWeightRecipe().length, (index) {
          return WeightCard(
            showAd: () {
              _showInterstitialAd();
            },
            recipe: DataModel().listOfWeightRecipe()[index],
            index: index,
          );
        }),
      ),
    ));
    /*child: WeightCard(
        recipe: DataModel().listOfWeightRecipe()[0],
      ),*/
  }
}
