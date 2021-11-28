import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:foody/models/favorite_model.dart';
import 'package:foody/pages/home_page.dart';
import 'package:foody/providers/recipes_provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  await Firebase.initializeApp();
  await Hive.initFlutter();
  Hive.registerAdapter(FavoriteRecipeAdapter());
  await Hive.openBox('favorite');
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<FavoriteModel>(
          create: (_) => FavoriteModel(),
        ),
        ChangeNotifierProvider<RecipesProvider>(
          create: (_) => RecipesProvider(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Foody",
      color: Colors.green[300],
      home: RecipesPage(),
      theme: ThemeData(fontFamily: 'Rubik'),
    );
  }
}
