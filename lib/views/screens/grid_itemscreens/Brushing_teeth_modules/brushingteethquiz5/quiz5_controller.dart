import 'package:autism_fyp/views/screens/grid_itemscreens/Brushing_teeth_modules/brushing_teeth_module_controller.dart';
import 'package:get/get.dart';
import 'package:autism_fyp/views/controllers/global_audio_services.dart';

class Quiz5Controller extends GetxController {
  var selectedTemplate = 0.obs; 
  var userAnswerCorrect = false.obs;
  var userAnswered = false.obs;
  var retries = 0.obs;
  var wrongAnswersCount = 0.obs;
  var score = 0.obs;
  var showCompletion = false.obs;

  // Store user's selected answers (index per template)
  var userAnswers = <int?>[].obs; 

  final audioService = AudioInstructionService.to;
  final brushingTeethController = Get.find<BrushingTeethModuleController>();

  RxString get instructionText => audioService.instructionText;
  RxBool get isSpeaking => audioService.isSpeaking;

  final templates = [
    'lib/assets/quiz5_icon/icon1.png',
    'lib/assets/quiz5_icon/icon2.png',
    'lib/assets/quiz5_icon/icon3.png',
  ];

  final templateOptions = [
    [
      'lib/assets/quiz5_icon/opt3_icon1.png', // correct one
      'lib/assets/quiz5_icon/opt1_icon1.png',
      'lib/assets/quiz5_icon/opt2_icon1.png',
    ],
    [
      'lib/assets/quiz5_icon/opt1_icon2.png',
      'lib/assets/quiz5_icon/opt3_icon2.png', // correct one
      'lib/assets/quiz5_icon/opt2_icon2.png',
    ],
    [
      'lib/assets/quiz5_icon/opt1_icon3.png',
      'lib/assets/quiz5_icon/opt2_icon3.png',
      'lib/assets/quiz5_icon/opt3_icon3.png', // correct one
    ],
  ];

  final correctAnswers = [0, 1, 2];
  
  final templateInstructions = [
    "brushing_teeth_audios/quiz5_template1.mp3",
    "brushing_teeth_audios/quiz5_template2.mp3",
    "brushing_teeth_audios/quiz5_template3.mp3",
  ];

  @override
  void onInit() {
    super.onInit();
    // Initialize with nulls for all templates
    userAnswers.value = List.filled(templates.length, null);
    
    Future.delayed(Duration.zero, () {
      audioService.setInstructionAndSpeak(
        "Now Lets Match the correct items! Look carefully and choose the right option.",
        "goingbed_audios/quiz5_matching_intro.mp3",
      );
      _speakCurrentTemplateInstruction();
    });
  }

  void selectOption(int index) {
    if (userAnswered.value) return;
    
    userAnswered.value = true;
    final isCorrect = index == correctAnswers[selectedTemplate.value];
    userAnswerCorrect.value = isCorrect;

    // Save user's selected answer
    userAnswers[selectedTemplate.value] = index;

    if (isCorrect) {
      score.value++;
      audioService.playCorrectFeedback();
      audioService.setInstructionAndSpeak(
        "Correct! Great job matching!",
        "brushing_teeth_audios/quiz5_correct.mp3",
      );
    } else {
      wrongAnswersCount.value++;
      audioService.playIncorrectFeedback();
      
      // Record wrong answer
      brushingTeethController.recordWrongAnswer(
        quizId: "quiz5",
        questionId: "Template ${selectedTemplate.value + 1}",
        wrongAnswer: "Selected option ${index + 1}",
        correctAnswer: "Option ${correctAnswers[selectedTemplate.value] + 1}",
      );
      
      audioService.setInstructionAndSpeak(
        "That's not quite right. Try again!",
        "brushing_teeth_audios/quiz5_incorrect.mp3",
      );
    }

    Future.delayed(const Duration(seconds: 2), () {
      if (selectedTemplate.value < templates.length - 1) {
        selectedTemplate.value++;
        userAnswered.value = false;
        _speakCurrentTemplateInstruction();
      } else {
        completeQuiz();
      }
    });
  }

  void _speakCurrentTemplateInstruction() {
    if (selectedTemplate.value < templateInstructions.length) {
      audioService.setInstructionAndSpeak(
        "Select the matching item for pattern ${selectedTemplate.value + 1}",
        templateInstructions[selectedTemplate.value],
      );
    }
  }

  void completeQuiz() {
    showCompletion.value = true;
    final totalCorrect = getTotalCorrectAnswers();
    final isPassed = totalCorrect >= templates.length * 0.7;

    // Record quiz result
    brushingTeethController.recordQuizResult(
      quizId: "quiz5",
      score: totalCorrect,
      retries: retries.value,
      isCompleted: isPassed,
      wrongAnswersCount: wrongAnswersCount.value,
    );
    
    // Sync with Firestore
    brushingTeethController.syncModuleProgress();

    if (totalCorrect == templates.length) {
      audioService.setInstructionAndSpeak(
        "Perfect! You matched all ${templates.length} patterns correctly!",
        "brushing_teeth_audios/quiz5_perfect.mp3",
      );
    } else if (isPassed) {
      audioService.setInstructionAndSpeak(
        "Good job! You got $totalCorrect out of ${templates.length} correct.",
        "brushing_teeth_audios/quiz5_good.mp3",
      );
    } else {
      audioService.setInstructionAndSpeak(
        "You got $totalCorrect out of ${templates.length}. Let's practice more!",
        "brushing_teeth_audios/quiz5_practice.mp3",
      );
    }
  }

  void retryQuiz() {
    retries.value++;
    selectedTemplate.value = 0;
    userAnswered.value = false;
    userAnswers.value = List.filled(templates.length, null);
    score.value = 0;
    wrongAnswersCount.value = 0;
    showCompletion.value = false;
    
    audioService.setInstructionAndSpeak(
      "Let's try matching the patterns. Find the perfect match.",
      "brushing_teeth_audios/quiz5_retry.mp3",
    );
    _speakCurrentTemplateInstruction();
  }

  void nextTemplate() {
    if (selectedTemplate.value < templates.length - 1) {
      selectedTemplate.value++;
      userAnswered.value = false;
      _speakCurrentTemplateInstruction();
    }
  }

  void previousTemplate() {
    if (selectedTemplate.value > 0) {
      selectedTemplate.value--;
      userAnswered.value = false;
      _speakCurrentTemplateInstruction();
    }
  }

  // Method to get total correct answers based on user input
  int getTotalCorrectAnswers() {
    int count = 0;
    for (int i = 0; i < correctAnswers.length; i++) {
      if (userAnswers[i] == correctAnswers[i]) {
        count++;
      }
    }
    return count;
  }

  // Get completion percentage
  double getCompletionPercentage() {
    return selectedTemplate.value / templates.length;
  }

  // Check if current template is answered
  bool isTemplateAnswered(int templateIndex) {
    return userAnswers[templateIndex] != null;
  }

  // Get feedback for specific template
  bool isTemplateCorrect(int templateIndex) {
    return userAnswers[templateIndex] == correctAnswers[templateIndex];
  }

  @override
  void onClose() {
    audioService.stopSpeaking();
    super.onClose();
  }
}