import 'package:get/get.dart';
import 'package:autism_fyp/views/controllers/global_audio_services.dart';

class NumberLineController extends GetxController {
  final audioService = AudioInstructionService.to;
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
  "audio": "numberline_question3", // New audio file for this question
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
}
void moveFrog(int steps) {
  final newPosition = frogPosition.value + steps;
  if (newPosition >= 0 && newPosition <= 10) {
    frogPosition.value = newPosition;
  }
}

  void jumpForward() {
    if (frogPosition.value + operationValue.value <= 10) {
      frogPosition.value += operationValue.value;
    }
  }

  void jumpBackward() {
    if (frogPosition.value - operationValue.value >= 0) {
      frogPosition.value -= operationValue.value;
    }
  }

  void checkAnswer() {
    isCorrect.value = frogPosition.value == targetAnswer.value;
    showFeedback.value = true;

    if (isCorrect.value) {
      score.value++;
      audioService.playCorrectFeedback();
    } else {
      audioService.playIncorrectFeedback();
    }
  }

  void nextQuestion() {
    if (currentQuestionIndex.value < questions.length - 1) {
      currentQuestionIndex.value++;
      loadCurrentQuestion();
    } else {
      showFeedback.value = false;
      audioService.setInstructionAndSpeak(
        "Amazing! You completed all number line challenges!",
        "goingbed_audios/numberline_complete.mp3",
      );
    }
  }

  // void resetQuiz() {
  //   score.value = 0;
  //   currentQuestionIndex.value = 0;
  //   audioService.setInstructionAndSpeak(
  //     "Let's try the number line again!",
  //     "goingbed_audios/numberline_reset.mp3",
  //   ).then((_) {
  //     Future.delayed(const Duration(seconds: 2), () {
  //       loadCurrentQuestion();
  //     });
  //   });
  // }
    void checkAnswerAndNavigate() {
     
      // Navigate to the next screen
      // Get.to(() => const NumberLinescreen());
      

    
}

  Map<String, dynamic> get currentQuestion => questions[currentQuestionIndex.value];
  bool get isLastQuestion => currentQuestionIndex.value == questions.length - 1;
  String get currentProblem => currentQuestion["problem"];
}