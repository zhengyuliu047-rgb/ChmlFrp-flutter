import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/api_service.dart';

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

  // 加载节点列表
  Future<void> _loadNodes() async {
    setState(() {
      _isLoading = true;
    });
    await _fetchNodes();
    setState(() {
      _isLoading = false;
    });
  }

  // 刷新节点列表
  Future<void> _refreshNodes() async {
    setState(() {
      _isRefreshing = true;
    });
    await _fetchNodes();
    setState(() {
      _isRefreshing = false;
    });
  }

  // 从API获取节点列表
  Future<void> _fetchNodes() async {
    final nodes = await ApiService.getNodesDataList();
    setState(() {
      _nodes = nodes;
    });
  }

  // 查看节点详情
  Future<void> _viewNodeDetails(NodeData node) async {
    final nodeInfo = await ApiService.getNodeInfo(node.name);
    if (nodeInfo != null && mounted) {
      _showNodeInfoDialog(nodeInfo);
    } else if (mounted) {
      // 显示权限不足的提示
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('权限不足，无法查看节点详情')),
      );
    }
  }

  // 显示节点详情对话框
  void _showNodeInfoDialog(NodeInfo nodeInfo) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(nodeInfo.name),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildNodeInfoRow('区域', nodeInfo.area),
                _buildNodeInfoRow('位置', nodeInfo.location),
                _buildNodeInfoRow('类型', nodeInfo.type),
                _buildNodeInfoRow('状态', nodeInfo.state),
                _buildNodeInfoRow('IP地址', nodeInfo.ip),
                _buildNodeInfoRow('端口', nodeInfo.port.toString()),
                _buildNodeInfoRow('在线用户', nodeInfo.users.toString()),
                _buildNodeInfoRow('负载', nodeInfo.load15.toStringAsFixed(2)),
                _buildNodeInfoRow('带宽', '${nodeInfo.bandwidth} Mbps'),
                _buildNodeInfoRow('流量', '${nodeInfo.traffic} MB'),
                _buildNodeInfoRow('正常运行时间', _formatUptime(nodeInfo.uptime_seconds)),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('关闭'),
            ),
          ],
        );
      },
    );
  }

  // 构建节点信息行
  Widget _buildNodeInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  // 格式化运行时间
  String _formatUptime(int seconds) {
    final days = seconds ~/ 86400;
    final hours = (seconds % 86400) ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;

    final parts = <String>[];
    if (days > 0) parts.add('${days}天');
    if (hours > 0) parts.add('${hours}小时');
    if (minutes > 0) parts.add('${minutes}分钟');
    if (secs > 0) parts.add('${secs}秒');

    return parts.join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refreshNodes,
              child: _nodes.isEmpty
                  ? const Center(
                      child: Text('暂无节点'),
                    )
                  : ListView.builder(
                      itemCount: _nodes.length,
                      itemBuilder: (context, index) {
                        final node = _nodes[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: ListTile(
                            leading: Icon(Icons.dns, size: 32, color: Theme.of(context).colorScheme.primary),
                            title: Text(node.name),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('区域: ${node.area}'),
                                Text('节点组: ${node.nodegroup}'),
                                if (node.notes.isNotEmpty)
                                  Text(
                                    '备注: ${node.notes}',
                                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                                  ),
                              ],
                            ),
                            trailing: const Icon(Icons.arrow_forward_ios),
                            onTap: () => _viewNodeDetails(node),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
