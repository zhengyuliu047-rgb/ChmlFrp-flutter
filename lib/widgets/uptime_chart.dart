import 'package:flutter/material.dart';
import '../services/api_service.dart';

class UptimeChart extends StatefulWidget {
  final String nodeName;
  final double width;
  final double height;

  const UptimeChart({
    super.key,
    required this.nodeName,
    this.width = double.infinity,
    this.height = 30,
  });

  @override
  State<UptimeChart> createState() => _UptimeChartState();
}

class _UptimeChartState extends State<UptimeChart> {
  List<double> _uptimeData = [];
  double _overallUptime = 0;
  bool _isLoading = true;
  String _errorMessage = '';
  bool _isUp = true;

  @override
  void initState() {
    super.initState();
    _loadUptimeData();
  }

  Future<void> _loadUptimeData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      // 从 API 获取节点在线率数据
      final uptimeData = await ApiService.getNodeUptime(
        time: 90, // 获取90天的数据
        node: widget.nodeName,
      );

      if (uptimeData != null && uptimeData['state'] == 'success') {
        // 处理 API 返回的数据
        final List<dynamic> dataList = uptimeData['data'] ?? [];
        
        if (dataList.isNotEmpty) {
          final Map<String, dynamic> nodeData = dataList[0];
          final List<dynamic> historyUptime = nodeData['history_uptime'] ?? [];
          
          // 提取在线率数据
          _uptimeData = historyUptime.map<double>((item) {
            return (item['uptime'] ?? 100.0).toDouble();
          }).toList();

          // 提取节点状态
          final String nodeState = nodeData['state'] ?? 'online';
          _isUp = nodeState == 'online';

          // 计算总体在线率
          if (_uptimeData.isNotEmpty) {
            _overallUptime = _uptimeData.reduce((a, b) => a + b) / _uptimeData.length;
          } else {
            _overallUptime = 100.0;
          }
        } else {
          // 没有数据
          _errorMessage = '暂无在线率数据';
          _uptimeData = List.generate(90, (index) => 98.0);
          _overallUptime = 98.0;
          _isUp = true;
        }
      } else {
        // API 返回错误
        _errorMessage = '无法加载在线率数据';
        // 使用默认数据避免界面空白
        _uptimeData = List.generate(90, (index) => 98.0);
        _overallUptime = 98.0;
        _isUp = true;
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = '无法加载在线率数据';
        // 使用默认数据避免界面空白
        _uptimeData = List.generate(90, (index) => 98.0);
        _overallUptime = 98.0;
        _isUp = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          // 总体在线率百分比
          Container(
            width: 80,
            child: Text(
              _isLoading ? '加载中...' : '${_overallUptime.toStringAsFixed(4)}%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: _isUp ? Colors.green : Colors.red,
                fontFamily: "HarmonyOS Sans",
              ),
            ),
          ),
          
          // 在线率条形图
          Expanded(
            child: _isLoading
                ? const Center(child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)))
                : _errorMessage.isNotEmpty
                    ? Text(
                        _errorMessage,
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                          fontFamily: "HarmonyOS Sans",
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: _uptimeData.map((uptime) {
                          Color barColor;
                          if (uptime >= 95) {
                            barColor = Colors.green;
                          } else if (uptime >= 85) {
                            barColor = Colors.yellow;
                          } else {
                            barColor = Colors.red;
                          }

                          return Expanded(
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 0.5),
                              height: 12,
                              decoration: BoxDecoration(
                                color: barColor,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
          ),
          
          // 节点状态指示器
          Container(
            margin: const EdgeInsets.only(left: 8),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: _isUp ? Colors.green : Colors.red,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: _isUp ? Colors.green.withOpacity(0.5) : Colors.red.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  _isUp ? 'Up' : 'Down',
                  style: TextStyle(
                    fontSize: 12,
                    color: _isUp ? Colors.green : Colors.red,
                    fontFamily: "HarmonyOS Sans",
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
