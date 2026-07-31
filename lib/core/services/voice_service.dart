import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';

class VoiceService {
  VoiceService() {
    _tts.setLanguage('id-ID');
    _tts.setSpeechRate(0.45);
    // ponytail: no real "child" voice exists in system TTS engines, so a
    // higher pitch is the closest free approximation. Upgrade path: a cloud
    // TTS provider (Google/Azure/ElevenLabs) with an actual child voice preset.
    _tts.setPitch(1.35);
    _pickBestVoice();
  }

  final FlutterTts _tts = FlutterTts();

  /// Swaps in the best-quality Indonesian voice installed on the device, if
  /// one exists. Android's Google TTS ships higher-fidelity "network" voices
  /// alongside the default robotic one; iOS/others just keep the default.
  Future<void> _pickBestVoice() async {
    final voices = await _tts.getVoices;
    if (voices is! List) return;

    final idVoices = voices
        .whereType<Map>()
        .where((v) => (v['locale'] as String?)?.toLowerCase().startsWith('id') ?? false)
        .toList();

    final best = idVoices.firstWhere(
      (v) => (v['name'] as String? ?? '').toLowerCase().contains('network'),
      orElse: () => const {},
    );
    if (best.isEmpty) return;

    await _tts.setVoice({
      'name': best['name'] as String,
      'locale': best['locale'] as String,
    });
  }

  Future<void> speak(String text) => _tts.speak(text);

  Future<void> stop() => _tts.stop();
}

final voiceServiceProvider = Provider<VoiceService>((ref) => VoiceService());
