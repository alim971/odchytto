import 'dart:io';

import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdState {
  AdState(this.initialization);
  static const bool SHOULD_SHOW_ADS = true;
  Future<InitializationStatus> initialization;
  String get bannerId => Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/6300978111'
      : 'ca-app-pub-3940256099942544/2934735716';

  // BannerAdListener get adListener => _adListener;
}
