import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:foody/models/ad_helper.dart';
import 'package:foody/models/favorite_model.dart';
import 'package:foody/widgets/recipe_listView.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive/hive.dart';

import 'package:provider/provider.dart';

class FavoritePage extends StatefulWidget {
  @override
  _FavoritePageState createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  var box;

  BannerAd? _anchoredBanner;

  bool _loadingAnchoredBanner = false;
  Future<void> _createAnchoredBanner(BuildContext context) async {
    final AnchoredAdaptiveBannerAdSize? size =
        await AdSize.getAnchoredAdaptiveBannerAdSize(
      Orientation.portrait,
      MediaQuery.of(context).size.width.truncate(),
    );

    if (size == null) {
      return;
    }

    final BannerAd banner = BannerAd(
      size: AdSize.largeBanner,
      request: AdRequest(),
      adUnitId: AdHelper.bannerAdUnitId,
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          setState(() {
            _anchoredBanner = ad as BannerAd?;
          });
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          ad.dispose();
        },
      ),
    );
    return banner.load();
  }

  @override
  void dispose() {
    _anchoredBanner?.dispose();
    _interstitialAd?.dispose();
    super.dispose();
  }

  InterstitialAd? _interstitialAd;
  int _numInterstitialLoadAttempts = 0;

  void _createInterstitialAd() {
    InterstitialAd.load(
      adUnitId: AdHelper.interstialAdUnitId,
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _interstitialAd = ad;
          _numInterstitialLoadAttempts = 0;
          _interstitialAd!.setImmersiveMode(true);
        },
        onAdFailedToLoad: (LoadAdError error) {
          _numInterstitialLoadAttempts += 1;
          _interstitialAd = null;
          if (_numInterstitialLoadAttempts <= maxFailedLoadAttempts) {
            _createInterstitialAd();
          }
        },
      ),
    );
  }

  void _showInterstitialAd() {
    if (_interstitialAd == null) {
      return;
    }
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        ad.dispose();
        _createInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        ad.dispose();
        _createInterstitialAd();
      },
    );
    _interstitialAd!.show();
    _interstitialAd = null;
  }

  @override
  void initState() {
    super.initState();
    _createInterstitialAd();
  }

  final favoriteBox = Hive.box('favorite');

  @override
  Widget build(BuildContext context) {
    if (!_loadingAnchoredBanner) {
      _loadingAnchoredBanner = true;
      _createAnchoredBanner(context);
    }
    final provider = Provider.of<FavoriteModel>(context, listen: false);

    return SafeArea(
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Scaffold(
            appBar: AppBar(
              actions: [
                IconButton(
                  icon: Icon(Icons.clear_all_rounded),
                  onPressed: () {
                    showDialog(
                      barrierDismissible: true,
                      context: context,
                      builder: (_) => AlertDialog(
                        title: Text(
                          "Warning ! You're about to delete everything !",
                          textAlign: TextAlign.center,
                        ),
                        // content: //Image.asset("alertDialogue"),
                        elevation: 2,
                        actions: [
                          TextButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: FaIcon(FontAwesomeIcons.checkCircle,
                                size: 15, color: Colors.green[200]),
                            label: Text(
                              "Cancel!",
                              style: TextStyle(color: Colors.green[200]),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(right: 5),
                            decoration: BoxDecoration(
                                color: Colors.red[200],
                                borderRadius: BorderRadius.circular(8)),
                            child: TextButton.icon(
                              onPressed: () {
                                provider.clearBox();
                                Navigator.pop(context);
                              },
                              icon: FaIcon(
                                FontAwesomeIcons.trash,
                                color: Colors.white,
                                size: 15,
                              ),
                              label: Text(
                                "Delete",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          )
                        ],
                      ),
                    );
                  },
                )
              ],
              centerTitle: true,
              backgroundColor: Colors.green[300],
              title: Text(
                "Favorite",
              ),
            ),
            body: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Consumer<FavoriteModel>(
                    builder: (context, favorite, child) {
                      return FutureBuilder(
                        future: Hive.openBox<FavoriteRecipe>('favorite'),
                        builder: (ctx, snapshot) {
                          var favoritebox = provider.getBox();
                          if (favoriteBox.length == 0 &&
                              snapshot.connectionState ==
                                  ConnectionState.done) {
                            return Container(
                              height: MediaQuery.of(context).size.height / 1.2,
                              child: Center(
                                  child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                      "Favorite basket is empty try to add more Recipes"),
                                  SizedBox(height: 20),
                                  Container(
                                    decoration: BoxDecoration(
                                        color: Colors.green[300],
                                        borderRadius: BorderRadius.circular(6)),
                                    child: TextButton.icon(
                                      icon: Icon(
                                        Icons.navigate_next,
                                        color: Colors.white,
                                      ),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      label: Text(
                                        "Go To Recipes Page!",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ],
                              )),
                            );
                          }

                          return ListView.builder(
                            shrinkWrap: true,
                            physics: ScrollPhysics(),
                            //key: UniqueKey(),
                            itemCount: favoritebox.length,
                            itemBuilder: (BuildContext ctx, int index) {
                              final favoriteItem =
                                  favoritebox.getAt(index) as FavoriteRecipe;
                              return RecipeCard(
                                  showAd: () {}, // _showInterstitialAd,
                                  id: favoriteItem.id,
                                  image: favoriteItem.image,
                                  title: favoriteItem.title,
                                  difficulty: favoriteItem.difficulty,
                                  note: favoriteItem.note,
                                  rate: favoriteItem.rate);
                            },
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          if (_anchoredBanner != null)
            Container(
              width: _anchoredBanner!.size.width.toDouble(),
              height: _anchoredBanner!.size.height.toDouble(),
              child: AdWidget(ad: _anchoredBanner!),
            ),
        ],
      ),
    );
  }
}
