import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:foody/models/ad_helper.dart';
import 'package:foody/models/favorite_model.dart';
import 'package:foody/providers/recipes_provider.dart';
import 'package:foody/widgets/recipe_listView.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

class RecipeDetailPage extends StatefulWidget {
  const RecipeDetailPage({
    required this.id,
    required this.image,
    required this.title,
  });
  final String id;
  final String image;
  final String title;

  @override
  _RecipeDetailPageState createState() => _RecipeDetailPageState();
}

class _RecipeDetailPageState extends State<RecipeDetailPage> {
  InterstitialAd? _interstitialAd;
  int _numInterstitialLoadAttempts = 0;

  RewardedAd? _rewardedAd;
  int _numRewardedLoadAttempts = 0;

  void _createRewardedAd() {
    RewardedAd.load(
      adUnitId: AdHelper.rewardedAdUnitId,
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
    bool check = true;
    bool _isShowed = true;
    bool _isLikedAdShowed = true;
    final provider = Provider.of<FavoriteModel>(context, listen: false);
    var snapShot = FirebaseFirestore.instance
        .collection('recipies')
        .where("id", isEqualTo: widget.id)
        .get();
    snapShot.then(
      (value) {
        var docs = value.docs;
        var selectedDoc = docs[0];
        var recipe = RecipesProvider().selectedRecipeFromDocs(selectedDoc);
        provider.switchFavorite(recipe.id);
      },
    );
    if (!_loadingAnchoredBanner) {
      _loadingAnchoredBanner = true;
      _createAnchoredBanner(context);
    }
    return Scaffold(
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          CustomScrollView(physics: BouncingScrollPhysics(), slivers: [
            SliverAppBar(
              centerTitle: true,
              actions: [
                Builder(
                  builder: (BuildContext context) {
                    return IconButton(
                      icon: Consumer<FavoriteModel>(
                        builder: (context, favoriteProvider, _) {
                          if (favoriteProvider.isFavorite)
                            return Icon(Icons.favorite_border);
                          else
                            return Icon(Icons.favorite);
                        },
                      ),
                      onPressed: () {
                        if (_isShowed) {
                          //_showInterstitialAd();
                          _isShowed = false;
                        }

                        snapShot.then(
                          (value) {
                            var docs = value.docs;
                            var selectedDoc = docs[0];
                            var recipe = RecipesProvider()
                                .selectedRecipeFromDocs(selectedDoc);

                            provider.addToFavorite(
                                recipe.title,
                                recipe.image,
                                recipe.id,
                                recipe.note,
                                recipe.tips,
                                recipe.categorie,
                                recipe.difficulty,
                                recipe.nutritions,
                                recipe.instructions,
                                recipe.ingredients,
                                recipe.methods,
                                recipe.rate,
                                context);
                          },
                        );
                      },
                    );
                  },
                )
              ],
              backgroundColor: Colors.green,
              expandedHeight: 250,
              flexibleSpace: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.bottomCenter,
                children: [
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    child: Hero(
                      child: CachedNetworkImage(
                        errorWidget: (context, url, error) => Center(
                          child: FaIcon(
                            FontAwesomeIcons.sadCry,
                            size: 60,
                            color: Colors.white,
                          ),
                        ),
                        imageUrl: widget.image,
                        fit: BoxFit.cover,
                      ),
                      tag: widget.id,
                    ),
                  ),
                  Container(
                    color: Colors.black.withOpacity(0.3),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                    child: Text(
                      widget.title,
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            SliverList(
              delegate: SliverChildListDelegate(
                <Widget>[
                  FutureBuilder(
                    future: snapShot,
                    builder: (_, AsyncSnapshot snapshot) {
                      if (snapshot.hasData) {
                        var docs = snapshot.data.docs;
                        var selectedDoc = docs[0];
                        var recipe = RecipesProvider()
                            .selectedRecipeFromDocs(selectedDoc);
                        if (recipe.tips == "N/A") {
                          check = false;
                        }
                        return Padding(
                          padding: const EdgeInsets.all(0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (recipe.note != "N/A" ||
                                  recipe.note != "" ||
                                  recipe.note != "None")
                                titleSection("Note"),
                              if (recipe.note != "N/A" ||
                                  recipe.note != "" ||
                                  recipe.note != "None")
                                Card(
                                  color: Colors.pink[200],
                                  child: ListTile(
                                    title: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        recipe.note,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ),
                              Card(
                                color: Colors.green[100],
                                child: ListView.builder(
                                  physics: NeverScrollableScrollPhysics(),
                                  padding: EdgeInsets.zero,
                                  itemCount: recipe.instructions.length,
                                  shrinkWrap: true,
                                  itemBuilder: (context, index) {
                                    return Container(
                                      margin: EdgeInsets.all(8),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                            width: 15,
                                          ),
                                          if (recipe.instructions[index]
                                              .contains("Prep"))
                                            FaIcon(
                                              FontAwesomeIcons.clock,
                                              color: Colors.blue,
                                            ),
                                          if (recipe.instructions[index]
                                              .contains("Serves"))
                                            FaIcon(
                                              FontAwesomeIcons.peopleArrows,
                                              color: Colors.blue,
                                            ),
                                          if (recipe.instructions[index]
                                                  .contains("Easy") ||
                                              recipe.instructions[index]
                                                  .contains("More effort"))
                                            FaIcon(
                                              FontAwesomeIcons.hardHat,
                                              color: Colors.blue,
                                            ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width -
                                                80,
                                            child: Text(
                                              recipe.instructions[index],
                                              textAlign: TextAlign.start,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                              titleSection("Ingredients"),
                              ListView.builder(
                                padding: EdgeInsets.zero,
                                physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: recipe.ingredients.length,
                                itemBuilder: (_, index) {
                                  return Card(
                                    child: ListTile(
                                      trailing: FaIcon(
                                        FontAwesomeIcons.check,
                                        color: Colors.green,
                                      ),
                                      title: Text(recipe.ingredients[index]),
                                      leading: CircleAvatar(
                                        backgroundColor: Colors.orange,
                                        child: Text(
                                          (index + 1).toString(),
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              titleSection("Method"),
                              ListView.builder(
                                padding: EdgeInsets.zero,
                                physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: recipe.methods.length,
                                itemBuilder: (_, index) {
                                  return Card(
                                    child: ListTile(
                                      trailing: FaIcon(
                                        FontAwesomeIcons.check,
                                        color: Colors.green,
                                      ),
                                      title: Text(recipe.methods[index]),
                                      leading: CircleAvatar(
                                        backgroundColor: Colors.red[600],
                                        child: Text(
                                          (index + 1).toString(),
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              if (check) titleSection("Tips"),
                              if (check)
                                Card(
                                  child: ListTile(
                                    title: Text(recipe.tips),
                                    trailing: FaIcon(
                                      FontAwesomeIcons.checkCircle,
                                    ),
                                  ),
                                ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        if (_isLikedAdShowed) {
                                          // _showInterstitialAd();
                                          _isLikedAdShowed = false;
                                        }
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                            color: Colors.blue,
                                            borderRadius:
                                                BorderRadius.circular(6)),
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
                                        // _showRewardedAd();
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                            color: Colors.green[300],
                                            borderRadius:
                                                BorderRadius.circular(6)),
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
                              titleSection("Nutrition per serving"),
                              ListView.builder(
                                padding: EdgeInsets.zero,
                                physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: (recipe.nutritions.length ~/ 2),
                                itemBuilder: (_, index) {
                                  var car = [];
                                  var val = [];
                                  for (int i = 0;
                                      i < recipe.nutritions.length;
                                      i++) {
                                    if (i % 2 == 0) {
                                      car.add(recipe.nutritions[i]);
                                    } else {
                                      val.add(recipe.nutritions[i]);
                                    }
                                  }
                                  return Card(
                                    child: ListTile(
                                      trailing: Text(val[index]),
                                      title: Text(car[index]),
                                      leading: CircleAvatar(
                                        backgroundColor: Colors.green[600],
                                        child: Text(
                                          (index + 1).toString(),
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        );
                      } else
                        return Center(
                            child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(),
                        ));
                    },
                  ),
                  SizedBox(
                    height: 100,
                  )
                ],
              ),
            )
          ]),
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

  Widget titleSection(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            height: 30,
            width: 5,
            color: Colors.blue,
          ),
          SizedBox(
            width: 10,
          ),
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ],
      ),
    );
  }
}
