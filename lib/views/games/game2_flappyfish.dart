import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Game2FlappyFish extends FlameGame with TapDetector, HasCollisionDetection {
  late AnimatedFish player;
  final double gravity = 800;
  final double jumpForce = -300;
  final List<Obstacle> obstacles = [];
  double spawnTimer = 0;
  double obstacleInterval = 2.0;
  int score = 0;
  bool isGameOver = false;

  late TextComponent scoreText;
  late SpriteComponent background;
  final Random random = Random();

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Background
    final bgSprite = await loadSprite('ocean_bg.png');
    background = SpriteComponent()
      ..sprite = bgSprite
      ..size = size
      ..position = Vector2.zero();
    add(background);

    final fishFrames = await Future.wait([
      loadSprite('fish1.png'),
      loadSprite('fish2.png'),
      loadSprite('fish3.png'),
    ]);
    player = AnimatedFish(fishFrames, size: Vector2(60, 40))
      ..position = Vector2(size.x / 4, size.y / 2);
    add(player);

    // Score UI
    scoreText = TextComponent(
      text: 'Score: 0',
      position: Vector2(10, 30),
      anchor: Anchor.topLeft,
      textRenderer: TextPaint(
        style: const TextStyle(
            fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
    add(scoreText);

    // Background music
    FlameAudio.bgm.initialize();
    FlameAudio.bgm.play('bg_music2.mp3', volume: 0.5);
    FlameAudio.bgm.audioPlayer.setReleaseMode(ReleaseMode.loop);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isGameOver) return;

    // Gravity
    player.velocityY += gravity * dt;
    player.y += player.velocityY * dt;

    if (player.y < 0) player.y = 0;
    if (player.y + player.height > size.y) _endGame();

    // Spawn obstacles
    spawnTimer += dt;
    if (spawnTimer > obstacleInterval) {
      spawnTimer = 0;
      spawnObstacle();
    }

    // Update obstacles
    for (final obs in obstacles) {
      obs.x -= 200 * dt;

      if (!obs.isPassed && obs.x + obs.width < player.x) {
        score++;
        scoreText.text = 'Score: $score';
        obs.isPassed = true;
        FlameAudio.play('point_sound.mp3', volume: 0.8);
      }

      if (obs.x + obs.width < 0) obs.removeFromParent();

      if (player.toRect().overlaps(obs.topRect) ||
          player.toRect().overlaps(obs.bottomRect)) {
        _endGame();
      }
    }
  }

  @override
  void onTapDown(TapDownInfo info) {
    if (isGameOver) return;
    player.velocityY = jumpForce;
    FlameAudio.play('jump_sound.mp3', volume: 0.8);
  }

  void spawnObstacle() async {
    final gapHeight = 150.0;
    final topHeight = random.nextDouble() * (size.y - gapHeight - 100) + 50;
    final bottomHeight = size.y - topHeight - gapHeight;

    final obstacle = Obstacle(
      x: size.x,
      width: 60,
      topHeight: topHeight,
      bottomHeight: bottomHeight,
    );

    obstacles.add(obstacle);
    add(obstacle);
  }

  void _endGame() {
    isGameOver = true;
    FlameAudio.bgm.stop();

    Get.defaultDialog(
      title: 'Game Over',
      middleText: 'Your score: $score',
      textConfirm: 'OK',
      onConfirm: () => Get.back(),
      barrierDismissible: false,
    );
  }
}

class AnimatedFish extends SpriteAnimationComponent {
  double velocityY = 0;

  AnimatedFish(List<Sprite> frames, {required Vector2 size})
      : super(
          animation: SpriteAnimation.spriteList(frames, stepTime: 0.2, loop: true),
          size: size,
        );
}

class Obstacle extends PositionComponent {
  final double topHeight;
  final double bottomHeight;
  final double width;
  bool isPassed = false;

  late Rect topRect;
  late Rect bottomRect;

  Obstacle({
    required double x,
    required this.width,
    required this.topHeight,
    required this.bottomHeight,
  }) : super(position: Vector2(x, 0), size: Vector2(width, topHeight + bottomHeight));

  @override
  void onLoad() {
    super.onLoad();
    topRect = Rect.fromLTWH(x, 0, width, topHeight);
    bottomRect = Rect.fromLTWH(x, size.y - bottomHeight, width, bottomHeight);
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()..color = Colors.green;
    canvas.drawRect(topRect, paint);
    canvas.drawRect(bottomRect, paint);
  }
}
