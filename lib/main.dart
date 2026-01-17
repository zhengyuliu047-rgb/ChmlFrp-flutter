import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './pages/login_page.dart';
import './pages/main_page.dart';
import './services/api_service.dart';
import './services/frpc_service.dart';
import './theme/app_theme.dart';

void main() async {
  // 初始化日志系统
  await FrpcService.initializeLogs();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ChmlFrp Flutter',
      theme: AppTheme.lightTheme,
      home: const AppLoader(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/main': (context) => const MainPage(),
      },
    );
  }
}

// 应用加载器，检查是否已登录
class AppLoader extends StatefulWidget {
  const AppLoader({super.key});

  @override
  State<AppLoader> createState() => _AppLoaderState();
}

class _AppLoaderState extends State<AppLoader> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  // 检查登录状态
  Future<void> _checkLoginStatus() async {
    final isLoggedIn = await ApiService.init();
    if (mounted) {
      Navigator.pushReplacementNamed(
        context,
        isLoggedIn ? '/main' : '/login',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
