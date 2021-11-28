import 'package:cached_network_image/cached_network_image.dart';
import 'package:foody/models/ad_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:foody/pages/detail_page.dart';
import 'package:foody/providers/recipes_provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
// import 'package:native_admob_flutter/native_admob_flutter.dart';

const int maxFailedLoadAttempts = 3;

class ListViewWidget extends StatefulWidget {
  final RecipesProvider recipesProvider;
  final String categorie;

  const ListViewWidget(
      {required this.recipesProvider, required this.categorie});

  @override
  _ListViewWidgetState createState() => _ListViewWidgetState();
}

class _ListViewWidgetState extends State<ListViewWidget> {
  final scrollController = ScrollController();
  InterstitialAd? _interstitialAd;
  int _numInterstitialLoadAttempts = 0;

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
      size: AdSize.largeBanner,
      request: AdRequest(),
      adUnitId: AdHelper.bannerAdUnitId,
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

  void _createInterstitialAd() {
    InterstitialAd.load(
        adUnitId: AdHelper.interstialAdUnitId,
        request: AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            print('$ad loaded');
            _interstitialAd = ad;
            _numInterstitialLoadAttempts = 0;
            _interstitialAd!.setImmersiveMode(true);
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
  void initState() {
    super.initState();
    _createInterstitialAd();
    scrollController.addListener(scrollListener);
    widget.recipesProvider.fetchNextRecipes(widget.categorie);
  }

  @override
  void dispose() {
    scrollController.dispose();
    _interstitialAd?.dispose();

    _anchoredBanner?.dispose();

    super.dispose();
  }

  void scrollListener() {
    if (scrollController.offset >=
            scrollController.position.maxScrollExtent / 2 &&
        !scrollController.position.outOfRange) {
      if (widget.recipesProvider.hasNext) {
        widget.recipesProvider.fetchNextRecipes(widget.categorie);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_loadingAnchoredBanner) {
      _loadingAnchoredBanner = true;
      _createAnchoredBanner(context);
    }
    return ListView(
      controller: scrollController,
      physics: BouncingScrollPhysics(),
      padding: EdgeInsets.all(12),
      children: [
        if (_anchoredBanner != null)
          Container(
            width: _anchoredBanner!.size.width.toDouble(),
            height: _anchoredBanner!.size.height.toDouble(),
            child: AdWidget(ad: _anchoredBanner!),
          ),
        ...widget.recipesProvider.recipes.map((recipe) {
          return RecipeCard(
              showAd: _showInterstitialAd,
              id: recipe.id,
              image: recipe.image,
              title: recipe.title,
              difficulty: recipe.difficulty,
              note: recipe.note,
              rate: recipe.rate);
        }).toList(),
        if (widget.recipesProvider.hasNext)
          Center(
            child: GestureDetector(
              onTap: () {
                widget.recipesProvider.fetchNextRecipes(widget.categorie);
              },
              child: Container(
                height: 25,
                width: 25,
                child: CircularProgressIndicator(),
              ),
            ),
          ),
      ],
    );
  }
}

class RecipeCard extends StatelessWidget {
  final Function showAd;
  final String id;
  final String image;

  final String title;
  final String difficulty;
  final String note;
  final int rate;

  const RecipeCard(
      {required this.showAd,
      required this.id,
      required this.image,
      required this.title,
      required this.difficulty,
      required this.note,
      required this.rate});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: GestureDetector(
        onTap: () {
          showAd();
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => RecipeDetailPage(
                id: id,
                image: image,
                title: title,
              ),
            ),
          );
        },
        child: Container(
          padding: EdgeInsets.all(0),
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                //height: 300,
                child: Stack(
                  children: [
                    imageNetwork(image, id),
                    Positioned(
                      child: Container(
                        alignment: Alignment.center,
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10)),
                        height: 40,
                        child: Text(
                          difficulty,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      top: 10,
                      right: 10,
                    )
                  ],
                ),
              ),
              ListTile(
                contentPadding: EdgeInsets.all(8),
                title: Text(title),
                subtitle: Text(
                  note,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Container(
                  width: 33,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(rate.toString()),
                      Icon(
                        Icons.star_rounded,
                        color: Colors.yellow,
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget imageNetwork(String url, String id) {
    ErrorWidget.builder = (FlutterErrorDetails details) {
      bool inDebug = false;
      assert(() {
        inDebug = true;
        return true;
      }());
      if (inDebug) {
        return ErrorWidget(details.exception);
      }
      return Container(
        alignment: Alignment.center,
        child: const Text(
          'Error!',
          style: const TextStyle(color: Colors.yellow),
          textDirection: TextDirection.ltr,
        ),
      );
    };
    return Hero(
      tag: id,
      child: CachedNetworkImage(
        height: 250,
        width: double.infinity,
        imageUrl: url,
        fit: BoxFit.cover,
        cacheManager:
            CacheManager(Config("cacheKey", stalePeriod: Duration(days: 10))),
        progressIndicatorBuilder: (context, url, downloadProgress) => Center(
            child: CircularProgressIndicator(value: downloadProgress.progress)),
        errorWidget: (context, url, error) {
          print("Will delete $url");

          return Icon(Icons.error);
        },
      ),
    );
  }
}
