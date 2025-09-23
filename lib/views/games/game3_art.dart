import 'dart:ui' as ui;
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:autism_fyp/views/controllers/global_audio_services.dart';

class ArtGame extends FlameGame with PanDetector {
  final List<DrawStroke> strokes = [];
  DrawStroke? currentStroke;

  final ValueNotifier<Color> selectedColor = ValueNotifier<Color>(Colors.black);
  final ValueNotifier<double> selectedBrushSize = ValueNotifier<double>(6.0);
  final ValueNotifier<bool> showTemplate = ValueNotifier<bool>(true);

  final AudioInstructionService audioService = Get.find<AudioInstructionService>();

  late Rect drawingArea;
  late ui.Image templateImage;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    templateImage = await images.load('apple_templete.png');

    drawingArea = Rect.fromLTWH(
      size.x * 0.06,
      size.y * 0.12,
      size.x * 0.88,
      size.y * 0.72,
    );
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final bg = Paint()..color = const Color(0xFFF7FAFF);
    canvas.drawRect(size.toRect(), bg);

    final panelPaint = Paint()..color = Colors.white;
    final rrect = RRect.fromRectAndRadius(drawingArea, const Radius.circular(16));
    canvas.drawRRect(rrect, panelPaint);

    final border = Paint()
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawRRect(rrect, border);

    if (showTemplate.value) {
      canvas.saveLayer(drawingArea, Paint());
      canvas.drawImageRect(
        templateImage,
        Rect.fromLTWH(0, 0, templateImage.width.toDouble(), templateImage.height.toDouble()),
        drawingArea,
        Paint()..color = Colors.white.withOpacity(0.3),
      );
      canvas.restore();
    }

    final textPainter = TextPainter(
      text: const TextSpan(
          text: "🎨 Color or trace the image",
          style: TextStyle(color: Colors.black54, fontSize: 16)),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(maxWidth: drawingArea.width - 24);
    textPainter.paint(canvas, Offset(drawingArea.left + 12, drawingArea.top + 10));

    for (final s in strokes) {
      s.paintStroke(canvas);
    }
    currentStroke?.paintStroke(canvas);
  }

  @override
  void onPanStart(DragStartInfo info) {
    final pos = info.eventPosition.widget;
    if (!drawingArea.contains(pos.toOffset())) return;

    currentStroke = DrawStroke(
      color: selectedColor.value,
      strokeWidth: selectedBrushSize.value,
    );
    currentStroke!.points.add(pos);
  }

  @override
  void onPanUpdate(DragUpdateInfo info) {
    if (currentStroke == null) return;
    final pos = info.eventPosition.widget;
    final clamped = Vector2(
      pos.x.clamp(drawingArea.left, drawingArea.right),
      pos.y.clamp(drawingArea.top, drawingArea.bottom),
    );
    currentStroke!.points.add(clamped);
  }

  @override
  void onPanEnd(DragEndInfo info) {
    if (currentStroke == null) return;
    strokes.add(currentStroke!);
    currentStroke = null;
  }

  void clearCanvas() {
    strokes.clear();
  }

  void undoStroke() {
    if (strokes.isNotEmpty) strokes.removeLast();
  }

  void toggleTemplate() {
    showTemplate.value = !showTemplate.value;
  }

  Future<bool> checkDrawing() async {
    final success = strokes.isNotEmpty;
    if (success) {
      await audioService.playCorrectFeedback(message: "Yuhuu! Nice work!");
    } else {
      await audioService.playIncorrectFeedback(message: "Try to draw something!");
    }
    return success;
  }
}

class DrawStroke {
  final List<Vector2> points = [];
  final Color color;
  final double strokeWidth;

  DrawStroke({required this.color, required this.strokeWidth});

  void paintStroke(Canvas canvas) {
    if (points.isEmpty) return;
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    final first = points.first.toOffset();
    path.moveTo(first.dx, first.dy);
    for (int i = 1; i < points.length; i++) {
      final p = points[i].toOffset();
      path.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(path, paint);
  }
}
