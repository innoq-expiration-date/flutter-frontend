import 'dart:io';

import 'package:camera/camera.dart';
import 'package:dio/dio.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:riverpod/riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../utils/haptic.dart';

class CameraStore {
  static var cameraProvider = StateNotifierProvider<CameraNotifier,
      AsyncValue<List<CameraDescription>>?>((ref) => CameraNotifier());

  static var pictureProvider =
      StateNotifierProvider<PictureNotifier, AsyncValue<PictureResult>?>(
          (ref) => PictureNotifier());
}

class CameraNotifier
    extends StateNotifier<AsyncValue<List<CameraDescription>>?> {
  CameraNotifier() : super(null);

  void initializeCameras() async {
    this.state = const AsyncValue.loading();
    this.state = await AsyncValue.guard(() async {
      return await availableCameras();
    });
  }
}

class PictureNotifier extends StateNotifier<AsyncValue<PictureResult>?> {
  PictureNotifier() : super(null);

  void takePicture(CameraController controller,
      [bool onDeviceRecognition = false, Duration? duration]) async {
    /// Initate a standard haptic to indicate we took a picture
    /// and wait a small time to start the image processing
    HapticUtils.normalHaptic(4);

    this.state = const AsyncValue.loading();
    this.state = await AsyncValue.guard(() async {
      XFile file = (await Future.wait([
        controller.takePicture(),
        Future.delayed(duration ?? const Duration(seconds: 1)),
      ]))[0];

      if (onDeviceRecognition) {
        String tempFilePath =
            '${(await getTemporaryDirectory()).path}/test.png';

        await file.saveTo(tempFilePath);

        final inputImage = InputImage.fromFilePath(tempFilePath);

        final textRecognizer =
            TextRecognizer(script: TextRecognitionScript.latin);

        final RecognizedText recognizedText =
            await textRecognizer.processImage(inputImage);

        /// Approaches how to work with [RecognizedText] - can
        /// can be used later
        ///
        // String text = recognizedText.text;
        // for (TextBlock block in recognizedText.blocks) {
        //   final Rect rect = block.boundingBox;
        //   final List<Point<int>> cornerPoints = block.cornerPoints;
        //   final String text = block.text;
        //   final List<String> languages = block.recognizedLanguages;

        //   for (TextLine line in block.lines) {
        //     // Same getters as TextBlock
        //     for (TextElement element in line.elements) {
        //       // Same getters as TextBlock
        //     }
        //   }
        // }

        await Future.delayed(const Duration(seconds: 5));
        return PictureResult(file, recognizedText);
      } else {
        String tempFilePath =
            '${(await getTemporaryDirectory()).path}/scan.png';

        await file.saveTo(tempFilePath);

        var formData = FormData.fromMap({
          'image':
              await MultipartFile.fromFile(tempFilePath, filename: 'scan.png'),
        });

        Response response = await Dio().post(
          'http://web-frontend-innoq-expiration-date.apps.cloudscale-lpg-2.appuio.cloud/pic/',
          data: formData,
        );

        return PictureResult(file, null, response.data);
      }
    });
  }
}

class PictureResult {
  final XFile file;
  final RecognizedText? recognizedText;
  final dynamic response;

  PictureResult(this.file, [this.recognizedText, this.response]);
}
