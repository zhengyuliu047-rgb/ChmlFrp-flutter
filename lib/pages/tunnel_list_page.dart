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

class _TunnelListPageState extends State<TunnelListPage> with TickerProviderStateMixin {
  List<TunnelInfo> _tunnels = [];
  Map<int, bool> _tunnelRunningStatus = {};
  bool _isLoading = false;
  bool _isRefreshing = false;
  late AnimationController _listAnimationController;

  @override
  void initState() {
    super.initState();
    _listAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _loadTunnels();
  }

  @override
  void dispose() {
    _listAnimationController.dispose();
    super.dispose();
  }

  Future<void> _loadTunnels() async {
    setState(() => _isLoading = true);
    await _fetchTunnels();
    setState(() => _isLoading = false);
    _listAnimationController.forward();
  }

  Future<void> _refreshTunnels() async {
    setState(() => _isRefreshing = true);
    await _fetchTunnels();
    setState(() => _isRefreshing = false);
    _listAnimationController.reset();
    _listAnimationController.forward();
  }

  Future<void> _fetchTunnels() async {
    final tunnels = await ApiService.getTunnelList();
    setState(() {
      _tunnels = tunnels;
      for (var tunnel in tunnels) {
        _tunnelRunningStatus[tunnel.id] = FrpcService.isTunnelRunning(tunnel.id);
      }
    });
  }

  Future<void> _toggleTunnel(TunnelInfo tunnel) async {
    final isRunning = _tunnelRunningStatus[tunnel.id] ?? false;
    TunnelStatus status;

    if (isRunning) {
      status = await FrpcService.stopTunnel(tunnel.id, null);
      if (mounted) {
        _showSnackBar('隧道停止成功', AppTheme.successColor);
      }
    } else {
      status = await FrpcService.startTunnel(tunnel.id, (newStatus) {
        setState(() => _tunnelRunningStatus[tunnel.id] = newStatus);
      });
      
      if (mounted) {
        if (status == TunnelStatus.started) {
          _showSnackBar('启动成功', AppTheme.successColor);
        } else {
          _showSnackBar('启动失败，请查看日志', AppTheme.errorColor);
        }
      }
    }

    setState(() => _tunnelRunningStatus[tunnel.id] = status == TunnelStatus.started);
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

  Future<void> _createTunnel() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => const TunnelFormDialog(),
    );
    if (result == true) _refreshTunnels();
  }

  Future<void> _editTunnel(TunnelInfo tunnel) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => TunnelFormDialog(tunnel: tunnel),
    );
    if (result == true) _refreshTunnels();
  }

  Future<void> _deleteTunnel(TunnelInfo tunnel) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除', style: TextStyle(fontFamily: "HarmonyOS Sans", fontWeight: FontWeight.w700)),
        content: Text('确定要删除隧道 "${tunnel.name}" 吗？', style: const TextStyle(fontFamily: "HarmonyOS Sans", fontSize: 13)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消', style: TextStyle(fontFamily: "HarmonyOS Sans")),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('删除', style: TextStyle(fontFamily: "HarmonyOS Sans", color: AppTheme.errorColor)),
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );

    if (confirmed == true) {
      final success = await ApiService.deleteTunnel(tunnel.id);
      if (success) {
        _refreshTunnels();
        if (mounted) _showSnackBar('隧道删除成功', AppTheme.successColor);
      } else {
        if (mounted) _showSnackBar('隧道删除失败', AppTheme.errorColor);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: _buildFAB(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refreshTunnels,
              color: AppTheme.primaryColor,
              backgroundColor: AppTheme.surfaceColor,
              child: _tunnels.isEmpty
                  ? _buildEmptyState()
                  : _buildTunnelGrid(),
            ),
    );
  }

  Widget _buildFAB() {
    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.4),
            offset: const Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: _createTunnel,
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(Icons.route_rounded, size: 40, color: AppTheme.primaryColor),
          ),
          const SizedBox(height: 20),
          const Text(
            '暂无隧道',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '点击右上角按钮创建第一个隧道',
            style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildTunnelGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = constraints.maxWidth ~/ 340;
        crossAxisCount = crossAxisCount.clamp(1, 3);
        
        return GridView.builder(
          padding: const EdgeInsets.all(24),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 20,
            crossAxisSpacing: 20,
            childAspectRatio: 1.5,
          ),
          itemCount: _tunnels.length,
          itemBuilder: (context, index) {
            final tunnel = _tunnels[index];
            final isRunning = _tunnelRunningStatus[tunnel.id] ?? false;
            
            return AnimatedBuilder(
              animation: _listAnimationController,
              builder: (context, child) {
                final delay = index * 0.1;
                final progress = ((_listAnimationController.value - delay) / (1 - delay)).clamp(0.0, 1.0);
                return Transform.scale(
                  scale: 0.8 + (0.2 * Curves.easeOutCubic.transform(progress)),
                  child: Opacity(opacity: progress, child: child),
                );
              },
              child: TunnelCard(
                tunnel: tunnel,
                isRunning: isRunning,
                onToggle: () => _toggleTunnel(tunnel),
                onEdit: () => _editTunnel(tunnel),
                onDelete: () => _deleteTunnel(tunnel),
              ),
            );
          },
        );
      },
    );
  }
}

// ================================================================
// 隧道卡片组件 - 全新设计
// ================================================================
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
  late AnimationController _hoverController;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) { setState(() => _isHovered = true); _hoverController.forward(); },
      onExit: (_) { setState(() => _isHovered = false); _hoverController.reverse(); },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: widget.isRunning 
                ? AppTheme.successColor.withOpacity(0.5)
                : _isHovered 
                    ? AppTheme.primaryColor.withOpacity(0.3)
                    : AppTheme.borderColor,
            width: widget.isRunning ? 2 : 1,
          ),
          boxShadow: [
            widget.isRunning
                ? BoxShadow(
                    color: AppTheme.successColor.withOpacity(0.15),
                    offset: const Offset(0, 8),
                    blurRadius: 24,
                  )
                : _isHovered
                    ? AppTheme.shadowLg
                    : AppTheme.shadowMd,
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 顶部：名称和状态
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.tunnel.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _StatusBadge(isRunning: widget.isRunning),
                ],
              ),
              const SizedBox(height: 10),
              // 类型和节点标签
              Row(
                children: [
                  _TypeBadge(type: widget.tunnel.type),
                  const SizedBox(width: 8),
                  Expanded(child: _NodeBadge(node: widget.tunnel.node)),
                ],
              ),
              const SizedBox(height: 12),
              // 连接信息
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _InfoItem(
                      icon: Icons.public_rounded,
                      label: '远程',
                      value: ['http', 'https'].contains(widget.tunnel.type)
                          ? widget.tunnel.dorp
                          : '${widget.tunnel.ip}:${widget.tunnel.dorp}',
                      showCopy: true,
                    ),
                    _InfoItem(
                      icon: Icons.computer_rounded,
                      label: '本地',
                      value: '${widget.tunnel.localip}:${widget.tunnel.nport}',
                      showCopy: true,
                    ),
                    _InfoItem(
                      icon: Icons.link_rounded,
                      label: '连接数',
                      value: widget.tunnel.cur_conns.toString(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // 操作按钮
              Row(
                children: [
                  _IconBtn(
                    icon: Icons.edit_outlined,
                    color: AppTheme.textSecondary,
                    onTap: widget.onEdit,
                    tooltip: '编辑',
                  ),
                  _IconBtn(
                    icon: Icons.delete_outline,
                    color: AppTheme.errorColor,
                    onTap: widget.onDelete,
                    tooltip: '删除',
                  ),
                  const Spacer(),
                  _ToggleBtn(
                    isRunning: widget.isRunning,
                    onTap: widget.onToggle,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool isRunning;

  const _StatusBadge({required this.isRunning});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isRunning 
            ? AppTheme.successColor.withOpacity(0.12)
            : AppTheme.textTertiary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isRunning 
              ? AppTheme.successColor.withOpacity(0.3)
              : AppTheme.textTertiary.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: isRunning ? AppTheme.successColor : AppTheme.textTertiary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            isRunning ? '运行中' : '已停止',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isRunning ? AppTheme.successColor : AppTheme.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  final String type;

  const _TypeBadge({required this.type});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor.withOpacity(0.1),
            AppTheme.secondaryColor.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        type.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppTheme.primaryColor,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _NodeBadge extends StatelessWidget {
  final String node;

  const _NodeBadge({required this.node});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.infoColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.dns_rounded, size: 12, color: AppTheme.infoColor),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              node,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppTheme.infoColor,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool showCopy;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
    this.showCopy = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppTheme.textTertiary),
        const SizedBox(width: 8),
        Text(
          '$label:',
          style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (showCopy)
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: value));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('已复制到剪贴板', style: TextStyle(fontFamily: "HarmonyOS Sans")),
                  backgroundColor: AppTheme.successColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Icon(Icons.copy_rounded, size: 14, color: AppTheme.textTertiary),
          ),
      ],
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final String tooltip;

  const _IconBtn({
    required this.icon,
    required this.color,
    required this.onTap,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
      ),
    );
  }
}

class _ToggleBtn extends StatelessWidget {
  final bool isRunning;
  final VoidCallback onTap;

  const _ToggleBtn({required this.isRunning, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: isRunning
              ? LinearGradient(colors: [AppTheme.errorColor, AppTheme.errorLight])
              : AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: (isRunning ? AppTheme.errorColor : AppTheme.primaryColor).withOpacity(0.3),
              offset: const Offset(0, 2),
              blurRadius: 6,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isRunning ? Icons.stop_rounded : Icons.play_arrow_rounded,
              size: 16,
              color: Colors.white,
            ),
            const SizedBox(width: 4),
            Text(
              isRunning ? '停止' : '启动',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
