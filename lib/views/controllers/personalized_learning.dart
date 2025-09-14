import 'package:autism_fyp/views/widget/custom_widget.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:autism_fyp/views/screens/home_screen.dart';

class PersonalizationQuestionsScreen extends StatefulWidget {
  final bool isFirstTime;
  
  const PersonalizationQuestionsScreen({super.key, this.isFirstTime = false});

  @override
  _PersonalizationQuestionsScreenState createState() => _PersonalizationQuestionsScreenState();
}

class _PersonalizationQuestionsScreenState extends State<PersonalizationQuestionsScreen> {
  int _currentQuestionIndex = 0;
  final Map<String, dynamic> _answers = {};
  final List<Question> _questions = [
    Question(
      id: 'learning_style',
      question: 'How does your child learn best?',
      options: ['Visual (pictures, videos)', 'Auditory (listening, sounds)', 'Kinesthetic (hands-on activities)', 'Mixed approach'],
      type: QuestionType.singleChoice,
    ),
    Question(
      id: 'difficulty_level',
      question: 'What difficulty level is most comfortable?',
      options: ['Beginner', 'Intermediate', 'Advanced'],
      type: QuestionType.singleChoice,
    ),
    Question(
      id: 'interests',
      question: "What are your child's interests?",
      options: ['Animals', 'Numbers', 'Letters', 'Music', 'Art', 'Sports', 'Nature', 'Vehicles'],
      type: QuestionType.multipleChoice,
    ),
    Question(
      id: 'attention_span',
      question: 'How long can your child typically focus?',
      options: ['5-10 minutes', '10-20 minutes', '20-30 minutes', '30+ minutes'],
      type: QuestionType.singleChoice,
    ),
    Question(
      id: 'challenges',
      question: 'What areas need the most support?',
      options: ['Communication', 'Social skills', 'Academic skills', 'Behavior regulation', 'Daily living skills'],
      type: QuestionType.multipleChoice,
    ),
  ];

  final Color _primaryColor = const Color(0xFF0E83AD);
  final Color _backgroundColor = const Color(0xFFF5F9FF);
  final Color _cardColor = Colors.white;
  final Color _textColor = const Color(0xFF2C3E50);

  Future<void> _saveAnswersAndNavigate() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        // Save to personalized_learning collection
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('personalized_learning')
            .doc('preferences')
            .set({
          'answers': _answers,
          'completedAt': FieldValue.serverTimestamp(),
          'isFirstTime': widget.isFirstTime,
        });
        
        // Update user document
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .update({
          'hasCompletedPreferences': true,
          'lastPreferenceUpdate': FieldValue.serverTimestamp(),
        });
        
        // Navigate to home screen
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              LinearProgressIndicator(
                value: (_currentQuestionIndex + 1) / _questions.length,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(_primaryColor),
              ),
              const SizedBox(height: 30),
              Text(
                'Personalized Learning',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: _primaryColor,
                ),
              ),
              const SizedBox(height: 30),
              Expanded(child: _buildQuestionCard()),
              const SizedBox(height: 20),
              _buildNavigationButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionCard() {
    final question = _questions[_currentQuestionIndex];
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: _cardColor,
      child: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Question ${_currentQuestionIndex + 1}/${_questions.length}',
              style: TextStyle(color: _primaryColor, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 15),
            Text(question.question, style: TextStyle(fontSize: 22, color: _textColor)),
            const SizedBox(height: 25),
            Expanded(child: _buildOptions(question)),
          ],
        ),
      ),
    );
  }

  Widget _buildOptions(Question question) {
    if (question.type == QuestionType.singleChoice) {
      return ListView.builder(
        itemCount: question.options.length,
        itemBuilder: (context, index) {
          final option = question.options[index];
          final isSelected = _answers[question.id] == option;
          return ListTile(
            title: Text(option),
            leading: Radio(
              value: option,
              groupValue: _answers[question.id],
              onChanged: (value) => setState(() => _answers[question.id] = value),
            ),
            onTap: () => setState(() => _answers[question.id] = option),
          );
        },
      );
    } else {
      final selectedOptions = List<String>.from(_answers[question.id] ?? []);
      return ListView.builder(
        itemCount: question.options.length,
        itemBuilder: (context, index) {
          final option = question.options[index];
          return CheckboxListTile(
            title: Text(option),
            value: selectedOptions.contains(option),
            onChanged: (value) {
              setState(() {
                if (value == true) {
                  selectedOptions.add(option);
                } else {
                  selectedOptions.remove(option);
                }
                _answers[question.id] = selectedOptions;
              });
            },
          );
        },
      );
    }
  }

  Widget _buildNavigationButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (_currentQuestionIndex > 0)
          CustomElevatedButton(
            text: 'Previous',
            onPressed: () => setState(() => _currentQuestionIndex--),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[300]),
          )
        else
          const SizedBox(width: 100),
        CustomElevatedButton(
          text: _currentQuestionIndex == _questions.length - 1 ? 'Complete' : 'Next',
          onPressed: () async {
            if (_answers[_questions[_currentQuestionIndex].id] == null ||
                (_questions[_currentQuestionIndex].type == QuestionType.multipleChoice && 
                 (_answers[_questions[_currentQuestionIndex].id] as List).isEmpty)) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please select an answer')),
              );
              return;
            }
            
            if (_currentQuestionIndex < _questions.length - 1) {
              setState(() => _currentQuestionIndex++);
            } else {
              await _saveAnswersAndNavigate();
            }
          },
        ),
      ],
    );
  }
}

class Question {
  final String id;
  final String question;
  final List<String> options;
  final QuestionType type;

  Question({required this.id, required this.question, required this.options, required this.type});
}

enum QuestionType { singleChoice, multipleChoice }