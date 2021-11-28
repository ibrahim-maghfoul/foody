import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:rate_my_app/rate_my_app.dart';
import 'package:shiny/components/recipies_card.dart';
import 'package:shiny/models/ad_helper.dart';
import 'package:shiny/models/dataModel.dart';
import 'package:shiny/models/recipe.dart';
import 'package:shiny/screens/selected_recipe.dart';
import 'package:url_launcher/url_launcher.dart';

const _url = 'https://play.google.com/store/apps/details?id=com.ariss.shiny';

class RecipiesListScreen extends StatefulWidget {
  final String chosenCategory;
  RecipiesListScreen({required this.chosenCategory});

  @override
  _RecipiesListScreenState createState() => _RecipiesListScreenState();
}

class _RecipiesListScreenState extends State<RecipiesListScreen> {
  RateMyApp _rateMyApp = RateMyApp(
    preferencesPrefix: 'rateMyApp_',
    minDays: 3,
    minLaunches: 7,
    remindDays: 2,
    remindLaunches: 4,
    //googlePlayIdentifier: 'com.ariss.shiny',
  );

  void _launchURL() async {
    await canLaunch(_url) ? await launch(_url) : throw 'Could not launch $_url';
  }

  void showRateDialogue() {
    _rateMyApp.showStarRateDialog(
      context,
      title: 'هل أعجبك تطبيقنا سيدتي؟',
      message: 'المرجو ترك تقييم لنا في المتجر إذا أعجبك التطبيق',
      actionsBuilder: (_, stars) {
        return [
          // Returns a list of actions (that will be shown at the bottom of the dialog).
          FlatButton(
            child: Text('حسنا'),
            onPressed: () async {
              print('Thanks for the ' +
                  (stars == null ? '0' : stars.round().toString()) +
                  ' star(s) !');
              if (stars != null && (stars == 4 || stars == 5)) {
                _launchURL();
                //if the user stars is equal to 4 or five
                // you can redirect the use to playstore or                         appstore to enter their reviews

              } else {
                // else you can redirect the user to a page in your app to tell you how you can make the app better

              }
              // You can handle the result as you want (for instance if the user puts 1 star then open your contact page, if he puts more then open the store page, etc...).
              // This allows to mimic the behavior of the default "Rate" button. See "Advanced > Broadcasting events" for more information :
              await _rateMyApp.callEvent(RateMyAppEventType.rateButtonPressed);
              Navigator.pop<RateMyAppDialogButton>(
                  context, RateMyAppDialogButton.rate);
            },
          ),
        ];
      },
      dialogStyle: DialogStyle(
        titleAlign: TextAlign.center,
        messageAlign: TextAlign.center,
        messagePadding: EdgeInsets.only(bottom: 20.0),
      ),
      starRatingOptions: StarRatingOptions(),
    );
  }

  BannerAd? _anchoredBanner;
  bool _loadingAnchoredBanner = false;

  Future<void> _createAnchoredBanner(BuildContext context) async {
    final AnchoredAdaptiveBannerAdSize? size =
        await AdSize.getAnchoredAdaptiveBannerAdSize(
      Orientation.portrait,
      MediaQuery.of(context).size.width.truncate(),
    );

    if (size == null) {
      print('Unable to get height of anchored banner.');
      return;
    }

    final BannerAd banner = BannerAd(
      size: size,
      request: AdRequest(),
      adUnitId: ShowAds.bannerId,
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          print('$BannerAd loaded.');
          setState(() {
            _anchoredBanner = ad as BannerAd?;
          });
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          print('$BannerAd failedToLoad: $error');
          ad.dispose();
        },
        onAdOpened: (Ad ad) => print('$BannerAd onAdOpened.'),
        onAdClosed: (Ad ad) => print('$BannerAd onAdClosed.'),
      ),
    );
    return banner.load();
  }

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
    if (!_loadingAnchoredBanner) {
      _loadingAnchoredBanner = true;
      _createAnchoredBanner(context);
    }
    List<Recipe> recipies =
        DataModel().listOfChoosenRecipies(widget.chosenCategory);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(DataModel().selectedCategory(widget.chosenCategory).title),
        actions: [
          IconButton(
              icon: Icon(Icons.favorite),
              onPressed: () {
                showRateDialogue();
              }),
        ],
      ),
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          ListView.builder(
            physics: BouncingScrollPhysics(),
            padding: const EdgeInsets.all(8),
            itemCount: recipies.length,
            itemBuilder: (BuildContext context, int index) {
              if (index % 2 == 0)
                return FirstRecipeCard(
                    recipe: recipies[index],
                    index: index,
                    showAd: () {
                      _showInterstitialAd();
                    });
              else
                return SecondRecipeCard(
                  showAd: () {
                    _showInterstitialAd();
                  },
                  recipe: recipies[index],
                  index: index,
                );
            },
          ),
          if (_anchoredBanner != null)
            Container(
              color: Colors.green,
              width: _anchoredBanner!.size.width.toDouble(),
              height: _anchoredBanner!.size.height.toDouble(),
              child: AdWidget(ad: _anchoredBanner!),
            ),
        ],
      ),
    );
  }
}
