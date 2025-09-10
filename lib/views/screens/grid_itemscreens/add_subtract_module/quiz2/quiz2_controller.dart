import 'package:get/get.dart';
import 'package:autism_fyp/views/controllers/global_audio_services.dart';
import 'package:autism_fyp/views/screens/grid_itemscreens/add_subtract_module/add_subtract_module_controller.dart';

class NumberLineController extends GetxController {
  final audioService = AudioInstructionService.to;
  final addSubtractModuleController = Get.find<AddSubtractModuleController>();
  
  RxString get instructionText => audioService.instructionText;
  RxBool get isSpeaking => audioService.isSpeaking;

  var currentQuestionIndex = 0.obs;
  var frogPosition = 0.obs;
  var targetAnswer = 0.obs;
  var showFeedback = false.obs;
  var isCorrect = false.obs;
  var score = 0.obs;
  var totalQuestions = 0.obs;
  var currentOperation = "+".obs;
  var operationValue = 0.obs;

  // Progress tracking
  var retries = 0.obs;
  var wrongAttempts = 0.obs;
  var hasSubmitted = false.obs;
  var showCompletion = false.obs;

  final List<Map<String, dynamic>> questions = [
    {
      "problem": "5 + 3",
      "instruction": "Help Frog jump 3 spaces forward from 4!",
      "audio": "numberline_question1",
      "startPosition": 5,
      "operation": "+",
      "value": 3,
      "answer": 8
    },
    {
      "problem": "8 - 4", 
      "instruction": "Help Frog jump 4 spaces backward from 8!",
      "audio": "numberline_question2",
      "startPosition": 8,
      "operation": "-",
      "value": 2,
      "answer": 4
    },
    {
      "problem": "5 + 1",
      "instruction": "Help Frog jump 1 space forward from 5!",
      "audio": "numberline_question3",
      "startPosition": 5,
      "operation": "+",
      "value": 1,  
      "answer": 6   
    },
    {
      "problem": "9 - 3",
      "instruction": "Help Frog jump 3 spaces backward from 9!",
      "audio": "numberline_question4",
      "startPosition": 9,
      "operation": "-",
      "value": 3,
      "answer": 6
    },
    {
      "problem": "3 + 4",
      "instruction": "Help Frog jump 4 spaces forward from 3!",
      "audio": "numberline_question5",
      "startPosition": 3,
      "operation": "+",
      "value": 4,
      "answer": 7
    }
  ];

  @override
  void onInit() {
    super.onInit();
    audioService.setInstructionAndSpeak(
      "kidos! Lets start Number Line Journey! Drag Frog to solve math problems.",
      "goingbed_audios/numberline_intro.mp3",
    ).then((_) {
      Future.delayed(const Duration(seconds: 2), () {
        loadCurrentQuestion();
      });
    });
  }

  void loadCurrentQuestion() {
    showFeedback.value = false;
    isCorrect.value = false;
    final currentQuestion = questions[currentQuestionIndex.value];
    
    frogPosition.value = currentQuestion["startPosition"];
    targetAnswer.value = currentQuestion["answer"];
    currentOperation.value = currentQuestion["operation"];
    operationValue.value = currentQuestion["value"];
    
    totalQuestions.value++;
    
    audioService.playAudioFromPath(currentQuestion["audio"]);
  }

  void resetCurrentQuestion() {
    frogPosition.value = questions[currentQuestionIndex.value]["startPosition"];
    showFeedback.value = false;
    isCorrect.value = false;
  }

  void moveFrog(int steps) {
    if (hasSubmitted.value) return;
    
    final newPosition = frogPosition.value + steps;
    if (newPosition >= 0 && newPosition <= 10) {
      frogPosition.value = newPosition;
    }
  }

  void jumpForward() {
    if (hasSubmitted.value) return;
    
    if (frogPosition.value + operationValue.value <= 10) {
      frogPosition.value += operationValue.value;
    }
  }

  void jumpBackward() {
    if (hasSubmitted.value) return;
    
    if (frogPosition.value - operationValue.value >= 0) {
      frogPosition.value -= operationValue.value;
    }
  }

  void checkAnswer() {
    if (hasSubmitted.value) return;
    
    isCorrect.value = frogPosition.value == targetAnswer.value;
    showFeedback.value = true;

    if (isCorrect.value) {
      score.value++;
      audioService.playCorrectFeedback();
      
      // Record successful question completion
      if (isLastQuestion) {
        completeQuiz();
      }
    } else {
      wrongAttempts.value++;
      audioService.playIncorrectFeedback();
      
      // Record wrong attempt
      addSubtractModuleController.recordWrongAnswer(
        quizId: "quiz2",
        questionId: "Question ${currentQuestionIndex.value + 1}",
        wrongAnswer: "Frog at ${frogPosition.value}, should be at ${targetAnswer.value}",
        correctAnswer: "Correct answer: ${currentQuestion['problem']} = ${targetAnswer.value}",
      );
    }
  }

  void nextQuestion() {
    if (currentQuestionIndex.value < questions.length - 1) {
      currentQuestionIndex.value++;
      loadCurrentQuestion();
    } else {
      completeQuiz();
    }
  }

  void completeQuiz() {
    showCompletion.value = true;
    hasSubmitted.value = true;
    
    audioService.playCorrectFeedback();
    audioService.setInstructionAndSpeak(
      "Amazing! You completed all number line challenges!",
      "goingbed_audios/numberline_complete.mp3",
    );
    
    // Record quiz result
    addSubtractModuleController.recordQuizResult(
      quizId: "quiz2",
      score: score.value,
      retries: retries.value,
      isCompleted: true,
      wrongAnswersCount: wrongAttempts.value,
    );
    
    // Sync progress
    addSubtractModuleController.syncModuleProgress();
  }

  void resetQuiz() {
    currentQuestionIndex.value = 0;
    frogPosition.value = 0;
    showFeedback.value = false;
    isCorrect.value = false;
    score.value = 0;
    retries.value++;
    wrongAttempts.value = 0;
    hasSubmitted.value = false;
    showCompletion.value = false;
    
    audioService.setInstructionAndSpeak(
      "Let's try the number line again!",
      "goingbed_audios/numberline_reset.mp3",
    ).then((_) {
      Future.delayed(const Duration(seconds: 2), () {
        loadCurrentQuestion();
      });
    });
  }

  void checkAnswerAndNavigate() {
    if (hasSubmitted.value && showCompletion.value) {
      // Navigate to the next screen
      // Get.to(() => const NextScreen());
    } else {
      checkAnswer();
    }
  }

  // Progress tracking methods
  double getProgressPercentage() {
    return (currentQuestionIndex.value + (showFeedback.value ? 1 : 0)) / questions.length;
  }

  int getRemainingQuestions() {
    return questions.length - (currentQuestionIndex.value + (showFeedback.value ? 1 : 0));
  }

  String getCurrentQuestionProgress() {
    return "Question ${currentQuestionIndex.value + 1}/${questions.length}";
  }

  // Get the current problem with answer for display
  String getCurrentProblemWithAnswer() {
    return "${currentQuestion['problem']} = ${targetAnswer.value}";
  }

  // Get frog movement instructions
  String getFrogMovementInstruction() {
    if (currentOperation.value == "+") {
      return "Jump ${operationValue.value} spaces forward";
    } else {
      return "Jump ${operationValue.value} spaces backward";
    }
  }

  Map<String, dynamic> get currentQuestion => questions[currentQuestionIndex.value];
  bool get isLastQuestion => currentQuestionIndex.value == questions.length - 1;
  String get currentProblem => currentQuestion["problem"];

  @override
  void onClose() {
    audioService.stopSpeaking();
    super.onClose();
  }
}