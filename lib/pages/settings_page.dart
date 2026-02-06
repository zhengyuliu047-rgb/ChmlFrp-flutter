import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:launch_at_startup/launch_at_startup.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
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
  
  // 初始化开机自启设置
  Future<void> _initializeLaunchAtStartup() async {
    try {
      // 设置应用信息
      launchAtStartup.setup(
        appName: 'ChmlFrp',
        appPath: Platform.resolvedExecutable,
      );
      
      // 检查当前状态
      final isEnabled = await launchAtStartup.isEnabled();
      setState(() {
        _launchAtStartup = isEnabled;
      });
    } catch (e) {
      print('初始化开机自启设置失败: $e');
    }
  }
  
  // 切换开机自启状态
  Future<void> _toggleLaunchAtStartup(bool value) async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      if (value) {
        await launchAtStartup.enable();
      } else {
        await launchAtStartup.disable();
      }
      
      setState(() {
        _launchAtStartup = value;
      });
      
      // 保存设置到本地存储
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('launchAtStartup', value);
    } catch (e) {
      print('切换开机自启状态失败: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  // 初始化自动启动隧道设置
  Future<void> _initializeAutoStartTunnel() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final autoStartEnabled = prefs.getBool('autoStartTunnel') ?? false;
      final tunnelIds = prefs.getStringList('autoStartTunnelIds') ?? [];
      
      setState(() {
        _autoStartTunnel = autoStartEnabled;
        _autoStartTunnelIds = tunnelIds;
      });
    } catch (e) {
      print('初始化自动启动隧道设置失败: $e');
    }
  }
  
  // 切换自动启动隧道状态
  Future<void> _toggleAutoStartTunnel(bool value) async {
    setState(() {
      _autoStartTunnel = value;
    });
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('autoStartTunnel', value);
    } catch (e) {
      print('切换自动启动隧道状态失败: $e');
    }
  }
  
  // 配置自动启动隧道
  void _configureAutoStartTunnel() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('配置自动启动隧道'),
        content: FutureBuilder<List<TunnelInfo>>(
          future: ApiService.getTunnelList(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Text('获取隧道列表失败: ${snapshot.error}');
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Text('未获取到隧道列表');
            } else {
              final tunnels = snapshot.data!;
              return StatefulBuilder(
                builder: (context, setState) {
                  return SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: tunnels.map((tunnel) {
                        final isSelected = _autoStartTunnelIds.contains(tunnel.id.toString());
                        return CheckboxListTile(
                          title: Text(tunnel.name),
                          subtitle: Text('${tunnel.type} | ${tunnel.node} | 端口: ${tunnel.nport}'),
                          value: isSelected,
                          onChanged: (value) {
                            setState(() {
                              if (value == true) {
                                _autoStartTunnelIds.add(tunnel.id.toString());
                              } else {
                                _autoStartTunnelIds.remove(tunnel.id.toString());
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                  );
                },
              );
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              // 保存配置
              final prefs = await SharedPreferences.getInstance();
              await prefs.setStringList('autoStartTunnelIds', _autoStartTunnelIds);
              
              // 更新UI
              setState(() {
                // UI will be updated when the dialog is closed
              });
              
              Navigator.of(context).pop();
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }



  // 处理登出
  Future<void> _handleLogout() async {
    await ApiService.logout();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: ListView(
            children: [
              // 系统设置卡片
              SettingsCard(
                title: '系统设置',
                icon: Icons.computer,
                iconColor: AppTheme.accentColor,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Divider(height: 1, color: AppTheme.borderColor),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('开机自启',style: TextStyle(fontFamily: "HarmonyOS Sans",fontSize: 14, fontWeight: FontWeight.w700)),
                                Text(
                                  '应用将在系统启动时自动运行',
                                  style: TextStyle(fontFamily: "HarmonyOS Sans",fontSize: 12, fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                            _isLoading
                                ? CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                                  )
                                : Switch(
                                    value: _launchAtStartup,
                                    onChanged: _toggleLaunchAtStartup,
                                    activeColor: AppTheme.primaryColor,
                                  ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 自动启动隧道卡片
              SettingsCard(
                title: '自动启动隧道',
                icon: Icons.link,
                iconColor: AppTheme.primaryColor,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Divider(height: 1, color: AppTheme.borderColor),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('启用自动启动隧道' ,style: TextStyle(fontFamily: "HarmonyOS Sans",fontSize: 14, fontWeight: FontWeight.w700)),
                                Text(
                                  '程序启动时自动启动选定的隧道',
                                  style: TextStyle(fontFamily: "HarmonyOS Sans",fontSize: 12, fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                            Switch(
                              value: _autoStartTunnel,
                              onChanged: _toggleAutoStartTunnel,
                              activeColor: AppTheme.primaryColor,
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('配置自动启动的隧道',style: TextStyle(fontFamily: "HarmonyOS Sans",fontSize: 14, fontWeight: FontWeight.w700)),
                                Text(
                                  _autoStartTunnelIds.isEmpty ? '未配置任何隧道' : '已配置 ${_autoStartTunnelIds.length} 个隧道',
                                  style:TextStyle(fontFamily: "HarmonyOS Sans",fontSize: 12, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                            ElevatedButton(
                              onPressed: _configureAutoStartTunnel,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                                ),
                              ),
                              child: const Text('配置隧道',style: TextStyle(fontFamily: "HarmonyOS Sans",fontSize: 12, fontWeight: FontWeight.w500)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 其他设置卡片
              SettingsCard(
                title: '其他设置',
                icon: Icons.settings,
                iconColor: AppTheme.secondaryColor,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Divider(height: 1, color: AppTheme.borderColor),
                      SettingTile(
                        title: '关于',
                        subtitle: 'ChmlFrp Flutter 客户端 v1.3.1',
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text('关于 ChmlFrp'),
                              content: SingleChildScrollView(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // 作者信息和头像
                                    Column(
                                      children: [
                                        // 圆形头像
                                        Container(
                                          width: 80,
                                          height: 80,
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            image: DecorationImage(
                                              image: AssetImage('assets/images/b_eabec14b96e98a610b58afbc411a55b7.jpg'),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        const Text('作者：初'),
                                      ],
                                    ),
                                    const SizedBox(height: 24),

                                    // 应用信息
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: const [
                                            Text('版本：', style: TextStyle(fontFamily: "HarmonyOS Sans",fontSize: 12, fontWeight: FontWeight.w700)),
                                            Text('1.3.1'),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: const [
                                            Text('平台：', style: TextStyle(fontFamily: "HarmonyOS Sans",fontSize: 12, fontWeight: FontWeight.w700)),
                                            Text('Flutter 跨平台'),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: const [
                                            Text('描述：' ,style: TextStyle(fontFamily: "HarmonyOS Sans",fontSize: 12, fontWeight: FontWeight.w700)),
                                            Text('ChmlFrp 客户端'),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 24),

                                    // Github 仓库链接
                                    GestureDetector(
                                      onTap: () async {
                                        final url = Uri.parse('https://github.com/zhengyuliu047-rgb/ChmlFrp-flutter');
                                        if (await canLaunchUrl(url)) {
                                          await launchUrl(url);
                                        }
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                                        decoration: BoxDecoration(
                                          color: AppTheme.primaryColor.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: AppTheme.primaryColor),
                                        ),
                                        child: const Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.code, size: 16),
                                            SizedBox(width: 8),
                                            Text('Github 仓库' ,style: TextStyle(fontFamily: "HarmonyOS Sans",fontSize: 14, fontWeight: FontWeight.w500)),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('关闭',  style: TextStyle(fontFamily: "HarmonyOS Sans",fontSize: 14, fontWeight: FontWeight.w500)),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // 登出按钮
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _handleLogout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.errorColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                    ),
                  ),
                  child: const Text(
                    '登出账户',
                    style: TextStyle(fontFamily: "HarmonyOS Sans",fontSize: 14, fontWeight: FontWeight.w500),
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
}

// 设置卡片组件
class SettingsCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final Widget child;

  const SettingsCard({
    super.key,
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
        border: Border.all(color: AppTheme.borderColor),
        boxShadow: [
          AppTheme.shadowSmall,
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 卡片头部
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                  ),
                  child: Icon(icon, size: 20, color: iconColor),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppTheme.borderColor),
          // 卡片内容
          child,
        ],
      ),
    );
  }
}

// 设置项组件
class SettingItem extends StatelessWidget {
  final String label;
  final String value;

  const SettingItem({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: AppTheme.textSecondary)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

// 状态项组件
class StatusItem extends StatelessWidget {
  final String label;
  final String value;
  final bool isLoading;
  final Color? valueColor;

  const StatusItem({
    super.key,
    required this.label,
    required this.value,
    this.isLoading = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: AppTheme.textSecondary)),
        if (isLoading)
          const SizedBox(
            height: 16,
            width: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
            ),
          )
        else
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: valueColor ?? AppTheme.textPrimary,
            ),
          ),
      ],
    );
  }
}

// 设置行组件
class SettingTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const SettingTile({
    super.key,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                    ),
                ],
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: AppTheme.textTertiary),
            ],
          ),
        ),
      ),
    );
  }
}
