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
  final List<CherryBlossom> _blossoms = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    // 初始化樱花 - 减少粒子数量以提高性能
    for (int i = 0; i < 15; i++) {
      _blossoms.add(CherryBlossom(
        x: _random.nextDouble() * 1.2,
        y: -0.1,
        size: _random.nextDouble() * 10 + 5,
        speedY: _random.nextDouble() * 0.005 + 0.002,
        speedX: _random.nextDouble() * 0.002 + 0.001,
        delay: _random.nextDouble() * 10,
        color: _getRandomColor(),
      ));
    }
  }

  Color _getRandomColor() {
    final colors = [
      Colors.pink.withOpacity(0.7),
      Colors.pinkAccent.withOpacity(0.7),
      Colors.red.withOpacity(0.7),
      Colors.redAccent.withOpacity(0.7),
    ];
    return colors[_random.nextInt(colors.length)];
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
        // 更新樱花位置
        for (final blossom in _blossoms) {
          blossom.update();
        }

        return Stack(
          children: _blossoms.map((blossom) => _buildBlossom(blossom)).toList(),
        );
      },
    );
  }

  Widget _buildBlossom(CherryBlossom blossom) {
    return Positioned(
      left: blossom.x * MediaQuery.of(context).size.width,
      top: blossom.y * MediaQuery.of(context).size.height,
      child: Opacity(
        opacity: blossom.opacity,
        child: Transform.rotate(
          angle: blossom.rotation,
          child: Container(
            width: blossom.size,
            height: blossom.size,
            decoration: BoxDecoration(
              color: blossom.color,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}
class CherryBlossom {
  double x;
  double y;
  double size;
  double speedY;
  double speedX;
  double delay;
  double rotation;
  double rotationSpeed;
  double opacity;
  Color color;
  final Random _random = Random();

  CherryBlossom({
    required this.x,
    required this.y,
    required this.size,
    required this.speedY,
    required this.speedX,
    required this.delay,
    required this.color,
  })  : rotation = 0,
        rotationSpeed = 0,
        opacity = 0 {
    rotationSpeed = _random.nextDouble() * 0.1 - 0.05;
    opacity = _random.nextDouble() * 0.5 + 0.5;
  }
  void update() {
    // 添加延迟效果
    if (delay > 0) {
      delay -= 0.1;
      return;
    }

    // 更新位置（从右上角向左下角移动）
    y += speedY;
    x -= speedX;

    // 更新旋转
    rotation += rotationSpeed;

    // 当樱花超出屏幕时重置
    if (y > 1.1 || x < -0.1) {
      reset();
    }
  }

  void reset() {
    // 从右上角重新开始
    x = 1.0 + _random.nextDouble() * 0.2;
    y = -0.1;
    speedY = _random.nextDouble() * 0.005 + 0.002;
    speedX = _random.nextDouble() * 0.002 + 0.001;
    rotationSpeed = _random.nextDouble() * 0.05 - 0.025;
    opacity = _random.nextDouble() * 0.5 + 0.5;
  }
}