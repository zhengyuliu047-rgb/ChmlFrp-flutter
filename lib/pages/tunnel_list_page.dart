import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../services/frpc_service.dart';
import '../widgets/tunnel_form_dialog.dart';
import '../theme/app_theme.dart';

class TunnelListPage extends StatefulWidget {
  const TunnelListPage({super.key});

  @override
  State<TunnelListPage> createState() => _TunnelListPageState();
}

class _TunnelListPageState extends State<TunnelListPage> {
  List<TunnelInfo> _tunnels = [];
  Map<int, bool> _tunnelRunningStatus = {};
  bool _isLoading = false;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _loadTunnels();
  }

  // 加载隧道列表
  Future<void> _loadTunnels() async {
    setState(() {
      _isLoading = true;
    });
    await _fetchTunnels();
    setState(() {
      _isLoading = false;
    });
  }

  // 刷新隧道列表
  Future<void> _refreshTunnels() async {
    setState(() {
      _isRefreshing = true;
    });
    await _fetchTunnels();
    setState(() {
      _isRefreshing = false;
    });
  }

  // 从API获取隧道列表
  Future<void> _fetchTunnels() async {
    final tunnels = await ApiService.getTunnelList();
    setState(() {
      _tunnels = tunnels;
      // 初始化隧道运行状态
      for (var tunnel in tunnels) {
        _tunnelRunningStatus[tunnel.id] = FrpcService.isTunnelRunning(tunnel.id);
      }
    });
  }

  // 处理隧道启动/停止
  Future<void> _toggleTunnel(TunnelInfo tunnel) async {
    final isRunning = _tunnelRunningStatus[tunnel.id] ?? false;
    TunnelStatus status;

    if (isRunning) {
      status = await FrpcService.stopTunnel(tunnel.id, null);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('隧道停止成功'),
            backgroundColor: AppTheme.successColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } else {
      status = await FrpcService.startTunnel(tunnel.id, (newStatus) {
        setState(() {
          _tunnelRunningStatus[tunnel.id] = newStatus;
        });
      });
      
      if (mounted) {
        if (status == TunnelStatus.started) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('启动成功'),
              backgroundColor: AppTheme.successColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
              ),
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('启动失败，请尝试重新启动，或者查看日志'),
              backgroundColor: AppTheme.errorColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
              ),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }

    setState(() {
      _tunnelRunningStatus[tunnel.id] = status == TunnelStatus.started;
    });
  }

  // 创建新隧道
  Future<void> _createTunnel() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => const TunnelFormDialog(),
    );

    if (result == true) {
      _refreshTunnels();
    }
  }

  // 编辑隧道
  Future<void> _editTunnel(TunnelInfo tunnel) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => TunnelFormDialog(tunnel: tunnel),
    );

    if (result == true) {
      _refreshTunnels();
    }
  }

  // 删除隧道
  Future<void> _deleteTunnel(TunnelInfo tunnel) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('确认删除'),
          content: Text('确定要删除隧道 "${tunnel.name}" 吗？' ,style: TextStyle(fontFamily: "HarmonyOS Sans",fontSize: 12, fontWeight: FontWeight.w500)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('取消' ,style: TextStyle(fontFamily: "HarmonyOS Sans",fontSize: 12, fontWeight: FontWeight.w500)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text('删除', style: TextStyle(fontFamily: "HarmonyOS Sans",fontSize: 12, fontWeight: FontWeight.w500)),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
          ),
        );
      },
    );

    if (confirmed == true) {
      final success = await ApiService.deleteTunnel(tunnel.id);
      if (success) {
        _refreshTunnels();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('隧道删除成功'),
              backgroundColor: AppTheme.successColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
              ),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('隧道删除失败'),
              backgroundColor: AppTheme.errorColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
              ),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _createTunnel,
        child: const Icon(Icons.add),
        tooltip: '创建隧道',
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refreshTunnels,
              color: AppTheme.primaryColor,
              backgroundColor: AppTheme.surfaceColor,
              child: _tunnels.isEmpty
                  ? const Center(
                      child: Text('暂无隧道'),
                    )
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        // 根据屏幕宽度动态调整列数
                        int crossAxisCount = constraints.maxWidth ~/ 300;
                        crossAxisCount = crossAxisCount.clamp(1, 3);
                        
                        return GridView.count(
                          crossAxisCount: crossAxisCount,
                          padding: const EdgeInsets.all(16),
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 1.6,
                          children: _tunnels.map((tunnel) {
                            final isRunning = _tunnelRunningStatus[tunnel.id] ?? false;
                            return TunnelCard(
                              tunnel: tunnel,
                              isRunning: isRunning,
                              onToggle: () => _toggleTunnel(tunnel),
                              onEdit: () => _editTunnel(tunnel),
                              onDelete: () => _deleteTunnel(tunnel),
                            );
                          }).toList(),
                        );
                      },
                    ),
            ),
    );
  }
}

// 隧道卡片组件
class TunnelCard extends StatefulWidget {
  final TunnelInfo tunnel;
  final bool isRunning;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TunnelCard({
    super.key,
    required this.tunnel,
    required this.isRunning,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<TunnelCard> createState() => _TunnelCardState();
}

class _TunnelCardState extends State<TunnelCard> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        _animationController.forward();
      },
      onExit: (_) {
        _animationController.reverse();
      },
      child: GestureDetector(
        onTap: () {},
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
                border: Border.all(
                  color: widget.isRunning ? AppTheme.primaryColor : AppTheme.borderColor,
                  width: widget.isRunning ? 1.5 : 1,
                ),
                boxShadow: [
                  AppTheme.shadowSmall,
                ],
              ),
              child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 隧道名称和状态
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    widget.tunnel.name,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                TunnelStatusBadge(isRunning: widget.isRunning),
                              ],
                            ),
                            const SizedBox(height: 4),
                            // 隧道类型和节点
                            Row(
                              children: [
                                Expanded(
                                  child: TunnelTypeBadge(type: widget.tunnel.type),
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: TunnelNodeBadge(node: widget.tunnel.node),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            // 隧道详细信息
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  TunnelInfoItem(
                                    label: '远程',
                                    value: ['http', 'https'].contains(widget.tunnel.type) ? widget.tunnel.dorp : '${widget.tunnel.ip}:${widget.tunnel.dorp}',
                                    showCopyButton: true,
                                  ),
                                  const SizedBox(height: 2),
                                  TunnelInfoItem(
                                    label: '本地',
                                    value: '${widget.tunnel.localip}:${widget.tunnel.nport}',
                                    showCopyButton: true,
                                  ),
                                  const SizedBox(height: 2),
                                  TunnelInfoItem(
                                    label: '连接数',
                                    value: '${widget.tunnel.cur_conns}',
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 6),
                            // 操作按钮
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  onPressed: widget.onEdit,
                                  icon: Icon(Icons.edit, size: 18, color: AppTheme.textSecondary),
                                  tooltip: '编辑',
                                  padding: const EdgeInsets.all(6),
                                ),
                                IconButton(
                                  onPressed: widget.onDelete,
                                  icon: Icon(Icons.delete, size: 18, color: AppTheme.errorColor),
                                  tooltip: '删除',
                                  padding: const EdgeInsets.all(6),
                                ),
                                Expanded(
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: ElevatedButton(
                                      onPressed: widget.onToggle,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: widget.isRunning ? AppTheme.errorColor : AppTheme.primaryColor,
                                        foregroundColor: Colors.white,
                                        minimumSize: const Size(56, 28),
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                                        ),
                                      ),
                                      child: Text(
                                        widget.isRunning ? '停止' : '启动',
                                        style: const TextStyle(fontFamily: '黑体',fontSize: 13),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
            ),
          ),
        ),
      ),
    );
  }
}

// 隧道状态徽章
class TunnelStatusBadge extends StatelessWidget {
  final bool isRunning;

  const TunnelStatusBadge({super.key, required this.isRunning});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isRunning ? AppTheme.successColor : AppTheme.textTertiary,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusFull),
      ),
      child: Text(
        isRunning ? '运行中' : '已停止',
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white),
      ),
    );
  }
}

// 隧道类型徽章
class TunnelTypeBadge extends StatelessWidget {
  final String type;

  const TunnelTypeBadge({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusFull),
      ),
      child: Text(
        type,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppTheme.primaryColor,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

// 隧道节点徽章
class TunnelNodeBadge extends StatelessWidget {
  final String node;

  const TunnelNodeBadge({super.key, required this.node});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: AppTheme.secondaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusFull),
      ),
      child: Text(
        node,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppTheme.secondaryColor,
          overflow: TextOverflow.ellipsis,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

// 隧道信息项
class TunnelInfoItem extends StatelessWidget {
  final String label;
  final String value;
  final bool showCopyButton;

  const TunnelInfoItem({
    super.key,
    required this.label,
    required this.value,
    this.showCopyButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppTheme.textSecondary,
            ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textPrimary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (showCopyButton)
          IconButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: value));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('已复制到剪贴板'),
                  backgroundColor: AppTheme.successColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                  ),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            icon: Icon(Icons.copy, size: 16, color: AppTheme.textSecondary),
            tooltip: '复制',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
      ],
    );
  }
}
