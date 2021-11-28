import 'dart:async';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:rate_my_app/rate_my_app.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shiny/models/ad_helper.dart';
import 'package:shiny/models/dataModel.dart';
import 'package:shiny/models/styles.dart';
import 'package:shiny/screens/bmi_calculator.dart';
import 'package:shiny/screens/body_weight.dart';
import 'package:shiny/screens/daily_recipe.dart';
import 'package:shiny/screens/favorite_items.dart';
import 'package:shiny/screens/home_page.dart';
import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:url_launcher/url_launcher.dart';

const _url = 'https://play.google.com/store/apps/details?id=com.ariss.shiny';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  runApp(ChangeNotifierProvider(
    create: (_) => DataModel(),
    //child: BodyWieght(),
    //child: Home(),
    //child: BmiCalculatorScreen(),
    child: MyApp(),
    //child: OnBoardingScreen(),
  ));
  SharedPreferences prefs = await SharedPreferences.getInstance();

  bool _seen = (prefs.getBool('seen') ?? false);

  if (_seen) {
    //prefs.clear();
  } else {
    await prefs.setBool('seen', true);
    prefs.setString('date', DateTime.now().toUtc().toIso8601String());
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Shiny',
      theme: ThemeData(primarySwatch: Colors.pink, fontFamily: 'monadi'),
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  @override
  _NavigationPageState createState() => _NavigationPageState();
}

class _NavigationPageState extends State<Home> {
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

  int currentIndex = 0;
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
      onDismissed: () =>
          _rateMyApp.callEvent(RateMyAppEventType.laterButtonPressed),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    currentIndex = 0;

    _rateMyApp.init().then((_) {
      if (_rateMyApp.shouldOpenDialog) {
        //conditions check if user already rated the app
        showRateDialogue();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _anchoredBanner?.dispose();
    // myBanner.dispose(); // disposes of banner when UI is disposed of
    // disposes of interstitial when UI is disposed of
  }

  void changePage(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  Widget selectedPage() {
    switch (_currentIndex) {
      case 3:
        return CategoriesScreen();
      case 2:
        return FavoriteRecipeScreen();
      case 1:
        return BodyWieght();
      case 0:
        return DailyRecipeScreen();
      default:
        return CategoriesScreen();
    }
  }

  String selectedTitle() {
    switch (_currentIndex) {
      case 3:
        return 'وصفة';
      case 2:
        return 'المفضلة';
      case 1:
        return "زيادة الوزن";
      case 0:
        return 'وصفة اليوم';
      default:
        return 'Categories';
    }
  }

  int _currentIndex = 3;

  @override
  Widget build(BuildContext context) {
    if (!_loadingAnchoredBanner) {
      _loadingAnchoredBanner = true;
      _createAnchoredBanner(context);
    }
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        centerTitle: true,
        backgroundColor: Colors.pink,
        title: Text(
          selectedTitle(),
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              Icons.favorite,
            ),
            onPressed: () {
              showRateDialogue();
              //DataModel().clearPrefs();
            },
          ),
        ],
      ),
      bottomNavigationBar: BottomNavyBar(
        selectedIndex: _currentIndex,
        showElevation: true,
        itemCornerRadius: 24,
        curve: Curves.easeIn,
        onItemSelected: (index) => setState(() => _currentIndex = index),
        items: <BottomNavyBarItem>[
          BottomNavyBarItem(
            icon: FaIcon(
              FontAwesomeIcons.calendarAlt,
              color: colors[1],
            ),
            activeColor: colors[2],
            title: Text("اضافة",
                style: TextStyle(
                  fontFamily: 'monadi',
                  color: colors[2],
                )),
            textAlign: TextAlign.center,
          ),
          BottomNavyBarItem(
              icon: FaIcon(
                FontAwesomeIcons.dumbbell,
                color: colors[4],
              ),
              activeColor: colors[4],
              title: Text("جسمك  ",
                  style: TextStyle(
                    fontFamily: 'monadi',
                    color: colors[4],
                  ))),
          BottomNavyBarItem(
              icon: Icon(
                Icons.favorite,
                color: colors[7],
              ),
              activeColor: colors[8],
              title: Text("المفضلة",
                  style: TextStyle(
                    fontFamily: 'monadi',
                    color: colors[8],
                  ))),
          BottomNavyBarItem(
              icon: Icon(
                Icons.dashboard,
                color: colors[5],
              ),
              activeColor: colors[6],
              title: Text(
                "الرئيسة",
                style: TextStyle(
                  fontFamily: 'monadi',
                  color: colors[6],
                ),
              )),
        ],
      ),
      // ),
      // bottomNavigationBar: BubbleBottomBar(
      //   opacity: .2,
      //   currentIndex: currentIndex,
      //   onTap: changePage,
      //   borderRadius: BorderRadius.vertical(
      //     top: Radius.circular(16),
      //   ), //border radius doesn't work when the notch is enabled.
      //   elevation: 8,
      //   items: <BubbleBottomBarItem>[
      //     BubbleBottomBarItem(
      //         backgroundColor: Colors.red,
      //         // icon: Icon(
      //         //   Icons.info,
      //         //   color: Colors.pink,
      //         // ),
      //         icon: FaIcon(
      //           FontAwesomeIcons.calendarAlt,
      //           color: colors[1],
      //         ),
      //         // activeIcon: Icon(
      //         //   Icons.info,
      //         //   color: Colors.pink,
      //         // ),
      //         activeIcon: FaIcon(
      //           FontAwesomeIcons.calendarAlt,
      //           color: colors[2],
      //         ),
      //         title: Text("اضافة",
      //             style: TextStyle(
      //               fontFamily: 'monadi',
      //               color: colors[2],
      //             ))),
      //     BubbleBottomBarItem(
      //         backgroundColor: colors[3],
      //         // icon: Icon(
      //         //   Icons.sports,
      //         //   color: Colors.blue,
      //         // ),
      //         icon: FaIcon(
      //           FontAwesomeIcons.dumbbell,
      //           color: colors[4],
      //         ),
      //         // activeIcon: Icon(
      //         //   Icons.sports,
      //         //   color: Colors.blue,
      //         // ),
      //         activeIcon: FaIcon(
      //           FontAwesomeIcons.dumbbell,
      //           color: colors[4],
      //         ),
      //         title: Text("جسمك  ",
      //             style: TextStyle(
      //               fontFamily: 'monadi',
      //               color: colors[4],
      //             ))),
      //     BubbleBottomBarItem(
      //         backgroundColor: colors[7],
      //         icon: Icon(
      //           Icons.favorite,
      //           color: colors[7],
      //         ),
      //         activeIcon: Icon(
      //           Icons.favorite,
      //           color: colors[8],
      //         ),
      //         title: Text("المفضلة",
      //             style: TextStyle(
      //               fontFamily: 'monadi',
      //               color: colors[8],
      //             ))),
      //     BubbleBottomBarItem(
      //         backgroundColor: Colors.green,
      //         icon: Icon(
      //           Icons.dashboard,
      //           color: colors[5],
      //         ),
      //         activeIcon: Icon(
      //           Icons.dashboard,
      //           color: colors[6],
      //         ),
      //         title: Text(
      //           "الرئيسة",
      //           style: TextStyle(
      //             fontFamily: 'monadi',
      //             color: colors[6],
      //           ),
      //         ))
      //   ],
      // ),

      body: Stack(alignment: Alignment.bottomCenter, children: [
        selectedPage(),
        if (_anchoredBanner != null)
          Container(
            color: Colors.green,
            width: _anchoredBanner!.size.width.toDouble(),
            height: _anchoredBanner!.size.height.toDouble(),
            child: AdWidget(ad: _anchoredBanner!),
          ),
      ]),
      drawer: Drawer(
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    'تمتعي بأنوثتك سيدتي',
                    style: kMeduimeText,
                    textAlign: TextAlign.center,
                  ),
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: colors[8],
                    child: Image.asset('lib/assets/images/avatars/girl2.png'),
                  )
                ],
              ),
              decoration: BoxDecoration(
                color: colors[8].withOpacity(0.7),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
            ),
            ListTile(
              title: Text('حساب الوزن المثالي',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                  )),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => BmiCalculatorScreen()));
              },
            ),
            Divider(),
            ListTile(
              title: Text('المرجو ترك تقييم لنا',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                  )),
              onTap: () {
                _launchURL();
                // Update the state of the app.
                // ...
              },
            ),
            Divider(),
          ],
        ),
      ),
    );
  }
}
