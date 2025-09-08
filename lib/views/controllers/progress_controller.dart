import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProgressController extends GetxController {
  static ProgressController get to => Get.find();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  RxInt totalScore = 0.obs;
  RxInt totalQuizzesCompleted = 0.obs;
  RxInt totalLearningTime = 0.obs;
  RxList<String> completedModules = <String>[].obs;
  RxList<String> recentModules = <String>[].obs;
  Rx<DateTime?> lastLogin = Rx<DateTime?>(null);
  RxBool isLoading = false.obs;
  RxInt totalWrongAnswers = 0.obs; // Add this to track wrong answers

  String get _uid => _auth.currentUser?.uid ?? "";

  @override
  void onInit() {
    super.onInit();
    _createProgressDocIfNeeded();
  }

  Future<void> _createProgressDocIfNeeded() async {
    if (_uid.isEmpty) return;

    final overviewRef = _firestore
        .collection('users')
        .doc(_uid)
        .collection('progress')
        .doc('overview');

    final snapshot = await overviewRef.get();

    if (!snapshot.exists) {
      await overviewRef.set({
        "totalScore": 0,
        "totalQuizzesCompleted": 0,
        "totalLearningTime": 0,
        "totalWrongAnswers": 0, // Add this field
        "completedModules": [],
        "recentModules": [],
        "lastLogin": FieldValue.serverTimestamp(),
        "lastUpdated": FieldValue.serverTimestamp(),
      });
    } else {
      await overviewRef.update({"lastLogin": FieldValue.serverTimestamp()});
    }

    await _loadProgress();
  }

  Future<void> _loadProgress() async {
    if (_uid.isEmpty) return;
    isLoading.value = true;

    final docRef = _firestore
        .collection('users')
        .doc(_uid)
        .collection('progress')
        .doc('overview');

    final snapshot = await docRef.get();

    if (snapshot.exists) {
      final data = snapshot.data()!;
      totalScore.value = data['totalScore'] ?? 0;
      totalQuizzesCompleted.value = data['totalQuizzesCompleted'] ?? 0;
      totalLearningTime.value = data['totalLearningTime'] ?? 0;
      totalWrongAnswers.value = data['totalWrongAnswers'] ?? 0; // Load wrong answers
      completedModules.value = List<String>.from(data['completedModules'] ?? []);
      recentModules.value = List<String>.from(data['recentModules'] ?? []);
      lastLogin.value = (data['lastLogin'] as Timestamp?)?.toDate();
    }

    isLoading.value = false;
  }

  // Add this method to track wrong answers
  Future<void> recordWrongAnswer({
    required String moduleId,
    required String quizId,
    String? questionId,
    String? wrongAnswer,
    String? correctAnswer,
  }) async {
    if (_uid.isEmpty) return;

    final wrongAnswersRef = _firestore
        .collection('users')
        .doc(_uid)
        .collection('progress')
        .doc(moduleId);

    // Create a wrong answer entry
    final wrongAnswerData = {
      "timestamp": FieldValue.serverTimestamp(),
      "quizId": quizId,
      "questionId": questionId,
      "wrongAnswer": wrongAnswer,
      "correctAnswer": correctAnswer,
    };

    await wrongAnswersRef.set({
      "wrongAnswers": FieldValue.arrayUnion([wrongAnswerData])
    }, SetOptions(merge: true));

    // Update overview total wrong answers count
    final overviewRef = _firestore
        .collection('users')
        .doc(_uid)
        .collection('progress')
        .doc('overview');

    totalWrongAnswers.value += 1;

    await overviewRef.set({
      "totalWrongAnswers": totalWrongAnswers.value,
      "lastUpdated": FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
Future<void> updateQuizProgress({
  required String moduleId,
  required String quizId,
  required int score,
  required int retries,
  required bool isCompleted,
  int learningTime = 0,
  int wrongAnswers = 0,
}) async {
  if (_uid.isEmpty) return;

  final moduleRef = _firestore
      .collection('users')
      .doc(_uid)
      .collection('progress')
      .doc(moduleId);

  final moduleSnapshot = await moduleRef.get();
  Map<String, dynamic> currentQuizzes = {};
  int previousScore = 0;
  int previousWrongAnswers = 0;

  if (moduleSnapshot.exists) {
    final moduleData = moduleSnapshot.data()!;
    if (moduleData.containsKey('quizzes')) {
      currentQuizzes = Map<String, dynamic>.from(moduleData['quizzes']);
      
      if (currentQuizzes.containsKey(quizId)) {
        final previousQuizData = Map<String, dynamic>.from(currentQuizzes[quizId]);
        previousScore = previousQuizData['score'] ?? 0;
        previousWrongAnswers = previousQuizData['wrongAnswers'] ?? 0;
      }
    }
  }

  // Update the module progress
  await moduleRef.set({
    "quizzes": {
      quizId: {
        "score": score,
        "retries": retries,
        "isCompleted": isCompleted,
        "lastAttempt": FieldValue.serverTimestamp(),
        "timeSpent": FieldValue.increment(learningTime),
        "wrongAnswers": wrongAnswers,
      }
    }
  }, SetOptions(merge: true));

  // Update overview totals - CALCULATE PROPERLY
  final overviewRef = _firestore
      .collection('users')
      .doc(_uid)
      .collection('progress')
      .doc('overview');

  // Get current overview data
  final overviewSnapshot = await overviewRef.get();
  int currentTotalScore = 0;
  int currentTotalWrongAnswers = 0;
  int currentTotalQuizzesCompleted = 0;

  if (overviewSnapshot.exists) {
    final overviewData = overviewSnapshot.data()!;
    currentTotalScore = overviewData['totalScore'] ?? 0;
    currentTotalWrongAnswers = overviewData['totalWrongAnswers'] ?? 0;
    currentTotalQuizzesCompleted = overviewData['totalQuizzesCompleted'] ?? 0;
  }

  final newTotalScore = currentTotalScore - previousScore + score;
  final newTotalWrongAnswers = currentTotalWrongAnswers - previousWrongAnswers + wrongAnswers;
  
  final newTotalQuizzesCompleted = isCompleted ? currentTotalQuizzesCompleted + 1 : currentTotalQuizzesCompleted;

  totalScore.value = newTotalScore;
  totalQuizzesCompleted.value = newTotalQuizzesCompleted;
  totalLearningTime.value += learningTime;
  totalWrongAnswers.value = newTotalWrongAnswers;

  if (!recentModules.contains(moduleId)) {
    recentModules.insert(0, moduleId);
    if (recentModules.length > 5) recentModules.removeLast(); // Increased to 5
  }

  if (isCompleted && !completedModules.contains(moduleId)) {
    completedModules.add(moduleId);
  }

  await overviewRef.set({
    "totalScore": newTotalScore,
    "totalQuizzesCompleted": newTotalQuizzesCompleted,
    "totalLearningTime": FieldValue.increment(learningTime),
    "totalWrongAnswers": newTotalWrongAnswers,
    "recentModules": recentModules,
    "completedModules": completedModules,
    "lastUpdated": FieldValue.serverTimestamp(),
  }, SetOptions(merge: true));
}  Future<void> createInitialProgress() async {
    await _createProgressDocIfNeeded();
  }

  Future<void> resetProgress() async {
    if (_uid.isEmpty) return;

    final userProgress = _firestore
        .collection('users')
        .doc(_uid)
        .collection('progress');

    // Delete all module docs except overview
    final moduleDocs = await userProgress.get();
    for (var doc in moduleDocs.docs) {
      if (doc.id != 'overview') await doc.reference.delete();
    }

    final overviewRef = userProgress.doc('overview');
    await overviewRef.set({
      "totalScore": 0,
      "totalQuizzesCompleted": 0,
      "totalLearningTime": 0,
      "totalWrongAnswers": 0, // Reset wrong answers
      "completedModules": [],
      "recentModules": [],
      "lastLogin": FieldValue.serverTimestamp(),
      "lastUpdated": FieldValue.serverTimestamp(),
    });

    totalScore.value = 0;
    totalQuizzesCompleted.value = 0;
    totalLearningTime.value = 0;
    totalWrongAnswers.value = 0; // Reset wrong answers
    completedModules.clear();
    recentModules.clear();
    lastLogin.value = null;
  }

Future<void> fixCorruptedData() async {
  if (_uid.isEmpty) return;

  // First, calculate the actual totals from all modules
  final userProgress = _firestore
      .collection('users')
      .doc(_uid)
      .collection('progress');

  final allModules = await userProgress.get();
  
  int actualTotalScore = 0;
  int actualTotalQuizzesCompleted = 0;
  int actualTotalWrongAnswers = 0;
  List<String> actualCompletedModules = [];
  List<String> actualRecentModules = [];

  for (var doc in allModules.docs) {
    if (doc.id != 'overview' && doc.data().containsKey('quizzes')) {
      final quizzes = doc.data()['quizzes'] as Map<String, dynamic>;
      
      for (var quizEntry in quizzes.entries) {
        final quizData = quizEntry.value as Map<String, dynamic>;
        
        // SAFELY get score and wrongAnswers with null checks
        final int score = (quizData['score'] is int) ? quizData['score'] : 0;
        final int wrongAnswers = (quizData['wrongAnswers'] is int) ? quizData['wrongAnswers'] : 0;
        
        actualTotalScore += score;
        actualTotalWrongAnswers += wrongAnswers;
        
        // SAFELY check if quiz is completed
        final bool isCompleted = (quizData['isCompleted'] is bool) 
            ? quizData['isCompleted'] 
            : false;
            
        if (isCompleted) {
          actualTotalQuizzesCompleted++;
        }
      }
      
      // Check if module is completed (all quizzes completed)
      bool allQuizzesCompleted = true;
      for (var quizEntry in quizzes.entries) {
        final quizData = quizEntry.value as Map<String, dynamic>;
        final bool isCompleted = (quizData['isCompleted'] is bool) 
            ? quizData['isCompleted'] 
            : false;
            
        if (!isCompleted) {
          allQuizzesCompleted = false;
          break;
        }
      }
      
      if (allQuizzesCompleted) {
        actualCompletedModules.add(doc.id);
      }
      
      actualRecentModules.add(doc.id);
    }
  }

  // Keep only last 5 recent modules
  if (actualRecentModules.length > 5) {
    actualRecentModules = actualRecentModules.sublist(0, 5);
  }

  // Update the overview with correct data
  final overviewRef = userProgress.doc('overview');
  await overviewRef.set({
    "totalScore": actualTotalScore,
    "totalQuizzesCompleted": actualTotalQuizzesCompleted,
    "totalLearningTime": 0, // Reset or calculate actual time if needed
    "totalWrongAnswers": actualTotalWrongAnswers,
    "completedModules": actualCompletedModules,
    "recentModules": actualRecentModules,
    "lastLogin": FieldValue.serverTimestamp(),
    "lastUpdated": FieldValue.serverTimestamp(),
  });

  // Update local state
  totalScore.value = actualTotalScore;
  totalQuizzesCompleted.value = actualTotalQuizzesCompleted;
  totalWrongAnswers.value = actualTotalWrongAnswers;
  completedModules.value = actualCompletedModules;
  recentModules.value = actualRecentModules;
}
  
}

