import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'quiz4_controller.dart';

class Quiz4matching extends StatefulWidget {
  final List<String> leftImages;
  final List<String> rightImages;
  final Quiz4matchingController controller;

  const Quiz4matching({
    Key? key,
    required this.leftImages,
    required this.rightImages,
    required this.controller,
  }) : super(key: key);

  @override
  State<Quiz4matching> createState() => _Quiz4State();
}

class _Quiz4State extends State<Quiz4matching> {
  final List<GlobalKey> leftKeys = [];
  final List<GlobalKey> rightKeys = [];

  Offset? dragStart;
  Offset? dragCurrent;
  int? selectedLeftIndex;
  RenderBox? parentBox;

  @override
  void initState() {
    super.initState();
    leftKeys.addAll(List.generate(widget.leftImages.length, (_) => GlobalKey()));
    rightKeys.addAll(List.generate(widget.rightImages.length, (_) => GlobalKey()));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        parentBox = context.findRenderObject() as RenderBox?;
      });
    });
  }

  Offset? _getLocalCenter(GlobalKey key) {
    if (parentBox == null || key.currentContext == null) return null;
    final renderBox = key.currentContext!.findRenderObject() as RenderBox;
    final globalPos = renderBox.localToGlobal(Offset.zero);
    final localPos = parentBox!.globalToLocal(globalPos);
    return localPos + Offset(renderBox.size.width / 2, renderBox.size.height / 2);
  }

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;

    // Base size proportional to screen width, clamped for min/max
    double baseSize = screen.width * 0.12;
    final imageSize = baseSize.clamp(60.0, 120.0);

    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            // Line drawing layer
            Positioned.fill(
              child: CustomPaint(
                painter: MatchLinePainter(
                  controller: widget.controller,
                  leftKeys: leftKeys,
                  rightKeys: rightKeys,
                  currentLineStart: dragStart,
                  currentLineEnd: dragCurrent,
                  getLocalCenter: _getLocalCenter,
                ),
              ),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // LEFT COLUMN
                Flexible(
                  flex: 1,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                    children: List.generate(widget.leftImages.length, (index) {
                      return GestureDetector(
                        key: leftKeys[index],
                        onPanStart: (details) {
                          dragStart = _getLocalCenter(leftKeys[index]);
                          dragCurrent = dragStart;
                          selectedLeftIndex = index;
                          setState(() {});
                        },
                        onPanUpdate: (details) {
                          if (parentBox != null) {
                            dragCurrent = parentBox!.globalToLocal(details.globalPosition);
                            setState(() {});
                          }
                        },
                        onPanEnd: (details) {
                          if (parentBox != null) {
                            for (int i = 0; i < rightKeys.length; i++) {
                              final center = _getLocalCenter(rightKeys[i]);
                              if (center != null) {
                                final renderBox = rightKeys[i]
                                    .currentContext!
                                    .findRenderObject() as RenderBox;
                                final rect = renderBox.paintBounds.shift(
                                  parentBox!.globalToLocal(
                                    renderBox.localToGlobal(Offset.zero),
                                  ),
                                );
                                if (rect.contains(dragCurrent!)) {
                                  widget.controller.selectMatch(selectedLeftIndex!, i);
                                }
                              }
                            }
                          }
                          dragStart = null;
                          dragCurrent = null;
                          selectedLeftIndex = null;
                          setState(() {});
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: imageSize * 0.12),
                          child: Image.asset(widget.leftImages[index], height: imageSize),
                        ),
                      );
                    }),
                  ),
                ),

                SizedBox(width: constraints.maxWidth * 0.45),

                // RIGHT COLUMN
                Flexible(
                  flex: 1,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(widget.rightImages.length, (index) {
                      return Padding(
                          padding: EdgeInsets.symmetric(vertical: imageSize * 0.12),
                        child: Container(
                          key: rightKeys[index],
                          child: Image.asset(widget.rightImages[index], height: imageSize),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}


class MatchLinePainter extends CustomPainter {
  final Quiz4matchingController controller;
  final List<GlobalKey> leftKeys;
  final List<GlobalKey> rightKeys;
  final Offset? currentLineStart;
  final Offset? currentLineEnd;
  final Offset? Function(GlobalKey key) getLocalCenter;
  var isChecking = false.obs;


  MatchLinePainter({
    required this.controller,
    required this.leftKeys,
    required this.rightKeys,
    required this.currentLineStart,
    required this.currentLineEnd,
    required this.getLocalCenter,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 3;

    // Permanent matches
controller.userPairs.forEach((left, right) {
  final p1 = getLocalCenter(leftKeys[left]);
  final p2 = getLocalCenter(rightKeys[right]);

  if (p1 != null && p2 != null) {
    if (controller.isChecking.value) {
      // ✅ Show green or red if checking
      final isCorrect = controller.correctPairs[left] == right;
      paint.color = isCorrect ? Colors.green : Colors.red;
    } else {
      // 🟦 Always blue before checking
      paint.color = const Color(0xFF0E83AD);
    }
    canvas.drawLine(p1, p2, paint);
  }
});



    // Current dragging line
    if (currentLineStart != null && currentLineEnd != null) {
      canvas.drawLine(currentLineStart!, currentLineEnd!, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
