import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mhd_accessibility/app.dart';
import 'package:mhd_accessibility/utils/text_to_speech.dart';

void main() {
  runApp(
    const ProviderScope(
      child: App(),
    ),
  );
}
