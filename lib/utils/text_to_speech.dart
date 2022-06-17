import 'package:flutter_tts/flutter_tts.dart';

class TextToSpeechUtils {
  static final FlutterTts _flutterTts = FlutterTts()
    ..setSharedInstance(true)
    ..setIosAudioCategory(
      IosTextToSpeechAudioCategory.ambient,
      [
        IosTextToSpeechAudioCategoryOptions.allowBluetooth,
        IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
        IosTextToSpeechAudioCategoryOptions.mixWithOthers
      ],
      IosTextToSpeechAudioMode.voicePrompt,
    );

  static Future<void> setup() async {
    await _flutterTts.setLanguage("de-DE");
    await _flutterTts.setSpeechRate(0.7);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
  }

  static Future<void> speak(String text) async {
    await _flutterTts.speak(text);
  }

  static Future<void> stop() async {
    await _flutterTts.stop();
  }
}
