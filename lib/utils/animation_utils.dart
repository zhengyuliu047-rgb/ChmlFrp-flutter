import 'package:flutter/material.dart';

/// 动画工具类，提供各种通用动画效果
class AnimationUtils {
  /// 创建一个淡入动画
  static Animation<double> createFadeAnimation(AnimationController controller, {double begin = 0.0, double end = 1.0}) {
    return Tween<double>(begin: begin, end: end).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  /// 创建一个缩放动画
  static Animation<double> createScaleAnimation(AnimationController controller, {double begin = 0.9, double end = 1.0}) {
    return Tween<double>(begin: begin, end: end).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.easeOut,
      ),
    );
  }

  /// 创建一个滑动动画
  static Animation<Offset> createSlideAnimation(AnimationController controller, {Offset begin = const Offset(0, 0.1), Offset end = Offset.zero}) {
    return Tween<Offset>(begin: begin, end: end).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.easeOut,
      ),
    );
  }

  /// 创建一个旋转动画
  static Animation<double> createRotateAnimation(AnimationController controller, {double begin = 0.0, double end = 1.0}) {
    return Tween<double>(begin: begin, end: end).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOut,
      ),
    );
  }
}

/// 一个带动画效果的按钮组件
class AnimatedButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? borderRadius;
  final EdgeInsets? padding;

  const AnimatedButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.borderRadius,
    this.padding,
  });

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = AnimationUtils.createScaleAnimation(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          _isPressed = true;
          _animationController.forward();
        });
      },
      onTapUp: (_) {
        setState(() {
          _isPressed = false;
          _animationController.reverse();
          widget.onPressed();
        });
      },
      onTapCancel: () {
        setState(() {
          _isPressed = false;
          _animationController.reverse();
        });
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(widget.borderRadius ?? 8),
          ),
          padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: widget.child,
        ),
      ),
    );
  }
}

/// 一个带动画效果的卡片组件
class AnimatedCard extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final Border? border;
  final List<BoxShadow>? boxShadow;

  const AnimatedCard({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.padding,
    this.borderRadius,
    this.backgroundColor,
    this.border,
    this.boxShadow,
  });

  @override
  State<AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<AnimatedCard> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _scaleAnimation = AnimationUtils.createScaleAnimation(_animationController, begin: 0.95, end: 1.0);
    _fadeAnimation = AnimationUtils.createFadeAnimation(_animationController, begin: 0.8, end: 1.0);
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: widget.borderRadius,
            border: widget.border,
            boxShadow: widget.boxShadow,
          ),
          padding: widget.padding,
          child: widget.child,
        ),
      ),
    );
  }
}

/// 页面切换动画
class PageTransition extends PageRouteBuilder {
  final Widget child;
  final Duration duration;
  final Curve curve;

  PageTransition({
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
  }) : super(
          transitionDuration: duration,
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.1, 0);
            const end = Offset.zero;
            final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            final slideAnimation = animation.drive(tween);
            final fadeAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(animation);

            return SlideTransition(
              position: slideAnimation,
              child: FadeTransition(
                opacity: fadeAnimation,
                child: child,
              ),
            );
          },
        );
}

/// 一个带动画效果的列表项组件
class AnimatedListItem extends StatefulWidget {
  final Widget child;
  final int index;
  final Duration duration;

  const AnimatedListItem({
    super.key,
    required this.child,
    required this.index,
    this.duration = const Duration(milliseconds: 300),
  });

  @override
  State<AnimatedListItem> createState() => _AnimatedListItemState();
}

class _AnimatedListItemState extends State<AnimatedListItem> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    // 根据索引延迟动画，创建 staggered 效果
    Future.delayed(Duration(milliseconds: widget.index * 50), () {
      _animationController.forward();
    });
    _fadeAnimation = AnimationUtils.createFadeAnimation(_animationController, begin: 0.0, end: 1.0);
    _slideAnimation = AnimationUtils.createSlideAnimation(_animationController, begin: const Offset(0, 0.2), end: Offset.zero);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
}