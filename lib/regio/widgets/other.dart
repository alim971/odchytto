import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:watcher/common/ads/AdState.dart';
import 'package:watcher/common/ads/widgets.dart';
import 'package:watcher/common/data/localization.dart';
import 'package:watcher/common/widgets/widgets.dart';
import 'package:watcher/regio/theme.dart';

class ContainerWithIcon extends StatelessWidget {
  const ContainerWithIcon({required this.banner, Key? key}) : super(key: key);

  final BannerAd banner;

  @override
  Widget build(BuildContext context) {
    final BannerAd ad;
    // if (banner == null) {
    //   final adState = Provider.of<AdState>(context);
    //   ad = BannerAd(
    //     adUnitId: adState.bannerId, //search ad
    //     size: AdSize.banner,
    //     request: AdRequest(),
    //     listener: BannerAdListener(),
    //   )..load();
    // } else {
    ad = banner;
    // }
    return Column(
      children: [
        Expanded(
          child: Container(
              color: brightRegioYellow,
              child: const Center(
                  child: Opacity(
                opacity: 0.2,
                child: Icon(
                  Icons.directions_subway,
                  size: 200,
                ),
              ))),
        ),
        if (AdState.SHOULD_SHOW_ADS) AdOrSpaceWidget(banner: ad),
      ],
    );
  }
}

class ContainerWithIconNoRoutes extends StatelessWidget {
  const ContainerWithIconNoRoutes({required this.banner, Key? key})
      : super(key: key);

  final BannerAd banner;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Container(
              color: brightRegioYellow,
              child: Center(
                  child: Column(
                children: [
                  PlaceName(AppLocalizations.of(context).noRoutesFound),
                  const Opacity(
                    opacity: 0.2,
                    child: Icon(
                      Icons.directions_subway,
                      size: 200,
                    ),
                  ),
                ],
              ))),
        ),
        if (AdState.SHOULD_SHOW_ADS) AdOrSpaceWidget(banner: banner),
      ],
    );
  }
}
