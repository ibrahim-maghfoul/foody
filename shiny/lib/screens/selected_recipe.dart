import 'dart:async';

import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

import 'package:flutter/material.dart';
import 'package:shiny/components/choosen_recipe_card.dart';
import 'package:shiny/models/ad_helper.dart';
import 'package:shiny/models/dataModel.dart';
import 'package:shiny/models/styles.dart';

const int maxFailedLoadAttempts = 3;

class SelectedRecipeScreen extends StatefulWidget {
  final String recipeId;
  final int index;
  SelectedRecipeScreen({required this.recipeId, required this.index});

  @override
  _SelectedRecipeScreenState createState() => _SelectedRecipeScreenState();
}

class _SelectedRecipeScreenState extends State<SelectedRecipeScreen> {
  InterstitialAd? _interstitialAd;
  int _numInterstitialLoadAttempts = 0;

  RewardedAd? _rewardedAd;
  int _numRewardedLoadAttempts = 0;

  void _createRewardedAd() {
    RewardedAd.load(
      adUnitId: ShowAds.rewarded,
      request: AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          _rewardedAd = ad;
          _numRewardedLoadAttempts = 0;
        },
        onAdFailedToLoad: (LoadAdError error) {
          _rewardedAd = null;
          _numRewardedLoadAttempts += 1;
          if (_numRewardedLoadAttempts <= maxFailedLoadAttempts) {
            _createRewardedAd();
          }
        },
      ),
    );
  }

  void _showRewardedAd() {
    if (_rewardedAd == null) {
      return;
    }
    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (RewardedAd ad) {
        ad.dispose();
        _createRewardedAd();
      },
      onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
        ad.dispose();
        _createRewardedAd();
      },
    );

    _rewardedAd!.setImmersiveMode(true);
    _rewardedAd!.show(onUserEarnedReward: (RewardedAd ad, RewardItem reward) {
      showDialog(
        barrierDismissible: true,
        context: context,
        builder: (_) => AlertDialog(
          title: Text(
            "Thank you so much ! we appreciate it !",
            textAlign: TextAlign.center,
          ),
          content: Icon(
            Icons.favorite_rounded,
            color: Colors.pink[600],
            size: 80,
          ),

          // content: //Image.asset("alertDialogue"),
          elevation: 2,
        ),
      );
    });
    _rewardedAd = null;
  }

  void _createInterstitialAd() {
    InterstitialAd.load(
        adUnitId: ShowAds.interstialId,
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
        ));
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
      adUnitId: ShowAds.bannerId,
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
  void initState() {
    super.initState();
    _createRewardedAd();
    _createInterstitialAd();
  }

  @override
  void dispose() {
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();

    _anchoredBanner?.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool _isLikedAdShowed = true;
    if (!_loadingAnchoredBanner) {
      _loadingAnchoredBanner = true;
      _createAnchoredBanner(context);
    }
    bool isAddShowen = false;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: colors[widget.index],
        centerTitle: true,
        title: Text(DataModel().selectedRecipe(widget.recipeId).subtitle),
        actions: [
          Builder(
            builder: (context) => IconButton(
                icon: Icon(Icons.favorite),
                onPressed: () {
                  _showInterstitialAd();
                  DataModel().addToFavorite(widget.recipeId);
                  DataModel().showSnakBare(true, context);
                }),
          )
        ],
      ),
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.only(top: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (_isLikedAdShowed) {
                            _showInterstitialAd();
                            _isLikedAdShowed = false;
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(6)),
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.thumb_up_sharp,
                                color: Colors.white,
                              ),
                              SizedBox(
                                width: 6,
                              ),
                              Text(
                                "Enjoy it !",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          _showRewardedAd();
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.green[300],
                              borderRadius: BorderRadius.circular(6)),
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.video_collection,
                                color: Colors.white,
                              ),
                              SizedBox(
                                width: 6,
                              ),
                              Text(
                                "Support us by watching this ad ❤",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: MediaQuery.of(context).size.height -
                      AdSize.fullBanner.height,
                  margin: EdgeInsets.only(top: 8),
                  child: SelectedRecipeCard(
                    showAd: () {
                      _showInterstitialAd();
                      Provider.of<DataModel>(context, listen: false)
                          .addToFavorite(widget.recipeId);
                    },
                    id: widget.recipeId,
                    index: widget.index,
                  ),
                ),
              ],
            ),
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
