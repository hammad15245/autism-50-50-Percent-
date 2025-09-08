
import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:math';

class CountingGameWidget extends StatefulWidget {
  const CountingGameWidget({Key? key}) : super(key: key);

  @override
  State<CountingGameWidget> createState() => _CountingGameWidgetState();
}

class _CountingGameWidgetState extends State<CountingGameWidget> {
  late Offset playerPosition;
  final double playerSize = 50.0;
  List<CollectibleBall> balls = [];
  int score = 0;
  int targetScore = 10;
  double timeLeft = 20;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    playerPosition = const Offset(100, 100);
    _spawnBalls();
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        timeLeft -= 1;
        if (timeLeft <= 0) {
          timer.cancel();
          // game over
          // You can show a dialog or navigate here
        }
      });
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void _spawnBalls() {
    balls.clear();
    final rand = Random();
    for (int i = 0; i < 10; i++) {
      balls.add(
        CollectibleBall(
          position: Offset(
            rand.nextDouble() * (300 - 40), // Assuming screen width 300
            rand.nextDouble() * (500 - 40), // Assuming screen height 500
          ),
          size: 40.0,
        ),
      );
    }
  }

  void _collectBall(int index) {
    setState(() {
      score++;
      balls.removeAt(index);
      if (score >= targetScore) {
        // Level Complete!
        // You can show a dialog or navigate here
      }
    });
  }

  void _movePlayer(DragUpdateDetails details) {
    setState(() {
      double newX = (playerPosition.dx + details.delta.dx).clamp(0.0, 300 - playerSize);
      double newY = (playerPosition.dy + details.delta.dy).clamp(0.0, 500 - playerSize);
      playerPosition = Offset(newX, newY);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: _movePlayer,
      onTapDown: (details) {
        for (int i = 0; i < balls.length; i++) {
          if (balls[i].toRect().contains(details.globalPosition)) {
            _collectBall(i);
            break;
          }
        }
      },
      child: CustomPaint(
        size: const Size(300, 500),
        painter: CountingGamePainter(
          playerPosition: playerPosition,
          playerSize: playerSize,
          balls: balls,
          score: score,
          timeLeft: timeLeft,
        ),
      ),
    );
  }
}

class CountingGamePainter extends CustomPainter {
  final Offset playerPosition;
  final double playerSize;
  final List<CollectibleBall> balls;
  final int score;
  final double timeLeft;

  CountingGamePainter({
    required this.playerPosition,
    required this.playerSize,
    required this.balls,
    required this.score,
    required this.timeLeft,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw player
    Paint playerPaint = Paint()..color = Colors.blue;
    canvas.drawRect(
      Rect.fromLTWH(playerPosition.dx, playerPosition.dy, playerSize, playerSize),
      playerPaint,
    );

    // Draw balls
    Paint ballPaint = Paint()..color = Colors.red;
    for (var ball in balls) {
      canvas.drawOval(ball.toRect(), ballPaint);
    }

    // Draw score and timer
    TextPainter tpScore = TextPainter(
      text: TextSpan(
        text: 'Score: $score',
        style: const TextStyle(color: Colors.black, fontSize: 24),
      ),
      textDirection: TextDirection.ltr,
    );
    tpScore.layout();
    tpScore.paint(canvas, const Offset(10, 10));

    TextPainter tpTime = TextPainter(
      text: TextSpan(
        text: 'Time: ${timeLeft.toInt()}',
        style: const TextStyle(color: Colors.black, fontSize: 24),
      ),
      textDirection: TextDirection.ltr,
    );
    tpTime.layout();
    tpTime.paint(canvas, const Offset(10, 40));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class CollectibleBall {
  Offset position;
  double size;

  CollectibleBall({required this.position, required this.size});

  Rect toRect() {
    return Rect.fromLTWH(position.dx, position.dy, size, size);
  }
}
