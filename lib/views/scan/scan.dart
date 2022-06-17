import 'dart:async';

import 'package:beamer/beamer.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mhd_accessibility/stores/camera.dart';
import 'package:mhd_accessibility/views/scan/widgets/camera_wrapper.dart';

class ScanView extends ConsumerStatefulWidget {
  const ScanView({Key? key}) : super(key: key);

  @override
  ConsumerState<ScanView> createState() => _ScanViewState();
}

class _ScanViewState extends ConsumerState<ScanView> {
  CameraController? _controller;

  Future<List<CameraDescription>>? _cameras;

  @override
  void initState() {
    super.initState();

    ref.read(CameraStore.cameraProvider.notifier).initializeCameras();
  }

  void _initialiseCameraController(List<CameraDescription> cameras) {
    _controller = CameraController(
      cameras[0],
      ResolutionPreset.max,
      enableAudio: false,
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cameraNotifier = ref.watch(CameraStore.cameraProvider);

    ref.listen<AsyncValue<PictureResult>?>(CameraStore.pictureProvider,
        (AsyncValue<PictureResult>? previousPicture,
            AsyncValue<PictureResult>? newPicture) {
      if (newPicture != null) {
        Beamer.of(context).beamToNamed('/picture');
      }
    });

    return Material(
      color: Colors.black,
      child: cameraNotifier?.map(
            data: (camera) {
              _initialiseCameraController(camera.value);

              return CameraWrapper(controller: _controller!);
            },
            error: (error) => Center(
              child: Text(error.error.toString()),
            ),
            loading: (loading) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  CircularProgressIndicator(),
                  SizedBox(height: 12.0),
                  Text('Loading Cameras...')
                ],
              ),
            ),
          ) ??
          Container(),
    );
  }
}
