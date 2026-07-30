import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';

class VoiceService {
  VoiceService() {
    _tts.setLanguage('id-ID');
    _tts.setSpeechRate(0.45);
    _tts.setPitch(1.1);
  }

  final FlutterTts _tts = FlutterTts();

  Future<void> speak(String text) => _tts.speak(text);

  Future<void> stop() => _tts.stop();
}

final voiceServiceProvider = Provider<VoiceService>((ref) => VoiceService());
