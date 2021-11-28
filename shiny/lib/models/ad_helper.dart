import 'package:google_mobile_ads/google_mobile_ads.dart';

class ShowAds {
  static String bannerId = BannerAd.testAdUnitId;
  static String interstialId = InterstitialAd.testAdUnitId;
  static String rewarded = RewardedAd.testAdUnitId;

  // static String bannerId = 'ca-app-pub-9094069776493275/9658796460';
  // static String interstialId = 'ca-app-pub-9094069776493275/1140822820';
  // static String rewardedId = "ca-app-pub-9094069776493275/8827741153";
}

/*
def keystoreProperties = new Properties()
   def keystorePropertiesFile = rootProject.file('key.properties')
   if (keystorePropertiesFile.exists()) {
       keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
   }

}
*/