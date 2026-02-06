import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import '../services/frpc_service.dart';
import '../theme/app_theme.dart';
import '../utils/animation_utils.dart';

class LogsPage extends StatefulWidget {
  const LogsPage({super.key});

  @override
  State<LogsPage> createState() => _LogsPageState();
}

class _LogsPageState extends State<LogsPage> with SingleTickerProviderStateMixin {
  // 实时日志相关
  List<String> _logLines = [];
  bool _autoScroll = true;
  final ScrollController _scrollController = ScrollController();
  StreamSubscription? _logSubscription;
  Timer? _statusCheckTimer;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _loadBufferedLogs();
    _startLogStream();
    _startStatusCheck();
    // 初始化动画
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = AnimationUtils.createFadeAnimation(_animationController);
    _animationController.forward();
  }

  @override
  void dispose() {
    _logSubscription?.cancel();
    _statusCheckTimer?.cancel();
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // 启动状态检查定时器
  void _startStatusCheck() {
    // 每1秒检查一次进程状态
    _statusCheckTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          // 状态会通过FrpcService.isFrpcProcessRunning()自动更新
        });
      }
    });
  }

  // 加载缓冲的日志
  void _loadBufferedLogs() {
    // 从 FrpcService 获取缓冲区中的日志
    final bufferedLogs = FrpcService.getLogBuffer();
    if (bufferedLogs.isNotEmpty) {
      setState(() {
        _logLines.addAll(bufferedLogs);
        // 限制日志行数，避免内存溢出
        if (_logLines.length > 1000) {
          _logLines = _logLines.sublist(_logLines.length - 1000);
        }
      });
    }
  }

  // 启动日志流监听
  void _startLogStream() {
    // 监听全局日志流
    _logSubscription = FrpcService.globalLogStream.stream.listen((logLine) {
      if (mounted) {
        setState(() {
          _logLines.add(logLine);
          // 限制日志行数，避免内存溢出
          if (_logLines.length > 1000) {
            _logLines = _logLines.sublist(_logLines.length - 1000);
          }
          
          // 自动滚动到底部
          if (_autoScroll) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (_scrollController.hasClients) {
                _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
              }
            });
          }
        });
      }
    });
  }

  // 清空日志
  void _clearLogs() {
    setState(() {
      _logLines.clear();
    });
    // 清空持久化日志
    FrpcService.clearLogs();
  }

  // 构建日志行
  Widget _buildLogLine(String line, int index) {
    // 分析日志级别并应用不同颜色
    Color textColor = const Color(0xFFBB86FC); // 默认紫色
    if (line.contains('[ERROR]')) {
      textColor = AppTheme.errorColor;
    } else if (line.contains('[WARN]')) {
      textColor = AppTheme.warningColor;
    } else if (line.contains('[INFO]')) {
      textColor = AppTheme.successColor;
    } else if (line.contains('启动成功') || line.contains('成功')) {
      textColor = AppTheme.successColor;
    } else if (line.contains('失败') || line.contains('错误')) {
      textColor = AppTheme.errorColor;
    }

    return FadeTransition(
      opacity: Tween<double>(begin: 0.8, end: 1.0).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(index * 0.01, 1.0, curve: Curves.easeOut),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 行号
            SizedBox(
              width: 40,
              child: Text(
                '${index + 1}'.padLeft(4, '0'),
                style: TextStyle(
                  color: Color(0xFF6B7280),
                  fontFamily: AppTheme.fontFamilyMono,
                  fontSize: 12,
                ),
              ),
            ),
            // 日志内容
            Expanded(
              child: Text(
                line,
                style: TextStyle(
                  color: textColor,
                  fontFamily: AppTheme.fontFamilyMono,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Card(
            elevation: 0,
            color: AppTheme.surfaceColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
              side: BorderSide(color: AppTheme.borderColor),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 标题栏
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppTheme.secondaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                            ),
                            child: const Icon(Icons.article, size: 20, color: AppTheme.secondaryColor),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'FRPC 日志',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: "HarmonyOS Sans",
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          LogControlButton(
                            icon: _autoScroll ? Icons.autorenew : Icons.pause_circle_outline,
                            color: _autoScroll ? AppTheme.primaryColor : AppTheme.textTertiary,
                            tooltip: _autoScroll ? '自动滚动: 开启' : '自动滚动: 关闭',
                            onPressed: () {
                              setState(() {
                                _autoScroll = !_autoScroll;
                              });
                            },
                          ),
                          const SizedBox(width: 8),
                          LogControlButton(
                            icon: Icons.clear,
                            color: AppTheme.errorColor,
                            tooltip: '清空日志',
                            onPressed: _clearLogs,
                          ),
                          const SizedBox(width: 8),
                          LogControlButton(
                            icon: Icons.copy,
                            color: AppTheme.infoColor,
                            tooltip: '复制日志',
                            onPressed: () {
                              // TODO: 实现复制日志功能
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // 日志内容
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                        border: Border.all(
                          color: const Color(0xFF3E3E42),
                          width: 1,
                        ),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: _logLines.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.event_note, size: 48, color: Color(0xFF6B7280)),
                                  const SizedBox(height: 16),
                                  Text(
                                    '等待FRPC日志输出...',
                                    style: TextStyle(
                                      color: AppTheme.textTertiary,
                                      fontFamily: AppTheme.fontFamilyMono,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              controller: _scrollController,
                              itemCount: _logLines.length,
                              itemBuilder: (context, index) {
                                return _buildLogLine(_logLines[index], index);
                              },
                            ),
                    ),
                  ),
                  
                  // 状态栏
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Text(
                            '状态: ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontFamily: "HarmonyOS Sans",
                            ),
                          ),
                          Text(
                            FrpcService.isFrpcProcessRunning() ? '正在运行' : '已停止',
                            style: TextStyle(
                              color: FrpcService.isFrpcProcessRunning() ? AppTheme.successColor : AppTheme.errorColor,
                              fontFamily: "HarmonyOS Sans",
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '行数: ${_logLines.length}',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                          fontFamily: "HarmonyOS Sans",
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
    );
  }
}

// 日志控制按钮组件
class LogControlButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onPressed;

  const LogControlButton({
    super.key,
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
          ),
          child: Icon(icon, size: 20, color: color),
        ),
      ),
    );
  }
}
