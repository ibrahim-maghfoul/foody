import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shiny/models/ad_helper.dart';

import 'package:shiny/models/dataModel.dart';
import 'package:shiny/models/styles.dart';
import 'package:shiny/screens/bmi_result.dart';
import 'package:shiny/screens/selected_recipe.dart';

class BmiCalculatorScreen extends StatefulWidget {
  @override
  _BmiCalculatorScreenState createState() => _BmiCalculatorScreenState();
}

class _BmiCalculatorScreenState extends State<BmiCalculatorScreen> {
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

  int age = 18;
  int weight = 45;
  int height = 140;
  double bmi = 21;
  @override
  Widget build(BuildContext context) {
    double bmi = 0;
    final width = MediaQuery.of(context).size.width;

    void increseAge() {
      setState(() {
        age++;
      });
    }

    void decreseAge() {
      setState(() {
        age--;
      });
    }

    void increseWeight() {
      setState(() {
        weight++;
      });
    }

    void decreseAgeWeight() {
      setState(() {
        weight--;
      });
    }

    void resetParametrs() {
      setState(() {
        age = 18;
        weight = 40;
        height = 120;
      });
    }

    void navigateToPage() {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) {
          return BmiResultScreen(
            bmi: bmi,
          );
        }),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('حساب الوزن المثالي'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  BmiAgeCard(
                    onTapincrease: increseAge,
                    onTapDecrease: decreseAge,
                    index: age,
                    width: width,
                    type: 'السن',
                  ),
                  BmiAgeCard(
                    onTapincrease: increseWeight,
                    onTapDecrease: decreseAgeWeight,
                    index: weight,
                    width: width,
                    type: "الوزن",
                  ),
                ],
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: 10),
                padding: EdgeInsets.symmetric(vertical: 30),
                width: width,
                decoration: BoxDecoration(
                  color: colors[4].withOpacity(0.7),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                      decoration: BoxDecoration(
                        color: colors[4],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'الطول',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          " سم",
                          style: kSmallText,
                        ),
                        Text(
                          "$height",
                          style: kLargeText,
                        ),
                      ],
                    ),
                    Slider(
                      value: height.toDouble(),
                      onChanged: (double newValue) {
                        setState(() {
                          height = newValue.toInt();
                        });
                      },
                      min: 50,
                      max: 200,
                      activeColor: colors[4],
                      inactiveColor: Colors.white,
                    )
                  ],
                ),
              ),
              SizedBox(
                height: 40,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: resetParametrs,
                    child: Container(
                      alignment: Alignment.center,
                      margin: EdgeInsets.symmetric(horizontal: 20),
                      height: 100,
                      width: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        color: colors[4].withOpacity(0.7),
                      ),
                      child: FaIcon(
                        FontAwesomeIcons.redo,
                        color: Colors.white,
                        size: 50,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      bmi = DataModel().calculateBmi(height, weight);
                      _showInterstitialAd();
                      navigateToPage();
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 20),
                      alignment: Alignment.center,
                      height: 100,
                      width: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        color: colors[4].withOpacity(0.7),
                      ),
                      child: FaIcon(
                        FontAwesomeIcons.arrowRight,
                        color: Colors.white,
                        size: 50,
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

class BmiAgeCard extends StatelessWidget {
  VoidCallback onTapincrease;
  VoidCallback onTapDecrease;
  int index;
  double width;
  String type;
  BmiAgeCard(
      {required this.onTapincrease,
      required this.index,
      required this.onTapDecrease,
      required this.width,
      required this.type});
  @override
  Widget build(BuildContext context) {
    //final width = MediaQuery.of(context).size.width;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          height: width / 2,
          width: width / 2 - 10,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: colors[4].withOpacity(0.7),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                decoration: BoxDecoration(
                  color: colors[4],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$type',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
              Text('$index', style: kLargeText),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  InkWell(
                    onTap: onTapDecrease,
                    child: Container(
                      alignment: Alignment.center,
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        color: colors[4],
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: FaIcon(
                        FontAwesomeIcons.minus,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: onTapincrease,
                    child: Container(
                      alignment: Alignment.center,
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        color: colors[4],
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: FaIcon(
                        FontAwesomeIcons.plus,
                        color: Colors.white,
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        )
      ],
    );
  }
}
