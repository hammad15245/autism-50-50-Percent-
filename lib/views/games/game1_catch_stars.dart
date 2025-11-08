import 'dart:math';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Game1CatchStars extends FlameGame
    with PanDetector, HasCollisionDetection {
  late Player player;
  final Random random = Random();

  double spawnTimer = 0;
  int score = 0;
  int totalStars = 50;
  int spawnedStars = 0;
  bool isGameOver = false;

  late TextComponent scoreText;
  late SpriteComponent background;

  bool pendingGameOver = false;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final bgSprite = await loadSprite('bg.png');
    background = SpriteComponent()
      ..sprite = bgSprite
      ..size = size
      ..position = Vector2.zero();
    add(background);

    final playerSprite = await loadSprite('player.png');
    player = Player(sprite: playerSprite, size: Vector2(60, 60))
      ..position = Vector2(size.x / 2 - 30, size.y - 80);
    add(player);

    scoreText = TextComponent(
      text: 'Score: 0',
      position: Vector2(10, 100),
      anchor: Anchor.topLeft,
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 24,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    add(scoreText);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isGameOver) return;

    spawnTimer += dt;

    if (spawnTimer > 1.0 && spawnedStars < totalStars) {
      spawnTimer = 0;
      spawnedStars++;
      spawnStar();
    }

    // Safe end-game trigger
    if (!pendingGameOver &&
        spawnedStars >= totalStars &&
        !children.any((c) => c is Star)) {
      pendingGameOver = true;
      Future.microtask(_endGame);
    }
  }

  void spawnStar() async {
    final starSprite = await loadSprite('star.png');

    final star = Star(
      sprite: starSprite,
      size: Vector2(30, 30),
      onCatch: () {
        if (isGameOver) return;

        score++;
        scoreText.text = 'Score: $score';
      },
    )..position =
        Vector2(random.nextDouble() * (size.x - 30), 0);

    star.add(
      MoveEffect.by(
        Vector2(0, size.y),
        EffectController(duration: 4),
        onComplete: () => star.removeFromParent(),
      ),
    );

    add(star);
  }

  @override
  void onPanUpdate(DragUpdateInfo info) {
    if (isGameOver) return;

    player.x += info.delta.global.x;
    player.x = player.x.clamp(0, size.x - player.width);
  }

  void _endGame() {
    if (isGameOver) return;
    isGameOver = true;

    // Show dialog next frame (prevents Flame errors)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!Get.isDialogOpen!) {
        Get.defaultDialog(
          title: 'Game Over',
          middleText: 'You caught $score stars!',
          textConfirm: 'OK',
          onConfirm: () => Get.back(),
          barrierDismissible: false,
        );
      }
    });
  }
}

class Player extends SpriteComponent with CollisionCallbacks {
  Player({required Sprite sprite, required Vector2 size})
      : super(sprite: sprite, size: size);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(RectangleHitbox());
  }
}

class Star extends SpriteComponent with CollisionCallbacks {
  final VoidCallback onCatch;

  Star({
    required this.onCatch,
    required Sprite sprite,
    required Vector2 size,
  }) : super(sprite: sprite, size: size);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(RectangleHitbox());
  }

  @override
  void onCollision(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollision(intersectionPoints, other);

    final game = findParent<Game1CatchStars>();
    if (game == null || game.isGameOver) return;

    if (other is Player) {
      onCatch();
      removeFromParent();
    }
  }
}
