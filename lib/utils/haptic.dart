import 'dart:async';

import 'package:flutter/services.dart';

class HapticUtils {
  static Timer? _periodicHaptic;

  static void startPeriodicHaptic([Duration? duration]) {
    _periodicHaptic = Timer.periodic(
      duration ?? const Duration(milliseconds: 500),
      (timer) => HapticFeedback.mediumImpact(),
    );
  }

  static void stopPeriodicHaptic() {
    _periodicHaptic?.cancel();
  }

  static void normalHaptic([int? iterations, Duration? duration]) {
    if (iterations != null) {
      Timer.periodic(
        duration ?? const Duration(milliseconds: 50),
        (timer) {
          HapticFeedback.vibrate();
          if (timer.tick >= iterations) {
            timer.cancel();
          }
        },
      );
    } else {
      HapticFeedback.vibrate();
    }
  }
}
