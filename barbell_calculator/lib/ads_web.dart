import 'package:flutter/widgets.dart';
import 'dart:ui' as ui;
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

class BannerAdWidget extends StatelessWidget {
  BannerAdWidget({Key? key}) : super(key: key);
  static bool _registered = false;

  @override
  Widget build(BuildContext context) {
    if (!_registered) {
      // ignore: undefined_prefixed_name
      ui.platformViewRegistry.registerViewFactory(
        'adSense-html',
        (int viewId) => html.IFrameElement()
          ..width = '320'
          ..height = '100'
          ..srcdoc = '''
            <html>
              <head>
                <style>body { margin: 0; padding: 0; }</style>
              </head>
              <body>
                <ins class="adsbygoogle"
                  style="display:inline-block;width:320px;height:100px"
                  data-ad-client="ca-pub-XXXXXXXXXXXXXXXX"
                  data-ad-slot="YYYYYYYYYY"></ins>
                <script>
                  (adsbygoogle = window.adsbygoogle || []).push({});
                </script>
                <script async src="https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js"></script>
              </body>
            </html>
          '''
          ..style.border = 'none',
      );
      _registered = true;
    }
    return SizedBox(
      width: 320,
      height: 100,
      child: const HtmlElementView(viewType: 'adSense-html'),
    );
  }
}
