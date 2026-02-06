import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import './pages/login_page.dart';
import './pages/main_page.dart';
import './services/api_service.dart';
import './services/frpc_service.dart';
import './theme/app_theme.dart';

void main() async {
  // 初始化日志系统
  await FrpcService.initializeLogs();
  
  // 确保插件初始化
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化窗口管理器
  await windowManager.ensureInitialized();
  
  // 配置窗口属性
  WindowOptions windowOptions = const WindowOptions(
    size: Size(1200, 800),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.normal,
  );
  
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });
  
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WindowListener {
  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  void onWindowEvent(String eventName) {
    // 处理窗口事件
    debugPrint('Window event: $eventName');
  }

  @override
  void onWindowClose() async {
    // 处理窗口关闭事件
    bool isPreventClose = await windowManager.isPreventClose();
    if (isPreventClose) {
    
    }
  }

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
