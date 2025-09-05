import 'package:flutter/material.dart';

class StepProgressHeaderquiz3 extends StatefulWidget {
  final int currentStep;
  final VoidCallback onBack;

  const StepProgressHeaderquiz3({
    Key? key,
    required this.currentStep,
    required this.onBack,
  }) : super(key: key);

  @override
  _StepProgressHeaderquiz3State createState() => _StepProgressHeaderquiz3State();
}

class _StepProgressHeaderquiz3State extends State<StepProgressHeaderquiz3> {
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
            children: List.generate(3, (index) {
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