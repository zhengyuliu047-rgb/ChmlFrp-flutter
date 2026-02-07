import 'package:flutter/material.dart';
import 'dart:async';
import '../services/api_service.dart';
import '../services/frpc_service.dart';
import '../theme/app_theme.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}


class _DashboardPageState extends State<DashboardPage> {
  String _frpcVersion = '未知';
  int _runningTunnelCount = 0;
  bool _isSigningIn = false;
  String _signInStatus = '';
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _checkFrpcVersion();
    _updateRunningTunnelCount();
    
    // 初始化定时器，每 2 秒刷新一次运行中的隧道数量
    _refreshTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      _updateRunningTunnelCount();
    });
  }
  
  @override
  void dispose() {
    // 取消定时器
    _refreshTimer?.cancel();
    super.dispose();
  }

  // 检查frpc版本
  Future<void> _checkFrpcVersion() async {
    final version = await FrpcService.getFrpcVersion();
    setState(() {
      _frpcVersion = version;
    });
  }


  // 更新运行中的隧道数量
  void _updateRunningTunnelCount() {
    setState(() {
      _runningTunnelCount = FrpcService.getRunningTunnels().length;
    });
  }

  // 执行签到
  Future<void> _performSignIn() async {
    setState(() {
      _isSigningIn = true;
      _signInStatus = '正在签到...';
    });

    try {
      // 这里需要实现验证码获取和处理逻辑
      // 由于没有具体的验证码实现，这里使用模拟数据进行测试
      // 实际使用时需要集成真实的验证码获取和处理
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
            // 刷新用户信息以更新积分
            ApiService.refreshUserInfo().then((_) {
              setState(() {});
            });
          });
        } else {
          setState(() {
            _signInStatus = '签到失败：${result['msg'] ?? '未知错误'}';
          });
        }
      } else {
        setState(() {
          _signInStatus = '签到失败：网络错误';
        });
      }
    } catch (e) {
      setState(() {
        _signInStatus = '签到失败：${e.toString()}';
      });
    } finally {
      setState(() {
        _isSigningIn = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userInfo = ApiService.userInfo;
    if (userInfo == null) {
      return const Center(child: Text('用户信息加载失败', style: TextStyle(fontFamily: "HarmonyOS Sans")));
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // 根据屏幕宽度动态调整列数
          int crossAxisCount = constraints.maxWidth ~/ 400;
          crossAxisCount = crossAxisCount.clamp(1, 2);
          
          return GridView(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: 1.4,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            children: [
          // 用户信息卡片
          DashboardCard(
            title: '账户信息',
            icon: Icons.person,
            iconColor: AppTheme.primaryColor,
            onRefresh: () {},
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // 用户头像
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: userInfo.userimg.isNotEmpty == true
                            ? NetworkImage(userInfo.userimg)
                            : null,
                        child: userInfo.userimg.isEmpty == true
                            ? Text(userInfo.username.substring(0, 1).toUpperCase(), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, fontFamily: "HarmonyOS Sans"))
                            : null,
                        backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                      ),
                      const SizedBox(width: 16),
                      // 用户基本信息
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userInfo.username,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                fontFamily: "HarmonyOS Sans",
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              userInfo.usergroup,
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 12,
                                fontFamily: "HarmonyOS Sans",
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.email, size: 14, color: AppTheme.textTertiary),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(userInfo.email, style: TextStyle(fontSize: 11, color: AppTheme.textSecondary, fontFamily: "HarmonyOS Sans"), overflow: TextOverflow.ellipsis),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Icon(Icons.calendar_today, size: 14, color: AppTheme.textTertiary),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text('注册于 ${userInfo.regtime}', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary, fontFamily: "HarmonyOS Sans"), overflow: TextOverflow.ellipsis),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // 签到功能区域
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '每日签到',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textPrimary,
                                    fontFamily: "HarmonyOS Sans",
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: _isSigningIn ? null : _performSignIn,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppTheme.primaryColor,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                                          ),
                                        ),
                                        child: _isSigningIn
                                            ? const SizedBox(
                                                height: 16,
                                                width: 16,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                                ),
                                              )
                                            : const Text('立即签到', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, fontFamily: "HarmonyOS Sans")),
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
                                          fontFamily: "HarmonyOS Sans",
                                        ),
                                      ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // 账户状态卡片
          DashboardCard(
            title: '账户状态',
            icon: Icons.dashboard,
            iconColor: AppTheme.secondaryColor,
            onRefresh: _updateRunningTunnelCount,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatItem('隧道数量', userInfo.tunnelCount.toString(), AppTheme.primaryColor),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatItem('运行中', _runningTunnelCount.toString(), AppTheme.successColor),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('带宽限速', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12, fontFamily: "HarmonyOS Sans")),
                                const SizedBox(height: 4),
                                ..._getBandwidthLimit(userInfo.usergroup).entries.map((entry) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 1),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 50,
                                          child: Text(entry.key, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary, fontFamily: "HarmonyOS Sans")),
                                        ),
                                        Text(' ${entry.value} Mbps', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.secondaryColor, fontFamily: "HarmonyOS Sans")),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatItem('积分', userInfo.integral.toString(), AppTheme.accentColor),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // frpc状态卡片
          DashboardCard(
            title: 'frpc 状态',
            icon: Icons.cloud,
            iconColor: AppTheme.infoColor,
            onRefresh: _checkFrpcVersion,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  StatusItem(
                    label: 'frpc 版本',
                    value: _frpcVersion,
                    valueColor: AppTheme.textPrimary,
                  ),
                  const SizedBox(height: 16),
                  const SizedBox(height: 20),

                ],
              ),
            ),
          ),

          // 系统信息卡片
          DashboardCard(
            title: '系统信息',
            icon: Icons.computer,
            iconColor: AppTheme.warningColor,
            onRefresh: () {},
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  _buildSystemInfoItem('操作系统', 'Windows'),
                  _buildSystemInfoItem('应用版本', '1.4.0'),
                  _buildSystemInfoItem('API版本', 'v2'),
                  _buildSystemInfoItem('SDK版本', 'ChmlFrp.SDK'),
                ],
              ),
            ),
          ),
        ],
      );
        },
      ),
    );
  }

  // 构建统计项
  Widget _buildStatItem(String label, String value, Color valueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12, fontFamily: "HarmonyOS Sans"),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: valueColor,
            fontFamily: "HarmonyOS Sans",
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  // 构建系统信息项
  Widget _buildSystemInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12, fontFamily: "HarmonyOS Sans")),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, fontFamily: "HarmonyOS Sans")),
        ],
      ),
    );
  }

  // 根据用户等级获取带宽限速信息
  Map<String, int> _getBandwidthLimit(String userGroup) {
    switch (userGroup) {
      case '免费用户':
        return {'国内节点': 8, '国外节点': 32};
      case '普通会员':
        return {'国内节点': 16, '国外节点': 64};
      case '高级会员':
        return {'国内节点': 24, '国外节点': 96};
      case '超级会员':
        return {'国内节点': 32, '国外节点': 128};
      default:
        return {'国内节点': 8, '国外节点': 32};
    }
  }
}

// 仪表盘卡片组件
class DashboardCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final Widget child;
  final VoidCallback onRefresh;

  const DashboardCard({
    super.key,
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.child,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onRefresh,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
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
                padding: const EdgeInsets.all(12),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: iconColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                        ),
                        child: Icon(icon, size: 18, color: iconColor),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          fontFamily: "HarmonyOS Sans",
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
              ),
              const Divider(height: 1, color: AppTheme.borderColor),
              // 卡片内容
              Expanded(
                child: child,
              ),
            ],
          ),
        ),
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
        Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontFamily: "HarmonyOS Sans")),
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
              fontWeight: FontWeight.bold,
              color: valueColor ?? AppTheme.textPrimary,
              fontFamily: "HarmonyOS Sans",
            ),
          ),
      ],
    );
  }
}
