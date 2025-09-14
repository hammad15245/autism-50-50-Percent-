import 'package:autism_fyp/views/games/game2_flappyfish.dart';
import 'package:flutter/material.dart';
import 'package:flame/game.dart';

class Game2Screen extends StatelessWidget {
  const Game2Screen({super.key});

  @override
  Widget build(BuildContext context) {
    final game = Game2FlappyFish();

    return Scaffold(
      body: Stack(
        children: [
          GameWidget(game: game),
          Positioned(
            top: 40,
            left: 10,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 32),
              onPressed: () {
                game.pauseEngine();
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}
