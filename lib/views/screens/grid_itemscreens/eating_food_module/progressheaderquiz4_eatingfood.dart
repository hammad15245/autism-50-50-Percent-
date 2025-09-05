import 'package:flutter/material.dart';

class StepProgressHeaderquiz4eating extends StatefulWidget {
  final int currentStep;
  final VoidCallback onBack;

  const StepProgressHeaderquiz4eating({
    Key? key,
    required this.currentStep,
    required this.onBack,
  }) : super(key: key);

  @override
  _StepProgressHeaderquiz4eatingState createState() => _StepProgressHeaderquiz4eatingState();
}

class _StepProgressHeaderquiz4eatingState extends State<StepProgressHeaderquiz4eating> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black,),
          onPressed: widget.onBack,
        ),
      
        Expanded(
          child: Row(
            children: List.generate(4, (index) {
              bool isCompleted = index < widget.currentStep;
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  height: 20, 
                  decoration: BoxDecoration(
                    color: isCompleted ? Color(0xFF0E83AD) : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10), 
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}