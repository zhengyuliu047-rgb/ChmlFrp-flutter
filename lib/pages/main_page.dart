import 'package:flutter/material.dart';
import 'package:flutter/animation.dart';
import '../pages/dashboard_page.dart';
import '../pages/tunnel_list_page.dart';
import '../pages/node_list_page.dart';
import '../pages/settings_page.dart';
import '../pages/logs_page.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  bool _isSidebarExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // 侧边栏菜单项
  final List<Widget> _pages = [
    const DashboardPage(),
    const TunnelListPage(),
    const NodeListPage(),
    Container(),
    const SettingsPage(),
  ];

  // 侧边栏菜单数据
  static const List<Map<String, dynamic>> _menuItems = [
    {
      'title': '仪表盘',
      'icon': Icons.dashboard,
    },
    {
      'title': '隧道管理',
      'icon': Icons.cloud,
    },
    {
      'title': '节点列表',
      'icon': Icons.dns,
    },
    {
      'title': '日志管理',
      'icon': Icons.article,
    },
    {
      'title': '设置',
      'icon': Icons.settings,
    },
  ];

  @override
  void initState() {
    super.initState();
    // 初始化动画控制器
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300), // 缩短动画持续时间
      vsync: this,
    );
    // 初始化动画
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0.1, 0), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    // 刷新用户信息以获取最新头像
    _refreshUserInfo();
    // 启动动画
    _animationController.forward();
  }

  // 刷新用户信息
  Future<void> _refreshUserInfo() async {
    await ApiService.refreshUserInfo();
    // userInfo 是从 ApiService 全局获取的，不需要 setState
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // 侧边栏
          SidebarWidget(
            isExpanded: _isSidebarExpanded,
            selectedIndex: _selectedIndex,
            menuItems: _menuItems,
            onMenuItemTap: (index) {
              setState(() {
                _selectedIndex = index;
                // 如果用户点击了日志页面，创建LogsPage实例
                if (index == 3 && _pages[index] is Container) {
                  _pages[index] = const LogsPage();
                }
                // 启动页面切换动画
                _animationController.reset();
                _animationController.forward();
              });
            },
            onToggleExpanded: () {
              setState(() {
                _isSidebarExpanded = !_isSidebarExpanded;
              });
            },
            onLogout: _handleLogout,
          ),
          // 主内容区
          Expanded(
            child: Scaffold(
              appBar: AppBar(
                title: Text(_menuItems[_selectedIndex]['title']),
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
                shadowColor: Colors.transparent,
                actions: [],
              ),
              body: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: _pages[_selectedIndex],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 处理登出
  Future<void> _handleLogout() async {
    await ApiService.logout();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }
}

// 侧边栏组件
class SidebarWidget extends StatelessWidget {
  final bool isExpanded;
  final int selectedIndex;
  final List<Map<String, dynamic>> menuItems;
  final ValueChanged<int> onMenuItemTap;
  final VoidCallback onToggleExpanded;
  final VoidCallback onLogout;

  const SidebarWidget({
    super.key,
    required this.isExpanded,
    required this.selectedIndex,
    required this.menuItems,
    required this.onMenuItemTap,
    required this.onToggleExpanded,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: isExpanded ? 220 : 70,
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        border: Border(right: BorderSide(color: AppTheme.borderColor)),
        boxShadow: [
          AppTheme.shadowMedium,
        ],
      ),
      child: Column(
        children: [
          // 侧边栏头部
          GestureDetector(
            onTap: onToggleExpanded,
            child: Container(
              height: 70,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  if (isExpanded)
                    Expanded(
                      child: Text(
                        'ChmlFrp',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  Icon(
                    isExpanded ? Icons.chevron_left : Icons.chevron_right,
                    color: AppTheme.textSecondary,
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1, color: AppTheme.borderColor),
          const SizedBox(height: 12),
          // 菜单项列表
          Expanded(
            child: ListView.builder(
              itemCount: menuItems.length,
              itemBuilder: (context, index) {
                final item = menuItems[index];
                return MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () => onMenuItemTap(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: selectedIndex == index 
                            ? AppTheme.primaryColor.withOpacity(0.1) 
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                        border: selectedIndex == index 
                            ? Border.all(color: AppTheme.primaryColor, width: 1) 
                            : null,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          children: [
                            Icon(
                              item['icon'],
                              size: 22,
                              color: selectedIndex == index 
                                  ? AppTheme.primaryColor 
                                  : AppTheme.textSecondary,
                            ),
                            if (isExpanded)
                              Padding(
                                padding: const EdgeInsets.only(left: 12),
                                child: Text(
                                  item['title'],
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: selectedIndex == index 
                                        ? FontWeight.bold 
                                        : FontWeight.normal,
                                    color: selectedIndex == index 
                                        ? AppTheme.primaryColor 
                                        : AppTheme.textPrimary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // 底部登出按钮
          const Divider(height: 1, color: AppTheme.borderColor),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: onLogout,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                decoration: BoxDecoration(
                  color: AppTheme.errorColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                  border: Border.all(color: AppTheme.errorColor.withOpacity(0.2)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    children: [
                      Icon(Icons.logout, size: 22, color: AppTheme.errorColor),
                      if (isExpanded)
                        Padding(
                          padding: const EdgeInsets.only(left: 12),
                          child: Text(
                            '登出',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.normal,
                              color: AppTheme.errorColor,
                            ),
                          ),
                        ),
                    ],
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
