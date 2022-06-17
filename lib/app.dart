import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mhd_accessibility/utils/text_to_speech.dart';
import 'package:mhd_accessibility/views/picture/picture.dart';
import 'package:mhd_accessibility/views/scan/scan.dart';

final routerDelegate = BeamerDelegate(
  locationBuilder: RoutesLocationBuilder(
    routes: {
      // Return either Widgets or BeamPages if more customization is needed
      '/': (context, state, data) => const ScanView(),
      '/picture': (context, state, data) => const PictureView(),
    },
  ),
);

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void initState() {
    super.initState();

    /// Setup the default text to speech environment
    TextToSpeechUtils.setup();

    /// Set portait only mode
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routeInformationParser: BeamerParser(),
      routerDelegate: routerDelegate,
      title: 'MHD Scanner',
    );
  }
}
