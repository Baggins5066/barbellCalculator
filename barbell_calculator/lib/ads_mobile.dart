import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class BannerAdWidget extends StatelessWidget {
  final BannerAd bannerAd;

  BannerAdWidget({Key? key})
    : bannerAd = BannerAd(
        adUnitId: 'ca-app-pub-7664311233392669/6589593490',
        size: AdSize.banner,
        request: AdRequest(),
        listener: BannerAdListener(),
      )..load(),
      super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      width: bannerAd.size.width.toDouble(),
      height: bannerAd.size.height.toDouble(),
      child: AdWidget(ad: bannerAd),
    );
  }
}
