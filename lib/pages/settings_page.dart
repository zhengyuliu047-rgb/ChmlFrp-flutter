import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../utils/animation_utils.dart';
import '../widgets/about_dialog.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = AnimationUtils.createFadeAnimation(_animationController);
    _animationController.forward();
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
              // 账户信息卡片
              SettingsCard(
                title: '账户信息',
                icon: Icons.person,
                iconColor: AppTheme.primaryColor,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SettingItem(
                        label: '用户名',
                        value: ApiService.userInfo?.username ?? '',
                      ),
                      SettingItem(
                        label: '用户组',
                        value: ApiService.userInfo?.usergroup ?? '',
                      ),
                      SettingItem(
                        label: '邮箱',
                        value: ApiService.userInfo?.email ?? '',
                      ),
                      SettingItem(
                        label: 'QQ',
                        value: ApiService.userInfo?.qq ?? '',
                      ),
                      SettingItem(
                        label: '注册时间',
                        value: ApiService.userInfo?.regtime ?? '',
                      ),
                      SettingItem(
                        label: '积分',
                        value: ApiService.userInfo?.integral.toString() ?? '',
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
                        subtitle: 'ChmlFrp Flutter 客户端 v1.0.0',
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
                                            Text('版本：'),
                                            Text('1.0.0'),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: const [
                                            Text('平台：'),
                                            Text('Flutter 跨平台'),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: const [
                                            Text('描述：'),
                                            Text('ChmlFrp 客户端'),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 24),

                                    // Gitee 仓库链接
                                    GestureDetector(
                                      onTap: () async {
                                        final url = Uri.parse('https://gitee.com/initial-qwq/flutter_chmlfrp');
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
                                            Text('Gitee 仓库'),
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
                                  child: const Text('关闭'),
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
                    style: TextStyle(fontFamily: "黑体",fontSize: 16, fontWeight: FontWeight.w500),
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
