import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdOrSpaceWidget extends StatelessWidget {
  const AdOrSpaceWidget({this.banner, Key? key}) : super(key: key);
  final BannerAd? banner;
  @override
  Widget build(BuildContext context) {
    if (banner == null) {
      return const SizedBox(height: 50);
    } else {
      return SizedBox(height: 50, child: AdWidget(ad: banner!));
    }
  }
}
