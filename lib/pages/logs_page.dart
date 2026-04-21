import 'dart:async';
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

  void _startStatusCheck() {
    _statusCheckTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) setState(() {});
    });
  }

  void _loadBufferedLogs() {
    final bufferedLogs = FrpcService.getLogBuffer();
    if (bufferedLogs.isNotEmpty) {
      setState(() {
        _logLines.addAll(bufferedLogs);
        if (_logLines.length > 1000) {
          _logLines = _logLines.sublist(_logLines.length - 1000);
        }
      });
    }
  }

  void _startLogStream() {
    _logSubscription = FrpcService.globalLogStream.stream.listen((logLine) {
      if (mounted) {
        setState(() {
          _logLines.add(logLine);
          if (_logLines.length > 1000) {
            _logLines = _logLines.sublist(_logLines.length - 1000);
          }
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

  void _clearLogs() {
    setState(() => _logLines.clear());
    FrpcService.clearLogs();
  }

  Color _getLogColor(String line) {
    if (line.contains('[ERROR]') || line.contains('失败') || line.contains('错误')) {
      return AppTheme.errorColor;
    } else if (line.contains('[WARN]')) {
      return AppTheme.warningColor;
    } else if (line.contains('[INFO]') || line.contains('启动成功') || line.contains('成功')) {
      return AppTheme.successColor;
    } else if (line.contains('[DEBUG]')) {
      return AppTheme.infoColor;
    }
    return const Color(0xFFBB86FC);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.borderColor),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.secondaryColor.withOpacity(0.06),
                  offset: const Offset(0, 8),
                  blurRadius: 24,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 标题栏
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceVariant.withOpacity(0.5),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppTheme.secondaryColor, AppTheme.accentColor],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.secondaryColor.withOpacity(0.3),
                              offset: const Offset(0, 2),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.article_rounded, size: 20, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'FRPC 日志',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      // 控制按钮
                      _LogControlButton(
                        icon: _autoScroll ? Icons.sync_rounded : Icons.sync_disabled_rounded,
                        color: _autoScroll ? AppTheme.primaryColor : AppTheme.textTertiary,
                        tooltip: _autoScroll ? '自动滚动: 开' : '自动滚动: 关',
                        onPressed: () => setState(() => _autoScroll = !_autoScroll),
                      ),
                      const SizedBox(width: 8),
                      _LogControlButton(
                        icon: Icons.delete_outline_rounded,
                        color: AppTheme.errorColor,
                        tooltip: '清空日志',
                        onPressed: _clearLogs,
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: AppTheme.borderColor),
                // 日志内容
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF3E3E42)),
                    ),
                    child: _logLines.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.event_note_rounded,
                                  size: 48,
                                  color: AppTheme.textTertiary.withOpacity(0.5),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  '等待 FRPC 日志输出...',
                                  style: TextStyle(
                                    color: AppTheme.textTertiary.withOpacity(0.7),
                                    fontFamily: AppTheme.fontFamilyMono,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.all(16),
                            itemCount: _logLines.length,
                            itemBuilder: (context, index) {
                              final line = _logLines[index];
                              return _LogLine(
                                lineNumber: index + 1,
                                content: line,
                                color: _getLogColor(line),
                              );
                            },
                          ),
                  ),
                ),
                // 状态栏
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceVariant.withOpacity(0.5),
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                  ),
                  child: Row(
                    children: [
                      // 状态指示
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: FrpcService.isFrpcProcessRunning()
                              ? AppTheme.successColor
                              : AppTheme.errorColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: (FrpcService.isFrpcProcessRunning()
                                      ? AppTheme.successColor
                                      : AppTheme.errorColor)
                                  .withOpacity(0.5),
                              offset: const Offset(0, 0),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        FrpcService.isFrpcProcessRunning() ? '正在运行' : '已停止',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: FrpcService.isFrpcProcessRunning()
                              ? AppTheme.successColor
                              : AppTheme.errorColor,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '共 ${_logLines.length} 行',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LogControlButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onPressed;

  const _LogControlButton({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: color),
        ),
      ),
    );
  }
}

class _LogLine extends StatelessWidget {
  final int lineNumber;
  final String content;
  final Color color;

  const _LogLine({
    required this.lineNumber,
    required this.content,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 44,
            child: Text(
              lineNumber.toString().padLeft(4, '0'),
              style: TextStyle(
                color: color.withOpacity(0.5),
                fontFamily: AppTheme.fontFamilyMono,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              content,
              style: TextStyle(
                color: color,
                fontFamily: AppTheme.fontFamilyMono,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
