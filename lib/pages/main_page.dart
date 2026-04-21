import 'package:flutter/material.dart';
import 'package:flutter/animation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../pages/dashboard_page.dart';
import '../pages/tunnel_list_page.dart';
import '../pages/node_list_page.dart';
import '../pages/settings_page.dart';
import '../pages/logs_page.dart';
import '../services/api_service.dart';
import '../services/frpc_service.dart';
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

  // 侧边栏菜单数据 - 带渐变色图标
  static const List<Map<String, dynamic>> _menuItems = [
    {
      'title': '仪表盘',
      'icon': Icons.dashboard_rounded,
      'gradientColors': [Color(0xFF6366F1), Color(0xFF8B5CF6)],
    },
    {
      'title': '隧道管理',
      'icon': Icons.route_rounded,
      'gradientColors': [Color(0xFF10B981), Color(0xFF34D399)],
    },
    {
      'title': '节点列表',
      'icon': Icons.dns_rounded,
      'gradientColors': [Color(0xFF3B82F6), Color(0xFF60A5FA)],
    },
    {
      'title': '日志管理',
      'icon': Icons.article_rounded,
      'gradientColors': [Color(0xFFF59E0B), Color(0xFFFBBF24)],
    },
    {
      'title': '设置',
      'icon': Icons.settings_rounded,
      'gradientColors': [Color(0xFFEC4899), Color(0xFFF472B6)],
    },
  ];

  @override
  void initState() {
    super.initState();
    // 初始化动画控制器
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    // 初始化动画
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0.05, 0), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );
    // 刷新用户信息
    _refreshUserInfo();
    // 自动启动隧道
    _autoStartTunnels();
    // 启动动画
    _animationController.forward();
  }

  Future<void> _refreshUserInfo() async {
    await ApiService.refreshUserInfo();
  }
  
  Future<void> _autoStartTunnels() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final autoStartEnabled = prefs.getBool('autoStartTunnel') ?? false;
      
      if (autoStartEnabled) {
        final tunnelIds = prefs.getStringList('autoStartTunnelIds') ?? [];
        
        if (tunnelIds.isNotEmpty) {
          final allTunnels = await ApiService.getTunnelList();
          
          for (final tunnelIdStr in tunnelIds) {
            final tunnelId = int.tryParse(tunnelIdStr);
            if (tunnelId != null) {
              final tunnelExists = allTunnels.any((tunnel) => tunnel.id == tunnelId);
              if (tunnelExists) {
                await FrpcService.startTunnel(tunnelId, null);
              }
            }
          }
        }
      }
    } catch (e) {
      debugPrint('自动启动隧道失败: $e');
    }
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
                if (index == 3 && _pages[index] is Container) {
                  _pages[index] = const LogsPage();
                }
                _animationController.reset();
                _animationController.forward();
              });
            },
            onToggleExpanded: () {
              setState(() {
                _isSidebarExpanded = !_isSidebarExpanded;
              });
            },
          ),
          // 主内容区
          Expanded(
            child: Scaffold(
              appBar: AppBar(
                title: Row(
                  children: [
                    // Logo 图标
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.rocket_launch, color: Colors.white, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _menuItems[_selectedIndex]['title'],
                      style: const TextStyle(
                        fontFamily: "HarmonyOS Sans",
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                flexibleSpace: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceColor,
                    border: Border(
                      bottom: BorderSide(color: AppTheme.borderColor, width: 1),
                    ),
                  ),
                ),
                backgroundColor: AppTheme.surfaceColor,
                foregroundColor: AppTheme.textPrimary,
                elevation: 0,
                shadowColor: Colors.transparent,
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
}

// ================================================================
// 侧边栏组件 - 全新设计的视觉风格
// ================================================================
class SidebarWidget extends StatelessWidget {
  final bool isExpanded;
  final int selectedIndex;
  final List<Map<String, dynamic>> menuItems;
  final ValueChanged<int> onMenuItemTap;
  final VoidCallback onToggleExpanded;

  const SidebarWidget({
    super.key,
    required this.isExpanded,
    required this.selectedIndex,
    required this.menuItems,
    required this.onMenuItemTap,
    required this.onToggleExpanded,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: isExpanded ? 240 : 80,
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        border: Border(
          right: BorderSide(color: AppTheme.borderColor, width: 1),
        ),
        boxShadow: [
          AppTheme.shadowSm,
        ],
      ),
      child: Column(
        children: [
          // 侧边栏头部
          _SidebarHeader(
            isExpanded: isExpanded,
            onToggle: onToggleExpanded,
          ),
          Divider(height: 1, color: AppTheme.borderColor),
          const SizedBox(height: 12),
          // 菜单项列表
          Expanded(
            child: ListView.builder(
              itemCount: menuItems.length,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemBuilder: (context, index) {
                final item = menuItems[index];
                return _SidebarMenuItem(
                  icon: item['icon'],
                  title: item['title'],
                  gradientColors: item['gradientColors'],
                  isExpanded: isExpanded,
                  isSelected: selectedIndex == index,
                  onTap: () => onMenuItemTap(index),
                );
              },
            ),
          ),
          // 底部用户信息
          _SidebarFooter(isExpanded: isExpanded),
        ],
      ),
    );
  }
}

// 侧边栏头部
class _SidebarHeader extends StatelessWidget {
  final bool isExpanded;
  final VoidCallback onToggle;

  const _SidebarHeader({required this.isExpanded, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        height: 72,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            // Logo
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                    offset: const Offset(0, 4),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: const Icon(Icons.rocket_launch, color: Colors.white, size: 22),
            ),
            if (isExpanded) ...[
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) => AppTheme.primaryGradient.createShader(bounds),
                      child: const Text(
                        'ChmlFrp',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    const Text(
                      '反向代理管理',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.textTertiary,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            AnimatedRotation(
              turns: isExpanded ? 0 : 0.5,
              duration: const Duration(milliseconds: 300),
              child: Icon(
                Icons.keyboard_arrow_left_rounded,
                color: AppTheme.textSecondary,
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 侧边栏菜单项
class _SidebarMenuItem extends StatefulWidget {
  final IconData icon;
  final String title;
  final List<Color> gradientColors;
  final bool isExpanded;
  final bool isSelected;
  final VoidCallback onTap;

  const _SidebarMenuItem({
    required this.icon,
    required this.title,
    required this.gradientColors,
    required this.isExpanded,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_SidebarMenuItem> createState() => _SidebarMenuItemState();
}

class _SidebarMenuItemState extends State<_SidebarMenuItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: EdgeInsets.symmetric(
            horizontal: widget.isExpanded ? 14 : 0,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? widget.gradientColors[0].withOpacity(0.12)
                : _isHovered
                    ? AppTheme.surfaceVariant
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: widget.isSelected
                ? Border.all(color: widget.gradientColors[0].withOpacity(0.3), width: 1)
                : null,
          ),
          child: widget.isExpanded
              ? Row(
                  children: [
                    _IconContainer(
                      icon: widget.icon,
                      gradientColors: widget.gradientColors,
                      isSelected: widget.isSelected,
                      isHovered: _isHovered,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: widget.isSelected
                              ? widget.gradientColors[0]
                              : AppTheme.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (widget.isSelected)
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: widget.gradientColors,
                          ),
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                )
              : Center(
                  child: _IconContainer(
                    icon: widget.icon,
                    gradientColors: widget.gradientColors,
                    isSelected: widget.isSelected,
                    isHovered: _isHovered,
                    showBadge: true,
                  ),
                ),
        ),
      ),
    );
  }
}

// 图标容器
class _IconContainer extends StatelessWidget {
  final IconData icon;
  final List<Color> gradientColors;
  final bool isSelected;
  final bool isHovered;
  final bool showBadge;

  const _IconContainer({
    required this.icon,
    required this.gradientColors,
    required this.isSelected,
    required this.isHovered,
    this.showBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isSelected || isHovered) {
      return Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: gradientColors[0].withOpacity(0.3),
              offset: const Offset(0, 2),
              blurRadius: 6,
            ),
          ],
        ),
        child: Icon(icon, size: 20, color: Colors.white),
      );
    }

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: AppTheme.surfaceVariant,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, size: 20, color: AppTheme.textSecondary),
    );
  }
}

// 侧边栏底部
class _SidebarFooter extends StatelessWidget {
  final bool isExpanded;

  const _SidebarFooter({required this.isExpanded});

  @override
  Widget build(BuildContext context) {
    final userInfo = ApiService.userInfo;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceVariant.withOpacity(0.5),
        border: Border(
          top: BorderSide(color: AppTheme.borderColor, width: 1),
        ),
      ),
      child: Row(
        children: [
          // 用户头像
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withOpacity(0.3),
                  offset: const Offset(0, 2),
                  blurRadius: 6,
                ),
              ],
            ),
            child: userInfo?.userimg.isNotEmpty == true
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      userInfo!.userimg,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Center(
                        child: Text(
                          userInfo.username.isNotEmpty
                              ? userInfo.username[0].toUpperCase()
                              : 'U',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  )
                : Center(
                    child: Text(
                      userInfo?.username.isNotEmpty == true
                          ? userInfo!.username[0].toUpperCase()
                          : 'U',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
          ),
          if (isExpanded) ...[
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    userInfo?.username ?? '用户',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    userInfo?.usergroup ?? '游客',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.textTertiary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
