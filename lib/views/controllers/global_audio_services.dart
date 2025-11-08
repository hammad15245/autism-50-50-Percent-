import 'dart:convert';
import 'dart:io';
import 'package:autism_fyp/config.dart';
import 'package:get/get.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class AudioInstructionService extends GetxService {
  final AudioPlayer audioPlayer = AudioPlayer();
  final RxString instructionText = ''.obs;
  final RxBool isSpeaking = false.obs;

  static AudioInstructionService get to => Get.find();

  @override
  void onClose() {
    audioPlayer.dispose();
    super.onClose();
  }

  /// ✅ NEW: Play local audio file (assets) without TTS
  Future<void> playLocalAudio(String assetPath) async {
    try {
      await stopSpeaking(); // Stop TTS if running
      instructionText.value = ""; // No text for asset audio
      isSpeaking.value = false;

      // Remove "assets/" for AssetSource()
      final sourcePath = assetPath.replaceFirst("assets/", "");

      await audioPlayer.play(AssetSource(sourcePath));
    } catch (e) {
      print("Local audio error: $e");
    }
  }

  /// 🔊 Speak instruction with word-by-word UI updates
  Future<void> setInstructionAndSpeak(String text, {bool useAI = true}) async {
    if (isSpeaking.value) await stopSpeaking();

    instructionText.value = "";
    isSpeaking.value = true;

    try {
      if (useAI) {
        await speakText(text);
      } else {
        await audioPlayer.play(AssetSource("goingbed_audios/fallback.mp3"));
      }
    } catch (e) {
      print("Error generating/playing instruction audio: $e");
      isSpeaking.value = false;
      return;
    }

    for (String word in text.split(' ')) {
      instructionText.value += "$word ";
      await Future.delayed(const Duration(milliseconds: 400));
    }

    isSpeaking.value = false;
  }

  Future<void> speakText(String text) async {
    await stopSpeaking();
    isSpeaking.value = true;

    try {
      await _playElevenLabsSpeech(text);
    } catch (e) {
      print("Error in speakText: $e");
    }

    isSpeaking.value = false;
  }

  Future<void> playCorrectFeedback({String message = "Good job! That's correct."}) async {
    await speakText(message);
  }

  Future<void> playIncorrectFeedback({String message = "Oops! Try again."}) async {
    await speakText(message);
  }

  /// 🟡 ElevenLabs TTS API integration
  Future<void> _playElevenLabsSpeech(String text) async {
    final url = Uri.parse(
      "https://api.elevenlabs.io/v1/text-to-speech/${AppConfig.elevenLabsVoiceId}",
    );

    final response = await http.post(
      url,
      headers: {
        "xi-api-key": AppConfig.elevenLabsApiKey,
        "Content-Type": "application/json",
        "Accept": "audio/mpeg",
      },
      body: jsonEncode({
        "text": text,
        "voice_settings": {
          "stability": 0.6,
          "similarity_boost": 0.8
        }
      }),
    );

    if (response.statusCode == 200) {
      final bytes = response.bodyBytes;
      final dir = await getTemporaryDirectory();
      final file = File("${dir.path}/tts_output.mp3");
      await file.writeAsBytes(bytes);
      await audioPlayer.play(DeviceFileSource(file.path));
    } else {
      throw Exception("ElevenLabs TTS failed: ${response.body}");
    }
  }

  Future<void> stopSpeaking() async {
    await audioPlayer.stop();
    instructionText.value = "";
    isSpeaking.value = false;
  }

  Future<void> pauseSpeaking() async {
    await audioPlayer.pause();
    isSpeaking.value = false;
  }

  Future<void> resumeSpeaking() async {
    await audioPlayer.resume();
    isSpeaking.value = true;
  }
}
