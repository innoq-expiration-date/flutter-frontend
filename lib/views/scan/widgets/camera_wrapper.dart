import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mhd_accessibility/stores/camera.dart';
import 'package:mhd_accessibility/utils/haptic.dart';

class CameraWrapper extends ConsumerWidget {
  final CameraController controller;

  const CameraWrapper({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<void>(
      future: this.controller.initialize(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (!snapshot.hasError) {
            return Stack(
              alignment: Alignment.center,
              children: [
                CameraPreview(this.controller),
                SizedBox.expand(
                  child: GestureDetector(
                    onTap: () => ref
                        .read(CameraStore.pictureProvider.notifier)
                        .takePicture(controller),
                  ),
                ),
              ],
            );
          }
          return Center(
            child: Text(snapshot.error?.toString() ?? 'error'),
          );
        }
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              CircularProgressIndicator(),
              SizedBox(height: 12.0),
              Text('Initialize Controller...'),
            ],
          ),
        );
      },
    );
  }
}
