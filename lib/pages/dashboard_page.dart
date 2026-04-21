import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../services/api_service.dart';
import '../services/frpc_service.dart';
import '../theme/app_theme.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> with TickerProviderStateMixin {
  String _frpcVersion = '未知';
  int _runningTunnelCount = 0;
  bool _isSigningIn = false;
  String _signInStatus = '';
  Timer? _refreshTimer;
  late AnimationController _cardAnimationController;

  @override
  void initState() {
    super.initState();
    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _checkFrpcVersion();
    _updateRunningTunnelCount();
    _refreshTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      _updateRunningTunnelCount();
    });
    _cardAnimationController.forward();
  }
  
  @override
  void dispose() {
    _refreshTimer?.cancel();
    _cardAnimationController.dispose();
    super.dispose();
  }

  Future<void> _checkFrpcVersion() async {
    final version = await FrpcService.getFrpcVersion();
    setState(() => _frpcVersion = version);
  }

  void _updateRunningTunnelCount() {
    setState(() {
      _runningTunnelCount = FrpcService.getRunningTunnels().length;
    });
  }

  Future<void> _performSignIn() async {
    setState(() {
      _isSigningIn = true;
      _signInStatus = '正在签到...';
    });

    try {
      final result = await ApiService.signIn(
        lotNumber: 'test_lot_number',
        captchaOutput: 'test_captcha_output',
        passToken: 'test_pass_token',
        genTime: '${DateTime.now().millisecondsSinceEpoch}',
      );

      if (result != null) {
        if (result['state'] == 'success' || result['code'] == 200) {
          setState(() {
            _signInStatus = '签到成功！';
            ApiService.refreshUserInfo().then((_) => setState(() {}));
          });
        } else {
          setState(() {
            _signInStatus = '签到失败：${result['msg'] ?? '未知错误'}';
          });
        }
      } else {
        setState(() => _signInStatus = '签到失败：网络错误');
      }
    } catch (e) {
      setState(() => _signInStatus = '签到失败：${e.toString()}');
    } finally {
      setState(() => _isSigningIn = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userInfo = ApiService.userInfo;
    if (userInfo == null) {
      return const Center(
        child: Text('用户信息加载失败', style: TextStyle(fontFamily: "HarmonyOS Sans")),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(24),
      child: LayoutBuilder(
        builder: (context, constraints) {
          int crossAxisCount = constraints.maxWidth ~/ 380;
          crossAxisCount = crossAxisCount.clamp(1, 2);
          
          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: 1.35,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
            ),
            itemCount: 4,
            itemBuilder: (context, index) {
              return AnimatedBuilder(
                animation: _cardAnimationController,
                builder: (context, child) {
                  final delay = index * 0.15;
                  final progress = ((_cardAnimationController.value - delay) / (1 - delay)).clamp(0.0, 1.0);
                  return Transform.scale(
                    scale: 0.8 + (0.2 * Curves.easeOutCubic.transform(progress)),
                    child: Opacity(
                      opacity: progress,
                      child: child,
                    ),
                  );
                },
                child: _buildCard(context, index, userInfo),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildCard(BuildContext context, int index, userInfo) {
    switch (index) {
      case 0:
        return _AccountInfoCard(userInfo: userInfo);
      case 1:
        return _AccountStatusCard(
          userInfo: userInfo,
          runningTunnelCount: _runningTunnelCount,
        );
      case 2:
        return _FrpcStatusCard(frpcVersion: _frpcVersion);
      case 3:
        return _SystemInfoCard();
      default:
        return const SizedBox();
    }
  }
}

// 账户信息卡片
class _AccountInfoCard extends StatelessWidget {
  final dynamic userInfo;

  const _AccountInfoCard({required this.userInfo});

  @override
  Widget build(BuildContext context) {
    return _DashboardCard(
      gradientColors: const [Color(0xFF6366F1), Color(0xFF8B5CF6)],
      icon: Icons.person_rounded,
      title: '账户信息',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 用户头像和基本信息
          Row(
            children: [
              // 头像
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(0.3),
                      offset: const Offset(0, 4),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: userInfo.userimg.isNotEmpty == true
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(userInfo.userimg, fit: BoxFit.cover),
                      )
                    : Center(
                        child: Text(
                          userInfo.username.isNotEmpty ? userInfo.username[0].toUpperCase() : 'U',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userInfo.username,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.secondaryColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        userInfo.usergroup,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.secondaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 详细信息
          _InfoRow(icon: Icons.email_outlined, text: userInfo.email),
          const SizedBox(height: 8),
          _InfoRow(icon: Icons.calendar_today_outlined, text: '注册于 ${userInfo.regtime}'),
          const Spacer(),
          // 签到按钮
          _SignInSection(),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppTheme.textTertiary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _SignInSection extends StatefulWidget {
  @override
  State<_SignInSection> createState() => _SignInSectionState();
}

class _SignInSectionState extends State<_SignInSection> {
  bool _isSigningIn = false;
  String _signInStatus = '';

  Future<void> _performSignIn() async {
    setState(() {
      _isSigningIn = true;
      _signInStatus = '正在签到...';
    });

    try {
      final result = await ApiService.signIn(
        lotNumber: 'test_lot_number',
        captchaOutput: 'test_captcha_output',
        passToken: 'test_pass_token',
        genTime: '${DateTime.now().millisecondsSinceEpoch}',
      );

      if (result != null) {
        if (result['state'] == 'success' || result['code'] == 200) {
          setState(() {
            _signInStatus = '签到成功！';
            ApiService.refreshUserInfo();
          });
        } else {
          setState(() => _signInStatus = '签到失败：${result['msg'] ?? '未知错误'}');
        }
      } else {
        setState(() => _signInStatus = '签到失败：网络错误');
      }
    } catch (e) {
      setState(() => _signInStatus = '签到失败');
    } finally {
      setState(() => _isSigningIn = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '每日签到',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Container(
                height: 36,
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
                child: ElevatedButton(
                  onPressed: _isSigningIn ? null : _performSignIn,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.zero,
                  ),
                  child: _isSigningIn
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          '立即签到',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
        if (_signInStatus.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              _signInStatus,
              style: TextStyle(
                fontSize: 11,
                color: _signInStatus.contains('成功')
                    ? AppTheme.successColor
                    : AppTheme.errorColor,
              ),
            ),
          ),
      ],
    );
  }
}

// 账户状态卡片
class _AccountStatusCard extends StatelessWidget {
  final dynamic userInfo;
  final int runningTunnelCount;

  const _AccountStatusCard({
    required this.userInfo,
    required this.runningTunnelCount,
  });

  @override
  Widget build(BuildContext context) {
    return _DashboardCard(
      gradientColors: const [Color(0xFF10B981), Color(0xFF34D399)],
      icon: Icons.dashboard_rounded,
      title: '账户状态',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 统计数据
          Row(
            children: [
              Expanded(
                child: _StatBox(
                  label: '隧道数量',
                  value: userInfo.tunnelCount.toString(),
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatBox(
                  label: '运行中',
                  value: runningTunnelCount.toString(),
                  color: AppTheme.successColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatBox(
                  label: '积分',
                  value: userInfo.integral.toString(),
                  color: AppTheme.accentColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatBox(
                  label: '带宽限制',
                  value: _getBandwidthLimit(userInfo.usergroup),
                  color: AppTheme.secondaryColor,
                ),
              ),
            ],
          ),
          const Spacer(),
          // 带宽详情
          _BandwidthInfo(usergroup: userInfo.usergroup),
        ],
      ),
    );
  }

  String _getBandwidthLimit(String userGroup) {
    switch (userGroup) {
      case '免费用户':
        return '8M';
      case '普通会员':
        return '16M';
      case '高级会员':
        return '24M';
      case '超级会员':
        return '32M';
      default:
        return '8M';
    }
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatBox({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _BandwidthInfo extends StatelessWidget {
  final String usergroup;

  const _BandwidthInfo({required this.usergroup});

  @override
  Widget build(BuildContext context) {
    final limits = _getBandwidthLimit(usergroup);
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceVariant,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '带宽限速',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _BandwidthTag(label: '国内', value: '${limits['国内']} Mbps', color: AppTheme.warningColor),
              const SizedBox(width: 8),
              _BandwidthTag(label: '国外', value: '${limits['国外']} Mbps', color: AppTheme.infoColor),
            ],
          ),
        ],
      ),
    );
  }

  Map<String, int> _getBandwidthLimit(String userGroup) {
    switch (userGroup) {
      case '免费用户':
        return {'国内': 8, '国外': 32};
      case '普通会员':
        return {'国内': 16, '国外': 64};
      case '高级会员':
        return {'国内': 24, '国外': 96};
      case '超级会员':
        return {'国内': 32, '国外': 128};
      default:
        return {'国内': 8, '国外': 32};
    }
  }
}

class _BandwidthTag extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _BandwidthTag({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

// frpc 状态卡片
class _FrpcStatusCard extends StatelessWidget {
  final String frpcVersion;

  const _FrpcStatusCard({required this.frpcVersion});

  @override
  Widget build(BuildContext context) {
    return _DashboardCard(
      gradientColors: const [Color(0xFF3B82F6), Color(0xFF60A5FA)],
      icon: Icons.cloud_rounded,
      title: 'frpc 状态',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 版本信息
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppTheme.infoColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.terminal_rounded,
                    color: AppTheme.infoColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'frpc 版本',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      frpcVersion,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Spacer(),
          // 状态指示
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: AppTheme.successColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.successColor.withOpacity(0.5),
                      offset: const Offset(0, 0),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                '服务正常运行',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.successColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// 系统信息卡片
class _SystemInfoCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _DashboardCard(
      gradientColors: const [Color(0xFFF59E0B), Color(0xFFFBBF24)],
      icon: Icons.computer_rounded,
      title: '系统信息',
      child: Column(
        children: [
          _SystemInfoRow(label: '操作系统', value: 'Windows'),
          const SizedBox(height: 10),
          _SystemInfoRow(label: '应用版本', value: '2.0'),
          const SizedBox(height: 10),
          _SystemInfoRow(label: 'API 版本', value: 'v2'),
          const SizedBox(height: 10),
          _SystemInfoRow(label: 'SDK 版本', value: 'ChmlFrp.SDK'),
          const Spacer(),
          // 更新提示
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.successColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle_outline, size: 14, color: AppTheme.successColor),
                const SizedBox(width: 6),
                Text(
                  '已是最新版本',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.successColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SystemInfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _SystemInfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: AppTheme.textSecondary,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppTheme.surfaceVariant,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

// ================================================================
// 通用仪表盘卡片组件
// ================================================================
class _DashboardCard extends StatelessWidget {
  final List<Color> gradientColors;
  final IconData icon;
  final String title;
  final Widget child;

  const _DashboardCard({
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
            color: gradientColors[0].withOpacity(0.08),
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
                  child: Icon(icon, size: 18, color: Colors.white),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          // 卡片内容
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}
