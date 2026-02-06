import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import 'package:system_tray/system_tray.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'dart:ui';
import './pages/login_page.dart';
import './pages/main_page.dart';
import './services/api_service.dart';
import './services/frpc_service.dart';
import './theme/app_theme.dart';

final SystemTray systemTray = SystemTray();

void main() async {
  // 初始化日志系统
  await FrpcService.initializeLogs();
  
  // 启动时先杀死所有frpc进程，防止冲突
  await FrpcService.stopAllFrpcProcesses();
  
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
    // 设置阻止窗口关闭
    await windowManager.setPreventClose(true);
  });

  // 初始化系统托盘
  await initSystemTray();
  
  runApp(const MyApp());
}

// 初始化系统托盘
Future<void> initSystemTray() async {
  try {
    // 初始化系统托盘
    await systemTray.initSystemTray(
      iconPath: Platform.isWindows ? 'assets/images/app_icon.ico' : 'assets/images/app_icon.png',
      toolTip: 'ChmlFrp',
    );

    // 创建菜单
    final Menu menu = Menu();
    await menu.buildFrom([
      MenuItemLabel(
        label: '打开主界面',
        onClicked: (menuItem) => windowManager.show()
      ),
      MenuItemLabel(label: '退出', onClicked: (menuItem) async {
        // 退出前先杀死所有frpc进程
        await FrpcService.stopAllFrpcProcesses();
        // 取消阻止关闭，然后真正退出应用
        await windowManager.setPreventClose(false);
        // 直接退出应用
        exit(0);
      }),
    ]);
    await systemTray.setContextMenu(menu);

    // 注册事件处理器
    systemTray.registerSystemTrayEventHandler((eventName) {
      if (eventName == kSystemTrayEventClick) {
        Platform.isWindows ? windowManager.show() : systemTray.popUpContextMenu();
      } else if (eventName == kSystemTrayEventRightClick) {
        Platform.isWindows ? systemTray.popUpContextMenu() : windowManager.show();
      }
    });
  } catch (e) {
    if (kDebugMode) {
      print('系统托盘初始化失败: e');
    }
  }
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
    // 处理窗口关闭事件，最小化到系统托盘而不是退出
    await windowManager.hide();
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
