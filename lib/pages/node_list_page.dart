import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../widgets/uptime_chart.dart';

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
        const SnackBar(content: Text('权限不足，无法查看节点详情', style: TextStyle(fontFamily: "HarmonyOS Sans"))),
      );
    }
  }

  // 显示节点详情对话框
  void _showNodeInfoDialog(NodeInfo nodeInfo) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(nodeInfo.name, style: TextStyle(fontFamily: "HarmonyOS Sans")),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildNodeInfoRow('区域', nodeInfo.area),
                _buildNodeInfoRow('状态', nodeInfo.state),
                _buildNodeInfoRow('IP地址', nodeInfo.ip),
                _buildNodeInfoRow('真实IP', nodeInfo.realIp),
                _buildNodeInfoRow('端口', nodeInfo.port.toString()),
                _buildNodeInfoRow('UDP支持', nodeInfo.udp),
                _buildNodeInfoRow('建站支持', nodeInfo.web),
                _buildNodeInfoRow('防御', nodeInfo.fangyu),
                _buildNodeInfoRow('外网端口范围', nodeInfo.rport),
                _buildNodeInfoRow('节点组', nodeInfo.nodegroup),
                _buildNodeInfoRow('国内带宽', nodeInfo.china),
                _buildNodeInfoRow('过白', nodeInfo.toowhite ? '是' : '否'),
                _buildNodeInfoRow('经纬度', nodeInfo.coordinates),
                _buildNodeInfoRow('IPv6', nodeInfo.ipv6 != null ? nodeInfo.ipv6.toString() : '无'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('关闭',  style: TextStyle(fontFamily: "HarmonyOS Sans",fontSize: 14, fontWeight: FontWeight.w500)),
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
              style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: "HarmonyOS Sans"),
            ),
          ),
          Expanded(child: Text(value, style: TextStyle(fontFamily: "HarmonyOS Sans"))),
        ],
      ),
    );
  }

  // 生成节点标签
  List<Widget> _generateNodeTags(NodeData node) {
    final tags = <Widget>[];
    
    // 节点组标签
    if (node.nodegroup == 'user') {
      tags.add(_buildTag('免费', Colors.green));
    } else if (node.nodegroup == 'vip') {
      tags.add(_buildTag('会员', Colors.orange));
    }
    
    // 国内限速标签
    if (node.china == 'yes') {
      tags.add(_buildTag('国内限速', Colors.blue));
    } else if (node.china == 'no') {
      tags.add(_buildTag('国外限速', Colors.purple));
    }
    
    // 建站支持标签
    if (node.web == 'yes') {
      tags.add(_buildTag('允许建站', Colors.green));
    } else if (node.web == 'no') {
      tags.add(_buildTag('禁止建站', Colors.red));
    }
    
    // UDP支持标签
    if (node.udp == 'true') {
      tags.add(_buildTag('UDP支持', Colors.green));
    } else if (node.udp == 'false') {
      tags.add(_buildTag('UDP禁用', Colors.red));
    }
    
    return tags;
  }
  
  // 构建单个标签
  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      margin: const EdgeInsets.only(right: 6, top: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontFamily: "HarmonyOS Sans",
          fontWeight: FontWeight.w500,
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
              child: _nodes.isEmpty
                  ? const Center(
                      child: Text('暂无节点', style: TextStyle(fontFamily: "HarmonyOS Sans")),
                    )
                  : ListView.builder(
                      itemCount: _nodes.length,
                      itemBuilder: (context, index) {
                        final node = _nodes[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: ListTile(
                            leading: Icon(Icons.dns, size: 32, color: Theme.of(context).colorScheme.primary),
                            title: Text(node.name, style: TextStyle(fontFamily: "HarmonyOS Sans")),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('区域: ${node.area}', style: TextStyle(fontFamily: "HarmonyOS Sans")),
                                if (node.notes.isNotEmpty)
                                  Text(
                                    '备注: ${node.notes}',
                                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12, fontFamily: "HarmonyOS Sans"),
                                  ),
                                const SizedBox(height: 8),
                                UptimeChart(nodeName: node.name),
                                const SizedBox(height: 4),
                                Wrap(
                                  spacing: 4,
                                  runSpacing: 4,
                                  children: _generateNodeTags(node),
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