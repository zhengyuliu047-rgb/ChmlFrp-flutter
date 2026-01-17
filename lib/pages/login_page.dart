import 'package:flutter/material.dart';
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
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    // 初始化动画控制器 - 减少动画持续时间以提高性能
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    // 初始化动画
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    // 启动动画
    _animationController.forward();
  }

  @override
  void dispose() {
    _tokenController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // 处理登录
  Future<void> _handleLogin() async {
    String statusMessage = '';
    bool success = false;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    // 使用Token登录
    final token = _tokenController.text.trim();
    if (token.isEmpty) {
      statusMessage = '请输入Token';
    } else {
      success = await ApiService.loginWithToken(token);
      if (!success) {
        statusMessage = 'Token无效或已过期';
      }
    }

    setState(() {
      _isLoading = false;
      if (!success) {
        _errorMessage = statusMessage;
        // 添加错误信息动画
        _animationController.reset();
        _animationController.forward();
      }
    });

    if (success && mounted) {
      // 添加页面切换动画
      Navigator.pushReplacementNamed(context, '/main');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 樱花粒子效果背景
          const CherryBlossomParticle(),
          // 原有的渐变背景和登录表单
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.primaryColor.withOpacity(0.05),
                  AppTheme.secondaryColor.withOpacity(0.05),
                ],
              ),
            ),
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: SlideTransition(
                      position: Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
                        CurvedAnimation(
                          parent: _animationController,
                          curve: Curves.easeOut,
                        ),
                      ),
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 480),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceColor,
                          borderRadius: BorderRadius.circular(AppTheme.borderRadiusXLarge),
                          boxShadow: [
                            AppTheme.shadowLarge,
                          ],
                        ),
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Logo和标题
                            const SizedBox(height: 16),
                            Center(
                              child: Text(
                                'ChmlFrp',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Center(
                              child: Text(
                                'Flutter 客户端',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 18,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ),
                            const SizedBox(height: 48),

                            // 错误信息
                            if (_errorMessage.isNotEmpty)
                              FadeTransition(
                                opacity: _fadeAnimation,
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  margin: const EdgeInsets.only(bottom: 16),
                                  decoration: BoxDecoration(
                                    color: AppTheme.errorColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                                    border: Border.all(color: AppTheme.errorColor.withOpacity(0.3)),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.error_outline, color: AppTheme.errorColor, size: 20),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          _errorMessage,
                                          style: TextStyle(color: AppTheme.errorColor),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                            // Token登录表单
                            FadeTransition(
                              opacity: _fadeAnimation,
                              child: TextField(
                                controller: _tokenController,
                                decoration: InputDecoration(
                                  labelText: 'Token',
                                  hintText: '请输入您的Token',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                                    borderSide: BorderSide(color: AppTheme.borderColor),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                                    borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
                                  ),
                                  prefixIcon: Icon(Icons.vpn_key, color: AppTheme.primaryColor),
                                  labelStyle: TextStyle(color: AppTheme.textSecondary),
                                  filled: true,
                                  fillColor: AppTheme.surfaceColor,
                                ),
                                onSubmitted: (_) => _handleLogin(),
                                textInputAction: TextInputAction.done,
                              ),
                            ),
                            const SizedBox(height: 32),

                            // 登录按钮
                            FadeTransition(
                              opacity: _fadeAnimation,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _handleLogin,
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                                  ),
                                  backgroundColor: AppTheme.primaryColor,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shadowColor: Colors.transparent,
                                  animationDuration: const Duration(milliseconds: 300),
                                  disabledBackgroundColor: AppTheme.primaryColor.withOpacity(0.6),
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Text(
                                        '登录',
                                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
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
