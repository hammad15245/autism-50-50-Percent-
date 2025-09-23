// lib/screens/art_game_screen.dart
import 'package:autism_fyp/views/games/game3_art.dart';
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:get/get.dart';
import 'package:confetti/confetti.dart';
import 'package:autism_fyp/views/controllers/global_audio_services.dart';

class ArtGameScreen extends StatefulWidget {
  const ArtGameScreen({Key? key}) : super(key: key);

  @override
  State<ArtGameScreen> createState() => _ArtGameScreenState();
}

class _ArtGameScreenState extends State<ArtGameScreen> {
  late final ArtGame _game;
  late final ConfettiController _confettiCtrl;
  final audioService = Get.find<AudioInstructionService>();

  @override
  void initState() {
    super.initState();
    _game = ArtGame();
    _confettiCtrl = ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _confettiCtrl.dispose();
    super.dispose();
  }

  Future<void> _onCheck() async {
    final success = await _game.checkDrawing();
    if (success) {
      _confettiCtrl.play();
    }
  }

  Widget _buildColorCircle(Color c) {
    return GestureDetector(
      onTap: () => setState(() => _game.selectedColor.value = c),
      child: ValueListenableBuilder<Color>(
        valueListenable: _game.selectedColor,
        builder: (_, sel, __) {
          final isSelected = sel == c;
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 6),
            width: isSelected ? 44 : 36,
            height: isSelected ? 44 : 36,
            decoration: BoxDecoration(
              color: c,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? Colors.black : Colors.grey.shade300,
                width: isSelected ? 3 : 1.5,
              ),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 4)],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = [Colors.black, Colors.red, Colors.green, Colors.blue, Colors.orange, Colors.purple];

    return Scaffold(
      body: Stack(
        children: [
          GameWidget(game: _game),

          // Top bar
          SafeArea(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Color.fromARGB(255, 0, 0, 0), size: 30),
                  onPressed: () => Navigator.pop(context),
                ),
                const Text(
                  'Art Studio',
                  style: TextStyle(
                    color: Color.fromARGB(255, 0, 0, 0),
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // Toggle template visibility
                ValueListenableBuilder<bool>(
                  valueListenable: _game.showTemplate,
                  builder: (context, show, _) {
                    return IconButton(
                      icon: Icon(show ? Icons.visibility : Icons.visibility_off, color: const Color.fromARGB(255, 0, 0, 0)),
                      onPressed: () => setState(() => _game.toggleTemplate()),
                    );
                  },
                ),
              ],
            ),
          ),

          Positioned(
            left: 12,
            right: 12,
            bottom: 18,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Color palette row
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: palette.map(_buildColorCircle).toList(),
                  ),
                ),
                const SizedBox(height: 8),

                // Brush size slider
                Row(
                  children: [
                    const Text('Brush', style: TextStyle(fontWeight: FontWeight.w600)),
                    Expanded(
                      child: ValueListenableBuilder<double>(
                        valueListenable: _game.selectedBrushSize,
                        builder: (_, value, __) {
                          return Slider(
                            min: 2,
                            max: 18,
                            value: value,
                            onChanged: (v) => setState(() => _game.selectedBrushSize.value = v),
                          );
                        },
                      ),
                    ),
                    Text('${_game.selectedBrushSize.value.toInt()}'),
                  ],
                ),

                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => setState(() => _game.clearCanvas()),
                      icon: const Icon(Icons.clear, color: Colors.white,),
                      label: const Text('Clear'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => setState(() => _game.undoStroke()),
                      icon: const Icon(Icons.undo, color: Colors.white,),
                      label: const Text('Undo'),
                                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),

                    ),
                    ElevatedButton.icon(
                      onPressed: _onCheck,
                      icon: const Icon(Icons.check, color: Colors.white,),
                      label: const Text('Check'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ConfettiWidget(
              confettiController: _confettiCtrl,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
            ),
          ),
        ],
      ),
    );
  }
}
