import 'package:get/get.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioInstructionService extends GetxService {
  final AudioPlayer audioPlayer = AudioPlayer();
  final RxString instructionText = ''.obs;
  final RxBool isSpeaking = false.obs;

  final String correctAudioPath = "goingbed_audios/correct.mp3";
  final String incorrectAudioPath = "goingbed_audios/incorrect.mp3";

  static AudioInstructionService get to => Get.find();

  @override
  void onClose() {
    audioPlayer.dispose();
    super.onClose();
  }

  /// 🔊 Instructional audio with synced text
  Future<void> setInstructionAndSpeak(String text, String localAudioPath) async {
    if (isSpeaking.value) {
      await stopSpeaking();
    }

    // Defer UI update to avoid build-phase exceptions
    Future.delayed(Duration.zero, () {
      instructionText.value = "";
    });

    isSpeaking.value = true;
    List<String> words = text.split(' ');

    try {
      await audioPlayer.play(AssetSource(localAudioPath));
    } catch (e) {
      print("Error playing audio: $e");
      isSpeaking.value = false;
      return;
    }

    for (String word in words) {
      instructionText.value += "$word ";
      await Future.delayed(const Duration(milliseconds: 400));
    }

    isSpeaking.value = false;
  }


Future<void> playAudioFromPath(String fileName) async {
  try {
    await audioPlayer.stop();
    await audioPlayer.play(AssetSource("goingbed_audios/$fileName.mp3"));
  } catch (e) {
    print("Audio playback error: $e");
  }
}
  /// 🛑 Stop audio and clear text
  Future<void> stopSpeaking() async {
    await audioPlayer.stop();
    isSpeaking.value = false;
    instructionText.value = "";
  }

  /// ⏸ Pause audio
  Future<void> pauseSpeaking() async {
    await audioPlayer.pause();
    isSpeaking.value = false;
  }

  /// ▶️ Resume audio
  Future<void> resumeSpeaking() async {
    await audioPlayer.resume();
    isSpeaking.value = true;
  }

  /// 📦 Preload audio asset
  Future<void> preloadAudio(String localAudioPath) async {
    await audioPlayer.setSource(AssetSource(localAudioPath));
  }

  /// ✅ Correct feedback (audio only)
  Future<void> playCorrectFeedback() async {
    await playAudioOnly(correctAudioPath);
  }

  /// ❌ Incorrect feedback (audio only)
  Future<void> playIncorrectFeedback() async {
    await playAudioOnly(incorrectAudioPath);
  }

  /// 🔊 Play audio without affecting UI
  Future<void> playAudioOnly(String localAudioPath) async {
    try {
      await audioPlayer.stop();
      await audioPlayer.play(AssetSource(localAudioPath));
    } catch (e) {
      print("Error playing feedback audio: $e");
    }
  }
}