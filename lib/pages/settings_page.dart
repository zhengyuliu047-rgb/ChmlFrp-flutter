import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:launch_at_startup/launch_at_startup.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../services/frpc_service.dart';
import '../theme/app_theme.dart';
import '../utils/animation_utils.dart';
import '../widgets/about_dialog.dart';
import '../models/models.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _launchAtStartup = false;
  bool _isLoading = false;
  bool _autoStartTunnel = false;
  List<String> _autoStartTunnelIds = [];
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = AnimationUtils.createFadeAnimation(_animationController);
    _animationController.forward();
    _initializeLaunchAtStartup();
    _initializeAutoStartTunnel();
  }
  
  Future<void> _initializeLaunchAtStartup() async {
    try {
      launchAtStartup.setup(
        appName: 'ChmlFrp',
        appPath: Platform.resolvedExecutable,
      );
      final isEnabled = await launchAtStartup.isEnabled();
      setState(() => _launchAtStartup = isEnabled);
    } catch (e) {
      debugPrint('初始化开机自启设置失败: $e');
    }
  }
  
  Future<void> _toggleLaunchAtStartup(bool value) async {
    setState(() => _isLoading = true);
    try {
      if (value) {
        await launchAtStartup.enable();
      } else {
        await launchAtStartup.disable();
      }
      setState(() => _launchAtStartup = value);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('launchAtStartup', value);
    } catch (e) {
      debugPrint('切换开机自启状态失败: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  Future<void> _initializeAutoStartTunnel() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _autoStartTunnel = prefs.getBool('autoStartTunnel') ?? false;
        _autoStartTunnelIds = prefs.getStringList('autoStartTunnelIds') ?? [];
      });
    } catch (e) {
      debugPrint('初始化自动启动隧道设置失败: $e');
    }
  }
  
  Future<void> _toggleAutoStartTunnel(bool value) async {
    setState(() => _autoStartTunnel = value);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('autoStartTunnel', value);
    } catch (e) {
      debugPrint('切换自动启动隧道状态失败: $e');
    }
  }

  void _configureAutoStartTunnel() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('配置自动启动隧道', style: TextStyle(fontFamily: "HarmonyOS Sans", fontWeight: FontWeight.w700)),
        content: FutureBuilder<List<TunnelInfo>>(
          future: ApiService.getTunnelList(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Text('获取隧道列表失败: ${snapshot.error}', style: TextStyle(fontFamily: "HarmonyOS Sans"));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Text('未获取到隧道列表', style: TextStyle(fontFamily: "HarmonyOS Sans"));
            } else {
              final tunnels = snapshot.data!;
              return StatefulBuilder(
                builder: (context, setDialogState) {
                  return SizedBox(
                    width: 400,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: tunnels.length,
                      itemBuilder: (context, index) {
                        final tunnel = tunnels[index];
                        final isSelected = _autoStartTunnelIds.contains(tunnel.id.toString());
                        return _TunnelCheckbox(
                          name: tunnel.name,
                          subtitle: '${tunnel.type} | ${tunnel.node}',
                          isSelected: isSelected,
                          onChanged: (value) {
                            setDialogState(() {
                              if (value == true) {
                                _autoStartTunnelIds.add(tunnel.id.toString());
                              } else {
                                _autoStartTunnelIds.remove(tunnel.id.toString());
                              }
                            });
                          },
                        );
                      },
                    ),
                  );
                },
              );
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消', style: TextStyle(fontFamily: "HarmonyOS Sans")),
          ),
          TextButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setStringList('autoStartTunnelIds', _autoStartTunnelIds);
              Navigator.pop(context);
            },
            child: const Text('保存', style: TextStyle(fontFamily: "HarmonyOS Sans")),
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleLogout() async {
    await ApiService.logout();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }
  
  Future<void> _killAllFrpcProcesses() async {
    try {
      setState(() => _isLoading = true);
      await FrpcService.stopAllFrpcProcesses();
      if (mounted) {
        _showSnackBar('已成功杀死所有 frpc 进程', AppTheme.successColor);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('杀死 frpc 进程失败: $e', AppTheme.errorColor);
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontFamily: "HarmonyOS Sans")),
        backgroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ListView(
            children: [
              // 系统设置卡片
              _SettingsCard(
                gradientColors: const [Color(0xFFEC4899), Color(0xFFF472B6)],
                icon: Icons.computer_rounded,
                title: '系统设置',
                child: Column(
                  children: [
                    _SettingsTile(
                      icon: Icons.power_settings_new_rounded,
                      iconColor: AppTheme.accentColor,
                      title: '开机自启',
                      subtitle: '应用将在系统启动时自动运行',
                      trailing: _isLoading
                          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                          : Switch(
                              value: _launchAtStartup,
                              onChanged: _toggleLaunchAtStartup,
                              activeColor: AppTheme.primaryColor,
                            ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 自动启动隧道卡片
              _SettingsCard(
                gradientColors: const [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                icon: Icons.link_rounded,
                title: '自动启动隧道',
                child: Column(
                  children: [
                    _SettingsTile(
                      icon: Icons.play_circle_outline_rounded,
                      iconColor: AppTheme.primaryColor,
                      title: '启用自动启动隧道',
                      subtitle: '程序启动时自动启动选定的隧道',
                      trailing: Switch(
                        value: _autoStartTunnel,
                        onChanged: _toggleAutoStartTunnel,
                        activeColor: AppTheme.primaryColor,
                      ),
                    ),
                    const Divider(height: 1, color: AppTheme.borderColor),
                    _SettingsTile(
                      icon: Icons.tune_rounded,
                      iconColor: AppTheme.secondaryColor,
                      title: '配置自动启动的隧道',
                      subtitle: _autoStartTunnelIds.isEmpty ? '未配置任何隧道' : '已配置 ${_autoStartTunnelIds.length} 个隧道',
                      trailing: Container(
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _configureAutoStartTunnel,
                            borderRadius: BorderRadius.circular(10),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: Text(
                                '配置',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 其他设置卡片
              _SettingsCard(
                gradientColors: const [Color(0xFF10B981), Color(0xFF34D399)],
                icon: Icons.settings_rounded,
                title: '其他设置',
                child: Column(
                  children: [
                    _SettingsTile(
                      icon: Icons.warning_amber_rounded,
                      iconColor: AppTheme.errorColor,
                      title: '杀死所有 frpc 进程',
                      titleStyle: const TextStyle(color: AppTheme.errorColor, fontWeight: FontWeight.w700),
                      subtitleStyle: const TextStyle(color: AppTheme.errorColor, fontSize: 12),
                      subtitle: '当 frpc 启动出现问题时使用',
                      onTap: () => _showKillConfirmDialog(),
                    ),
                    const Divider(height: 1, color: AppTheme.borderColor),
                    _SettingsTile(
                      icon: Icons.info_outline_rounded,
                      iconColor: AppTheme.infoColor,
                      title: '关于',
                      subtitle: 'ChmlFrp Flutter 客户端 v1.4.1',
                      showArrow: true,
                      onTap: () => _showAboutDialog(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // 登出按钮
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.errorColor, AppTheme.errorLight],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.errorColor.withOpacity(0.3),
                      offset: const Offset(0, 4),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _handleLogout,
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.logout_rounded, color: Colors.white, size: 20),
                          SizedBox(width: 8),
                          Text(
                            '登出账户',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  void _showKillConfirmDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认操作', style: TextStyle(fontFamily: "HarmonyOS Sans", fontWeight: FontWeight.w700)),
        content: const Text('确定要杀死所有 frpc 进程吗？这将停止所有正在运行的隧道。', style: TextStyle(fontFamily: "HarmonyOS Sans")),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消', style: TextStyle(fontFamily: "HarmonyOS Sans")),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _killAllFrpcProcesses();
            },
            child: Text('确认', style: TextStyle(fontFamily: "HarmonyOS Sans", color: AppTheme.errorColor)),
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Logo
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(0.3),
                      offset: const Offset(0, 4),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: const Icon(Icons.rocket_launch_rounded, color: Colors.white, size: 36),
              ),
              const SizedBox(height: 16),
              ShaderMask(
                shaderCallback: (bounds) => AppTheme.primaryGradient.createShader(bounds),
                child: const Text(
                  'ChmlFrp',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Flutter 客户端 v1.4.1',
                style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 24),
              // GitHub 链接
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () async {
                      final url = Uri.parse('https://github.com/zhengyuliu047-rgb/ChmlFrp-flutter');
                      if (await canLaunchUrl(url)) await launchUrl(url);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.code_rounded, size: 18, color: AppTheme.primaryColor),
                          SizedBox(width: 8),
                          Text(
                            'GitHub 仓库',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('关闭'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 设置卡片组件
class _SettingsCard extends StatelessWidget {
  final List<Color> gradientColors;
  final IconData icon;
  final String title;
  final Widget child;

  const _SettingsCard({
    required this.gradientColors,
    required this.icon,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.borderColor),
        boxShadow: [
          BoxShadow(
            color: gradientColors[0].withOpacity(0.06),
            offset: const Offset(0, 8),
            blurRadius: 24,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 卡片头部
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceVariant.withOpacity(0.5),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: gradientColors),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: gradientColors[0].withOpacity(0.3),
                        offset: const Offset(0, 2),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: Icon(icon, size: 18, color: Colors.white),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppTheme.borderColor),
          child,
        ],
      ),
    );
  }
}

// 设置项组件
class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;
  final bool showArrow;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
    this.titleStyle,
    this.subtitleStyle,
    this.showArrow = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: titleStyle ?? const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: subtitleStyle ?? TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                  ),
                ],
              ),
            ),
            if (trailing != null) trailing!,
            if (showArrow) Icon(Icons.chevron_right_rounded, color: AppTheme.textTertiary, size: 20),
          ],
        ),
      ),
    );
  }
}

// 隧道复选框
class _TunnelCheckbox extends StatelessWidget {
  final String name;
  final String subtitle;
  final bool isSelected;
  final ValueChanged<bool?> onChanged;

  const _TunnelCheckbox({
    required this.name,
    required this.subtitle,
    required this.isSelected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      value: isSelected,
      onChanged: onChanged,
      title: Text(name, style: const TextStyle(fontFamily: "HarmonyOS Sans", fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: const TextStyle(fontFamily: "HarmonyOS Sans", fontSize: 12)),
      activeColor: AppTheme.primaryColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }
}
