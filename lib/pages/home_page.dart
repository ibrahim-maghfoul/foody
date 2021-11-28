import 'package:flutter/material.dart';
import 'package:foody/models/ad_helper.dart';
import 'package:foody/pages/favorite_page.dart';
import 'package:foody/providers/recipes_provider.dart';
import 'package:foody/widgets/recipe_listView.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:rate_my_app/rate_my_app.dart';
import 'package:url_launcher/url_launcher.dart';

class RecipesPage extends StatefulWidget {
  @override
  _RecipesPageState createState() => _RecipesPageState();
}

class _RecipesPageState extends State<RecipesPage>
    with TickerProviderStateMixin {
  RateMyApp _rateMyApp = RateMyApp(
    preferencesPrefix: 'rateMyApp_',
    minDays: 3,
    minLaunches: 7,
    remindDays: 2,
    remindLaunches: 4,
  );
  void _launchURL() async => await canLaunch(
          'https://play.google.com/store/apps/details?id=com.ariss.foody')
      ? await launch(
          'https://play.google.com/store/apps/details?id=com.ariss.foody')
      : throw "'Could not launch ' 'https://play.google.com/store/apps/details?id=com.ariss.foody'";
  void showRateDialogue() {
    _rateMyApp.showStarRateDialog(
      context,
      title: "Did you enjoy using our app",
      message:
          "Please consider rating us on the Play Store with 5 stars! (select the fifth star under below then press Confirm to go to the store!)",
      actionsBuilder: (_, stars) {
        return [
          TextButton(
            child: Text('Confirm'),
            onPressed: () async {
              print('Thanks for the ' +
                  (stars == null ? '0' : stars.round().toString()) +
                  ' star(s) !');
              if (stars != null && (stars == 4 || stars == 5)) {
                _launchURL();
              } else {}
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

  List<String> categories = [
    "Everyday",
    "Birthday",
    "Celebration",
    "Sunday lunch",
    "Picnic",
    "Low-fat",
    "Low GI",
    "Egg-free",
    "Gluten-free breakfasts",
    "Meat",
    "Fruit",
    "Vegetables",
    "Dairy",
    "Grains and pulses",
    "Banana recipes",
    "Chocolate",
    "Easy summer",
    "Summer drink",
    "Summer dessert",
    "Seasonal September",
    "Top 20 Autumn recipes",
    "Winter Roasts",
    "All-time top 20 recipes",
    "Cheap cut recipes",
    "Cheap eat recipes",
    "Courses",
    "Buffet",
    "Edible gift recipes",
    "Sharing recipes",
    "Food to get you in the mood",
    "Batch cooking",
    "Cheap eat",
    "Comfort food",
    "Five ingredients or less",
    "Freezable",
    "Leftovers",
    "Storecupboard",
    "One bowl meals",
    "Father's Day",
    "Jubilee",
    "Mother's Day",
    "Baking recipes",
    "Biscuit",
    "Bread",
    "Brownie Recipes",
    "Cake sale",
    "Caramel",
    "Celebration cake",
    "Cheesecake",
    "Chocolate baking",
    "Chocolate cake",
    "Cookies recipes",
    "Cupcake",
    "Easy baking",
    "Fruitcake",
    "Fruity cake",
    "Garden glut cake",
    "Halloween cake",
    "Low-fat cake",
    "Muffin",
    "Polenta cake",
    "Retro cake",
    "Summer cake",
    "Wedding cake",
    "Frozen desserts",
    "Christmas baking",
    "Christmas dinner",
    "Christmas cheeseboard",
    "Budget recipes",
    "Christmas biscuits",
    "Christmas brunch",
    "Christmas buffet",
    "Easy Christmas recipes",
    "Festive cake recipes",
    "Festive dessert recipes",
    "Festive main course recipes",
    "Festive starter recipes",
    "Gluten-free Christmas recipes",
    "Good Food magazine Christmas recipes",
    "Hangover recipes",
    "Christmas for kids recipes",
    "Last-minute Christmas recipes",
    "Leftover Christmas turkey recipes",
    "Low-calorie Christmas recipes",
    "Low-fat Christmas recipes",
    "Make-ahead Christmas recipes",
    "Mince pies recipes",
    "New Year's Eve recipes",
    "Nut-free Christmas recipes",
    "Quick nibbles recipes",
    "Turkey recipes",
    "Vegan Christmas recipes",
    "Vegetarian Christmas recipes",
    "Vegetarian Christmas canapé recipes",
    "Vegetarian Christmas starter recipes",
    "Decoration recipes",
    "Dairy-free Christmas recipes",
    "Christmas trimmings",
    "Trifle recipes",
    "Christmas sweets recipes",
    "Christmas stuffing recipes",
    "Christmas sprouts recipes",
    "Christmas soup recipes",
    "Christmas smoked salmon recipes",
    "Christmas side dish recipes",
    "Christmas sauces recipes",
    "Christmas roast potato recipes",
    "Christmas red cabbage recipes",
    "Christmas recovery recipes",
    "Christmas pudding",
    "Christmas parsnip recipes",
    "Christmas pate and terrine recipes",
    "Christmas leftovers recipes",
    "Christmas ham recipes",
    "Christmas gravy recipes",
    "Christmas gingerbread recipes",
    "Christmas gifts recipes",
    "Christmas cupcakes recipes",
    "Christmas cracker and biscuit recipes",
    "Christmas chutneys recipes",
    "Christmas chocolate recipes",
    "Christmas centrepiece recipes",
    "Christmas Cake recipes",
    "Festive drinks recipes",
    "Healthy Christmas recipes",
    "Healthy Christmas buffet recipes",
    "Healthy Christmas canapés recipes",
    "Healthy Christmas party recipes",
    "Healthy Christmas side dish recipes",
    "Healthy Christmas leftovers recipes"
  ];

  List<Tab> tabs() {
    return categories.map((e) {
      return Tab(
          child: Text(e,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)));
    }).toList();
  }

  TabController? tabController;

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

  @override
  void initState() {
    _rateMyApp.init().then((_) {
      if (_rateMyApp.shouldOpenDialog) {
        //conditions check if user already rated the app
        showRateDialogue();
      }
    });
    super.initState();
    tabController = TabController(
      initialIndex: 0,
      length: categories.length,
      vsync: this,
    );
    tabController?.addListener(() {
      RecipesProvider.chaged = true;
      print("value is : ${RecipesProvider.chaged}");
    });
  }

  @override
  void dispose() {
    _anchoredBanner?.dispose();

    super.dispose();
  }

  List<String> cat = [];
  String cate = '';
  @override
  Widget build(BuildContext context) {
    if (!_loadingAnchoredBanner) {
      _loadingAnchoredBanner = true;
      _createAnchoredBanner(context);
    }
    return ChangeNotifierProvider(
      create: (context) => RecipesProvider(),
      child: DefaultTabController(
        length: categories.length,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Scaffold(
              appBar: AppBar(
                backgroundColor: Colors.green[400],
                actions: [
                  IconButton(
                      onPressed: () {
                        showRateDialogue();
                      },
                      icon: Icon(Icons.star_border)),
                  IconButton(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => FavoritePage(),
                        ));
                      },
                      icon: Icon(Icons.favorite))
                ],
                title: Text(
                  'Foody',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                bottom: PreferredSize(
                  preferredSize: Size.fromHeight(30),
                  child: TabBar(
                    controller: tabController,
                    labelColor: Colors.white,
                    indicatorWeight: 4,
                    indicatorColor: Colors.orange,
                    isScrollable: true,
                    onTap: (i) {
                      print(i);
                      RecipesProvider.chaged = true;
                    },
                    tabs: tabs(),
                  ),
                ),
              ),
              body: Consumer<RecipesProvider>(
                builder: (context, recipesProvider, _) => TabBarView(
                    physics: BouncingScrollPhysics(),
                    controller: tabController,
                    children: categories
                        .map(
                          (category) => ListViewWidget(
                            recipesProvider: recipesProvider,
                            categorie: category,
                          ),
                        )
                        .toList()),
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
      ),
    );
  }
}
