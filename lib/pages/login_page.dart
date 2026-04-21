import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/cherry_blossom_particle.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  final _tokenController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';
  bool _obscureText = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );
    _scaleAnimation = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
      ),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _tokenController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    String statusMessage = '';
    bool success = false;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final token = _tokenController.text.trim();
    if (token.isEmpty) {
      statusMessage = '请输入 Token';
    } else {
      success = await ApiService.loginWithToken(token);
      if (!success) {
        statusMessage = 'Token 无效或已过期';
      }
    }

    setState(() {
      _isLoading = false;
      if (!success) {
        _errorMessage = statusMessage;
      }
    });

    if (success && mounted) {
      Navigator.pushReplacementNamed(context, '/main');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 动态背景渐变
          _AnimatedGradientBackground(),
          // 樱花粒子效果
          const CherryBlossomParticle(),
          // 登录表单
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: _LoginCard(
                    tokenController: _tokenController,
                    isLoading: _isLoading,
                    errorMessage: _errorMessage,
                    obscureText: _obscureText,
                    onToggleObscure: () => setState(() => _obscureText = !_obscureText),
                    onLogin: _handleLogin,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 动态渐变背景
class _AnimatedGradientBackground extends StatefulWidget {
  @override
  State<_AnimatedGradientBackground> createState() => _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState extends State<_AnimatedGradientBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat(reverse: true);
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
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.lerp(
                Alignment.topLeft,
                Alignment.topRight,
                _controller.value,
              )!,
              end: Alignment.lerp(
                Alignment.bottomRight,
                Alignment.bottomLeft,
                _controller.value,
              )!,
              colors: const [
                Color(0xFFF8FAFC),
                Color(0xFFEDE9FE),
                Color(0xFFFCE7F3),
                Color(0xFFF8FAFC),
              ],
              stops: [0.0, 0.3, 0.7, 1.0],
            ),
          ),
        );
      },
    );
  }
}

// 登录卡片 - 玻璃态设计
class _LoginCard extends StatelessWidget {
  final TextEditingController tokenController;
  final bool isLoading;
  final String errorMessage;
  final bool obscureText;
  final VoidCallback onToggleObscure;
  final VoidCallback onLogin;

  const _LoginCard({
    required this.tokenController,
    required this.isLoading,
    required this.errorMessage,
    required this.obscureText,
    required this.onToggleObscure,
    required this.onLogin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 420),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.1),
            offset: const Offset(0, 20),
            blurRadius: 60,
          ),
          BoxShadow(
            color: AppTheme.secondaryColor.withOpacity(0.05),
            offset: const Offset(0, 10),
            blurRadius: 30,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.9),
                Colors.white.withOpacity(0.7),
              ],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Logo 区域
              _LogoSection(),
              const SizedBox(height: 32),
              // 错误提示
              if (errorMessage.isNotEmpty) ...[
                _ErrorBanner(message: errorMessage),
                const SizedBox(height: 24),
              ],
              // Token 输入框
              _TokenInput(
                controller: tokenController,
                obscureText: obscureText,
                onToggleObscure: onToggleObscure,
                onSubmit: onLogin,
              ),
              const SizedBox(height: 28),
              // 登录按钮
              _LoginButton(
                isLoading: isLoading,
                onPressed: onLogin,
              ),
              const SizedBox(height: 24),
              // 底部信息
              _FooterInfo(),
            ],
          ),
        ),
      ),
    );
  }
}

// Logo 区域
class _LogoSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Logo 图标
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withOpacity(0.4),
                offset: const Offset(0, 8),
                blurRadius: 24,
              ),
            ],
          ),
          child: const Icon(
            Icons.rocket_launch_rounded,
            color: Colors.white,
            size: 40,
          ),
        ),
        const SizedBox(height: 20),
        // 标题
        ShaderMask(
          shaderCallback: (bounds) => AppTheme.primaryGradient.createShader(bounds),
          child: const Text(
            'ChmlFrp',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -1,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Flutter 客户端',
          style: TextStyle(
            fontSize: 15,
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.w500,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}

// 错误提示横幅
class _ErrorBanner extends StatelessWidget {
  final String message;

  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.errorColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.errorColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppTheme.errorColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.error_outline_rounded,
              color: AppTheme.errorColor,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: AppTheme.errorColor,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Token 输入框
class _TokenInput extends StatelessWidget {
  final TextEditingController controller;
  final bool obscureText;
  final VoidCallback onToggleObscure;
  final VoidCallback onSubmit;

  const _TokenInput({
    required this.controller,
    required this.obscureText,
    required this.onToggleObscure,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '访问令牌',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppTheme.textSecondary,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.surfaceVariant,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.borderColor, width: 1),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: '请输入您的访问令牌',
              hintStyle: TextStyle(color: AppTheme.textTertiary),
              prefixIcon: Container(
                width: 48,
                alignment: Alignment.center,
                child: ShaderMask(
                  shaderCallback: (bounds) => AppTheme.primaryGradient.createShader(bounds),
                  child: const Icon(
                    Icons.key_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  obscureText ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                  color: AppTheme.textTertiary,
                  size: 20,
                ),
                onPressed: onToggleObscure,
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            onSubmitted: (_) => onSubmit(),
            textInputAction: TextInputAction.done,
          ),
        ),
      ],
    );
  }
}

// 登录按钮
class _LoginButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const _LoginButton({required this.isLoading, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: Container(
        decoration: BoxDecoration(
          gradient: isLoading ? null : AppTheme.primaryGradient,
          color: isLoading ? AppTheme.primaryColor.withOpacity(0.7) : null,
          borderRadius: BorderRadius.circular(14),
          boxShadow: isLoading
              ? null
              : [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.35),
                    offset: const Offset(0, 8),
                    blurRadius: 20,
                  ),
                ],
        ),
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.login_rounded, size: 20),
                    SizedBox(width: 8),
                    Text(
                      '登录',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

// 底部信息
class _FooterInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.shield_outlined, size: 14, color: AppTheme.textTertiary),
        const SizedBox(width: 6),
        Text(
          '令牌仅存储在本地',
          style: TextStyle(
            fontSize: 12,
            color: AppTheme.textTertiary,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
