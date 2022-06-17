import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mhd_accessibility/stores/camera.dart';
import 'package:mhd_accessibility/utils/haptic.dart';
import 'package:mhd_accessibility/utils/text_to_speech.dart';

class PictureView extends ConsumerStatefulWidget {
  const PictureView({Key? key}) : super(key: key);

  @override
  PictureViewState createState() => PictureViewState();
}

class PictureViewState extends ConsumerState<PictureView> {
  bool _handled = false;

  @override
  Widget build(BuildContext context) {
    final pictureNotifier = ref.watch(CameraStore.pictureProvider);

    return Material(
      child: pictureNotifier?.map(
            data: (picture) => FutureBuilder<Uint8List>(
                future: picture.value.file.readAsBytes(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    String date;

                    try {
                      date = picture.value.recognizedText?.text ??
                          picture.value.response?['extractedDates']
                              ?.first?['date'] ??
                          'Es wurde kein Datum gefunden';
                    } catch (e) {
                      date = 'Es wurde kein Datum gefunden';
                    }

                    if (!_handled) {
                      /// Stop haptic since connection state is done,
                      /// meaning our request is done, no matter if success
                      /// or failure
                      HapticUtils.stopPeriodicHaptic();

                      // TextToSpeechUtils.speak('12.12.2024');

                      TextToSpeechUtils.speak(date);
                      _handled = true;
                    }

                    if (!snapshot.hasError) {
                      return Listener(
                        onPointerMove: (event) {
                          if (event.delta.dy < -5.0) {
                            HapticUtils.normalHaptic(4);
                            Beamer.of(context).beamToNamed('/');
                          }
                        },
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Image.memory(snapshot.data!),
                            Positioned(
                              top: 48.0,
                              width:
                                  min(300, MediaQuery.of(context).size.width),
                              height: 150,
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4.0),
                                  side: const BorderSide(
                                    color: Colors.black,
                                  ),
                                ),
                                child: SingleChildScrollView(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      date,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return const Center(
                      child: Text('Error processing image!'),
                    );
                  }
                  return Column(
                    children: const [
                      CircularProgressIndicator(),
                      SizedBox(height: 12.0),
                      Text('Processing Image...'),
                    ],
                  );
                }),
            error: (error) {
              HapticUtils.stopPeriodicHaptic();
              HapticUtils.normalHaptic(8);
              return Listener(
                onPointerMove: (event) {
                  if (event.delta.dy < -5.0) {
                    HapticUtils.normalHaptic();
                    Beamer.of(context).beamToNamed('/');
                  }
                },
                child: SizedBox.expand(
                  child: Center(
                    child: Text(error.error.toString()),
                  ),
                ),
              );
            },
            loading: (loading) {
              /// We are in a loading scenario, therefore periodically
              /// giving haptic feedback to indicate this state
              HapticUtils.startPeriodicHaptic();
              return const Center(
                child: CircularProgressIndicator(),
              );
            },
          ) ??
          Container(),
    );
  }
}
