import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../widgets/uptime_chart.dart';
import '../theme/app_theme.dart';

class NodeListPage extends StatefulWidget {
  const NodeListPage({super.key});

  @override
  State<NodeListPage> createState() => _NodeListPageState();
}

class _NodeListPageState extends State<NodeListPage> {
  List<NodeData> _nodes = [];
  bool _isLoading = false;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _loadNodes();
  }

  Future<void> _loadNodes() async {
    setState(() => _isLoading = true);
    await _fetchNodes();
    setState(() => _isLoading = false);
  }

  Future<void> _refreshNodes() async {
    setState(() => _isRefreshing = true);
    await _fetchNodes();
    setState(() => _isRefreshing = false);
  }

  Future<void> _fetchNodes() async {
    final nodes = await ApiService.getNodesDataList();
    setState(() => _nodes = nodes);
  }

  Future<void> _viewNodeDetails(NodeData node) async {
    final nodeInfo = await ApiService.getNodeInfo(node.name);
    if (nodeInfo != null && mounted) {
      _showNodeInfoDialog(nodeInfo);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('权限不足，无法查看节点详情', style: TextStyle(fontFamily: "HarmonyOS Sans")),
          backgroundColor: AppTheme.warningColor,
        ),
      );
    }
  }

  void _showNodeInfoDialog(NodeInfo nodeInfo) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.dns_rounded, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          nodeInfo.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          nodeInfo.area,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 12),
              _InfoRow(label: '状态', value: nodeInfo.state),
              _InfoRow(label: 'IP地址', value: nodeInfo.ip),
              _InfoRow(label: '端口', value: nodeInfo.port.toString()),
              _InfoRow(label: 'UDP支持', value: nodeInfo.udp),
              _InfoRow(label: '建站支持', value: nodeInfo.web),
              _InfoRow(label: '防御', value: nodeInfo.fangyu),
              _InfoRow(label: '国内带宽', value: nodeInfo.china),
              _InfoRow(label: '过白', value: nodeInfo.toowhite ? '是' : '否'),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refreshNodes,
              color: AppTheme.primaryColor,
              backgroundColor: AppTheme.surfaceColor,
              child: _nodes.isEmpty
                  ? _buildEmptyState()
                  : _buildNodeList(),
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
              color: AppTheme.infoColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(Icons.dns_rounded, size: 40, color: AppTheme.infoColor),
          ),
          const SizedBox(height: 20),
          const Text(
            '暂无节点',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '节点列表为空',
            style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildNodeList() {
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: _nodes.length,
      itemBuilder: (context, index) {
        final node = _nodes[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _NodeCard(
            node: node,
            onTap: () => _viewNodeDetails(node),
          ),
        );
      },
    );
  }
}

class _NodeCard extends StatefulWidget {
  final NodeData node;
  final VoidCallback onTap;

  const _NodeCard({required this.node, required this.onTap});

  @override
  State<_NodeCard> createState() => _NodeCardState();
}

class _NodeCardState extends State<_NodeCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isHovered ? AppTheme.primaryColor.withOpacity(0.3) : AppTheme.borderColor,
          ),
          boxShadow: [
            _isHovered ? AppTheme.shadowLg : AppTheme.shadowMd,
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 头部
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          gradient: _getNodeGradient(),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: _getNodeGradient().colors[0].withOpacity(0.3),
                              offset: const Offset(0, 2),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: Icon(
                          _getNodeIcon(),
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.node.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceVariant,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                widget.node.area,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: _isHovered ? AppTheme.primaryColor : AppTheme.textTertiary,
                      ),
                    ],
                  ),
                  if (widget.node.notes.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      widget.node.notes,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 12),
                  // 图表
                  SizedBox(
                    height: 40,
                    child: UptimeChart(nodeName: widget.node.name),
                  ),
                  const SizedBox(height: 12),
                  // 标签
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: _generateNodeTags(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  LinearGradient _getNodeGradient() {
    if (widget.node.nodegroup == 'vip') {
      return const LinearGradient(
        colors: [Color(0xFFF59E0B), Color(0xFFFBBF24)],
      );
    } else if (widget.node.nodegroup == 'admin') {
      return const LinearGradient(
        colors: [Color(0xFFEF4444), Color(0xFFF87171)],
      );
    }
    return const LinearGradient(
      colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
    );
  }

  IconData _getNodeIcon() {
    if (widget.node.nodegroup == 'vip') {
      return Icons.star_rounded;
    } else if (widget.node.nodegroup == 'admin') {
      return Icons.verified_rounded;
    }
    return Icons.dns_rounded;
  }

  List<Widget> _generateNodeTags() {
    final tags = <Widget>[];

    // 节点组标签
    if (widget.node.nodegroup == 'user') {
      tags.add(_NodeTag(text: '免费节点', color: AppTheme.successColor));
    } else if (widget.node.nodegroup == 'vip') {
      tags.add(_NodeTag(text: '会员节点', color: AppTheme.warningColor));
    }

    // 国内限速标签
    if (widget.node.china == 'yes') {
      tags.add(_NodeTag(text: '国内限速', color: AppTheme.infoColor));
    } else if (widget.node.china == 'no') {
      tags.add(_NodeTag(text: '国外限速', color: Color(0xFF8B5CF6)));
    }

    // 建站支持标签
    if (widget.node.web == 'yes') {
      tags.add(_NodeTag(text: '允许建站', color: AppTheme.successColor));
    } else {
      tags.add(_NodeTag(text: '禁止建站', color: AppTheme.errorColor));
    }

    // UDP支持标签
    if (widget.node.udp == 'true') {
      tags.add(_NodeTag(text: 'UDP', color: AppTheme.primaryColor));
    }

    return tags;
  }
}

class _NodeTag extends StatelessWidget {
  final String text;
  final Color color;

  const _NodeTag({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
