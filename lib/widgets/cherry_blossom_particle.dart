import 'dart:math';
import 'package:flutter/material.dart';

class CherryBlossomParticle extends StatefulWidget {
  const CherryBlossomParticle({super.key});

  @override
  State<CherryBlossomParticle> createState() => _CherryBlossomParticleState();
}

class _CherryBlossomParticleState extends State<CherryBlossomParticle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_Blossom> _blossoms = [];
  final Random _random = Random();

  // 花瓣颜色
  static const _colors = [
    Color(0xFFFFB7C5), // 樱花粉
    Color(0xFFFFC0CB), // 粉色
    Color(0xFFFF69B4), // 热粉
    Color(0xFFFFE4E1), // 浅鲑鱼
    Color(0xFFFFF0F5), // 薰衣草红
    Color(0xFFFFFACD), // 柠檬绸
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    // 初始化樱花
    for (int i = 0; i < 25; i++) {
      _blossoms.add(_Blossom(
        x: _random.nextDouble() * 1.3,
        y: -0.05 - _random.nextDouble() * 0.3,
        size: _random.nextDouble() * 12 + 6,
        speedY: _random.nextDouble() * 0.003 + 0.001,
        speedX: _random.nextDouble() * 0.003 + 0.0005,
        delay: _random.nextDouble() * 8,
        rotation: _random.nextDouble() * pi * 2,
        rotationSpeed: (_random.nextDouble() - 0.5) * 0.04,
        color: _colors[_random.nextInt(_colors.length)],
        wobble: _random.nextDouble() * 0.002 + 0.001,
        wobblePhase: _random.nextDouble() * pi * 2,
        opacity: _random.nextDouble() * 0.5 + 0.3,
      ));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        for (final blossom in _blossoms) {
          blossom.update(_controller.value);
        }
        return CustomPaint(
          painter: _BlossomPainter(_blossoms),
          size: Size.infinite,
        );
      },
    );
  }
}

class _Blossom {
  double x;
  double y;
  double size;
  double speedY;
  double speedX;
  double delay;
  double rotation;
  double rotationSpeed;
  Color color;
  double wobble;
  double wobblePhase;
  double opacity;
  final Random _random = Random();

  _Blossom({
    required this.x,
    required this.y,
    required this.size,
    required this.speedY,
    required this.speedX,
    required this.delay,
    required this.rotation,
    required this.rotationSpeed,
    required this.color,
    required this.wobble,
    required this.wobblePhase,
    required this.opacity,
  });

  void update(double time) {
    if (delay > 0) {
      delay -= 0.02;
      return;
    }

    // 飘落
    y += speedY;
    wobblePhase += wobble;
    x -= speedX + sin(wobblePhase) * wobble * 0.5;

    // 旋转
    rotation += rotationSpeed;

    // 超出屏幕则重置
    if (y > 1.1 || x < -0.15) {
      _reset();
    }
  }

  void _reset() {
    x = 1.0 + _random.nextDouble() * 0.3;
    y = -0.05 - _random.nextDouble() * 0.2;
    size = _random.nextDouble() * 12 + 6;
    speedY = _random.nextDouble() * 0.003 + 0.001;
    speedX = _random.nextDouble() * 0.003 + 0.0005;
    rotation = _random.nextDouble() * pi * 2;
    rotationSpeed = (_random.nextDouble() - 0.5) * 0.04;
    wobble = _random.nextDouble() * 0.002 + 0.001;
    wobblePhase = _random.nextDouble() * pi * 2;
    opacity = _random.nextDouble() * 0.5 + 0.3;
  }
}

class _BlossomPainter extends CustomPainter {
  final List<_Blossom> blossoms;

  _BlossomPainter(this.blossoms);

  @override
  void paint(Canvas canvas, Size size) {
    for (final blossom in blossoms) {
      if (blossom.delay > 0) continue;

      final px = blossom.x * size.width;
      final py = blossom.y * size.height;
      final s = blossom.size;

      canvas.save();
      canvas.translate(px, py);
      canvas.rotate(blossom.rotation);

      // 绘制花瓣
      final paint = Paint()
        ..color = blossom.color.withOpacity(blossom.opacity)
        ..style = PaintingStyle.fill;

      // 五瓣花形状
      for (int i = 0; i < 5; i++) {
        final angle = (i * pi * 2 / 5) - pi / 2;
        final cx = cos(angle) * s * 0.35;
        final cy = sin(angle) * s * 0.35;

        canvas.drawCircle(
          Offset(cx, cy),
          s * 0.3,
          paint,
        );
      }

      // 花心
      final centerPaint = Paint()
        ..color = blossom.color.withOpacity(blossom.opacity * 0.8)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset.zero, s * 0.15, centerPaint);

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
