import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/models.dart';
import '../services/api_service.dart';

class FrpcService {
  // 全局日志流
  static final StreamController<String> globalLogStream = StreamController<String>.broadcast();
  
  // 日志缓冲区，保存本次运行的所有日志
  static final List<String> _logBuffer = [];
  
  // 存储运行中的隧道
  static final Set<int> _runningTunnels = {};
  
  // 存储每个隧道对应的FRPC进程
  static final Map<int, Process> _tunnelProcesses = {};
  
  // 存储进程状态
  static bool _isProcessRunning = false;
  
  // 调试日志方法
  static void _debugLog(String message) {
    print('[DEBUG] $message');
  }
  
  // 获取运行中的隧道
  static Set<int> getRunningTunnels() {
    return _runningTunnels;
  }
  
  // 检查隧道是否运行
  static bool isTunnelRunning(int tunnelId) {
    return _runningTunnels.contains(tunnelId);
  }
  
  // 获取 FRPC 可执行文件路径
  static Future<File> get _frpcExecutable async {
    // 对于Windows平台，从应用安装目录读取frpc.exe
    if (Platform.isWindows) {
      // 获取当前可执行文件所在目录
      final executablePath = Platform.resolvedExecutable;
      final executableDir = Directory(executablePath).parent;
      return File('${executableDir.path}\\frpc.exe');
    }
    
    // 其他平台仍然使用AppData
    final directory = Directory(Platform.environment['APPDATA']!);
    final chmlFrpDir = Directory('${directory.path}\\chmlfrp');
    if (!chmlFrpDir.existsSync()) {
      chmlFrpDir.createSync(recursive: true);
    }
    return File('${chmlFrpDir.path}\\frpc.exe');
  }
  
  // 获取日志文件目录
  static Future<Directory> get _logDirectory async {
    final directory = Directory(Platform.environment['APPDATA']!);
    final chmlFrpDir = Directory('${directory.path}\\chmlfrp');
    final logDir = Directory('${chmlFrpDir.path}\\logs');
    if (!logDir.existsSync()) {
      logDir.createSync(recursive: true);
    }
    return logDir;
  }
  
  // 获取日志文件
  static Future<File> get _logFile async {
    final logDir = await _logDirectory;
    return File('${logDir.path}\\frpc.log');
  }
  
  // 初始化日志系统
  static Future<void> initializeLogs() async {
    try {
      final logFile = await _logFile;
      // 清空历史日志，只记录本次运行的日志
      if (logFile.existsSync()) {
        await logFile.writeAsString('');
      }
    } catch (e) {
      _debugLog('初始化日志系统失败: $e');
    }
  }
  
  // 写入日志到文件
  static Future<void> _writeLog(String logLine) async {
    try {
      // 添加到日志缓冲区
      _logBuffer.add(logLine);
      
      final logFile = await _logFile;
      // 确保文件存在
      if (!logFile.existsSync()) {
        logFile.createSync(recursive: true);
      }
      
      // 追加日志
      await logFile.writeAsString('$logLine\n', mode: FileMode.append);
      
      // 检查日志文件大小，超过限制则清理
      await _checkLogFileSize();
    } catch (e) {
      _debugLog('写入日志文件失败: $e');
    }
  }
  
  // 检查日志文件大小
  static Future<void> _checkLogFileSize() async {
    try {
      final logFile = await _logFile;
      if (logFile.existsSync()) {
        final size = logFile.lengthSync();
        // 限制日志文件大小为 10MB
        if (size > 10 * 1024 * 1024) {
          // 读取日志内容
          final content = await logFile.readAsString();
          final lines = content.split('\n').where((line) => line.isNotEmpty).toList();
          
          // 保留后一半的日志
          if (lines.length > 100) {
            final keepLines = lines.length ~/ 2;
            final newContent = lines.sublist(lines.length - keepLines).join('\n');
            await logFile.writeAsString(newContent);
          } else {
            // 如果日志行数较少但文件较大，清空文件
            await logFile.writeAsString('');
          }
        }
      }
    } catch (e) {
      _debugLog('检查日志文件大小失败: $e');
    }
  }
  
  // 获取日志缓冲区内容
  static List<String> getLogBuffer() {
    return List.from(_logBuffer);
  }
  
  // 清空日志
  static Future<void> clearLogs() async {
    try {
      final logFile = await _logFile;
      if (logFile.existsSync()) {
        await logFile.writeAsString('');
      }
      // 清空日志缓冲区
      _logBuffer.clear();
    } catch (e) {
      _debugLog('清空日志文件失败: $e');
    }
  }
  
  // 检查 FRPC 是否已安装
  static Future<bool> isFrpcInstalled() async {
    final frpcExec = await _frpcExecutable;
    return frpcExec.existsSync();
  }

  // 获取 FRPC 版本
  static Future<String> getFrpcVersion() async {
    try {
      final frpcExec = await _frpcExecutable;
      if (!frpcExec.existsSync()) {
        return '未安装';
      }

      // 运行 frpc -v 命令获取版本信息
      final result = await Process.run(
        frpcExec.path,
        ['-v'],
        runInShell: true,
      );

      if (result.exitCode == 0) {
        final output = result.stdout.toString().trim();
        // 从输出中提取版本号
        final versionMatch = RegExp(r'frpc version ([\d\.]+)').firstMatch(output);
        if (versionMatch != null) {
          return versionMatch.group(1)!;
        }
        return output;
      } else {
        return '获取失败';
      }
    } catch (e) {
      _debugLog('获取 FRPC 版本失败: $e');
      return '未知';
    }
  }
  
  // 自动安装 FRPC
  static Future<bool> autoInstallFrpc({
    required Function(double) onProgress,
    required Function(String) onStatus,
  }) async {
    try {
      onStatus('正在下载 FRPC...');
      
      // 构建下载 URL (使用 GitHub 最新版本)
      final downloadUrl = 'https://github.com/fatedier/frp/releases/latest/download/frpc_windows_amd64.exe';
      
      // 下载文件
      final response = await http.get(Uri.parse(downloadUrl));
      
      if (response.statusCode == 200) {
        onStatus('正在安装 FRPC...');
        
        // 保存文件
        final frpcExec = await _frpcExecutable;
        await frpcExec.writeAsBytes(response.bodyBytes);
        
        onStatus('安装完成');
        onProgress(1.0);
        return true;
      } else {
        onStatus('下载失败: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      onStatus('安装失败: $e');
      return false;
    }
  }
  
  // 启动隧道
  static Future<TunnelStatus> startTunnel(int tunnelId, Function(bool)? onStatusChange) async {
    try {
      // 检查 FRPC 是否已安装
      if (!await isFrpcInstalled()) {
        final errorMsg = 'FRPC 未安装，无法启动隧道';
        globalLogStream.add(errorMsg);
        await _writeLog(errorMsg);
        return TunnelStatus.failed;
      }
      
      // 获取用户的隧道列表
      final tunnels = await ApiService.getTunnelList();
      if (tunnels.isEmpty) {
        final errorMsg = '未获取到隧道列表，无法启动隧道';
        globalLogStream.add(errorMsg);
        await _writeLog(errorMsg);
        return TunnelStatus.failed;
      }
      
      // 查找指定的隧道
      final tunnel = tunnels.firstWhere(
        (t) => t.id == tunnelId,
        orElse: () => throw Exception('Tunnel not found'),
      );
      
      // 启动 FRPC 进程（使用命令行参数格式，传入隧道ID）
      await runFrpc(tunnelId);
      
      // 添加到运行中的隧道
      _runningTunnels.add(tunnelId);
      
      // 通知状态变化
      onStatusChange?.call(true);
      
      return TunnelStatus.started;
    } catch (e) {
      final errorMsg = '隧道 $tunnelId 启动失败: $e';
      globalLogStream.add(errorMsg);
      await _writeLog(errorMsg);
      // 即使启动失败，也从进程映射中移除
      _tunnelProcesses.remove(tunnelId);
      // 更新进程状态
      _isProcessRunning = _tunnelProcesses.isNotEmpty;
      return TunnelStatus.failed;
    }
  }
  
  // 生成默认配置文件
  static Future<File> generateDefaultConfig() async {
    final directory = Directory(Platform.environment['APPDATA']!);
    final chmlFrpDir = Directory('${directory.path}\\chmlfrp');
    final configDir = Directory('${chmlFrpDir.path}\\configs');
    if (!configDir.existsSync()) {
      configDir.createSync(recursive: true);
    }
    
    final token = ApiService.userToken;
    
    final configContent = '''
[common]
server_addr = panel.chmlfrp.net
server_port = 7000
${token.isNotEmpty ? 'token = $token' : ''}

[example]
type = tcp
local_ip = 127.0.0.1
local_port = 80
remote_port = 6000
''';
    
    final configFile = File('${configDir.path}\\default.ini');
    await configFile.writeAsString(configContent);
    return configFile;
  }
  
  // 停止隧道
  static Future<TunnelStatus> stopTunnel(int tunnelId, Function(bool)? onStatusChange) async {
    try {
      // 检查该隧道是否有对应的进程
      if (_tunnelProcesses.containsKey(tunnelId)) {
        // 停止该隧道的进程
        final process = _tunnelProcesses[tunnelId];
        if (process != null) {
          process.kill();
          await process.exitCode;
        }
        // 从进程映射中移除
        _tunnelProcesses.remove(tunnelId);
      }
      
      // 从运行中的隧道中移除
      _runningTunnels.remove(tunnelId);
      
      // 更新进程状态
      _isProcessRunning = _tunnelProcesses.isNotEmpty;
      
      // 通知状态变化
      onStatusChange?.call(false);
      
      return TunnelStatus.stopped;
    } catch (e) {
      final errorMsg = '隧道 $tunnelId 停止失败: $e';
      globalLogStream.add(errorMsg);
      await _writeLog(errorMsg);
      return TunnelStatus.failed;
    }
  }
  
  // 获取所有隧道日志文件
  static Future<List<File>> getAllTunnelLogFiles() async {
    final logDir = await _logDirectory;
    final logFiles = logDir.listSync().whereType<File>().toList();
    // 按修改时间排序，最新的在前
    logFiles.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));
    return logFiles;
  }
  
  // 生成隧道配置文件
  static Future<File> generateTunnelConfig(TunnelInfo tunnel) async {
    final directory = Directory(Platform.environment['APPDATA']!);
    final chmlFrpDir = Directory('${directory.path}\\chmlfrp');
    final configDir = Directory('${chmlFrpDir.path}\\configs');
    if (!configDir.existsSync()) {
      configDir.createSync(recursive: true);
    }
    
    final token = ApiService.userToken;
    
    final configContent = '''
[common]
server_addr = ${tunnel.ip}
server_port = 7000
${token.isNotEmpty ? 'token = $token' : ''}

[${tunnel.name}]
type = ${tunnel.type}
local_ip = ${tunnel.localip}
local_port = ${tunnel.nport}
${['http', 'https'].contains(tunnel.type) ? 'custom_domains = ${tunnel.dorp}' : 'remote_port = ${tunnel.dorp}'}
''';
    
    final configFile = File('${configDir.path}\\tunnel_${tunnel.id}.ini');
    await configFile.writeAsString(configContent);
    return configFile;
  }

  // 运行 FRPC 进程
  static Future<Process> runFrpc(int tunnelId) async {
    final frpcExec = await _frpcExecutable;
    
    // 检查可执行文件是否存在
    if (!frpcExec.existsSync()) {
      final errorMsg = 'FRPC 可执行文件不存在: ${frpcExec.path}';
      globalLogStream.add(errorMsg);
      await _writeLog(errorMsg);
      throw Exception('FRPC executable not found');
    }
    
    // 获取用户token
    final token = ApiService.userToken;
    if (token.isEmpty) {
      final errorMsg = '未获取到用户token，无法启动FRPC';
      globalLogStream.add(errorMsg);
      await _writeLog(errorMsg);
      throw Exception('User token not found');
    }
    
    // 启动 FRPC 进程
    try {
      final process = await Process.start(
        frpcExec.path,
        ['-u', token, '-p', tunnelId.toString()],
      );
      
      // 更新进程状态
      _tunnelProcesses[tunnelId] = process;
      _isProcessRunning = true;
      
      // 添加启动信息日志
      final startMsg = '启动隧道 $tunnelId 的 FRPC 进程...';
      globalLogStream.add(startMsg);
      await _writeLog(startMsg);
      
      // 处理标准输出
      process.stdout.transform(utf8.decoder).listen((output) {
        final trimmedOutput = output.trim();
        globalLogStream.add(trimmedOutput);
        // 持久化存储
        _writeLog(trimmedOutput);
      });
      
      // 处理标准错误
      process.stderr.transform(utf8.decoder).listen((error) {
        final trimmedError = error.trim();
        globalLogStream.add(trimmedError);
        // 持久化存储
        _writeLog(trimmedError);
      });
      
      // 处理进程退出
      process.exitCode.then((code) {
        // 从进程映射中移除
        _tunnelProcesses.remove(tunnelId);
        // 从运行中的隧道中移除
        _runningTunnels.remove(tunnelId);
        // 更新进程状态
        _isProcessRunning = _tunnelProcesses.isNotEmpty;
      });
      
      return process;
    } catch (e) {
      final errorMsg = '启动 FRPC 进程失败: $e';
      globalLogStream.add(errorMsg);
      await _writeLog(errorMsg);
      throw e;
    }
  }
  
  // 获取 FRPC 进程状态
  static bool isFrpcProcessRunning() {
    return _isProcessRunning;
  }
  
  // 获取所有隧道的进程
  static Map<int, Process> getAllTunnelProcesses() {
    return _tunnelProcesses;
  }
  
  // 获取指定隧道的进程
  static Process? getTunnelProcess(int tunnelId) {
    return _tunnelProcesses[tunnelId];
  }
  
  // 停止所有 FRPC 进程
  static Future<void> stopAllFrpcProcesses() async {
    try {
      // 停止所有隧道的进程
      for (final tunnelId in _tunnelProcesses.keys.toList()) {
        final process = _tunnelProcesses[tunnelId];
        if (process != null) {
          process.kill();
          await process.exitCode;
        }
      }
      
      // 在 Windows 上使用 taskkill 命令停止所有 frpc.exe 进程
      await Process.run('taskkill', ['/F', '/IM', 'frpc.exe'], runInShell: true);
      
      // 更新进程状态
      _tunnelProcesses.clear();
      _runningTunnels.clear();
      _isProcessRunning = false;
    } catch (e) {
      final errorMsg = '停止 FRPC 进程失败: $e';
      globalLogStream.add(errorMsg);
      await _writeLog(errorMsg);
    }
  }
}

// 配置文件管理
class ConfigManager {
  // 获取配置目录
  static Future<Directory> get configDirectory async {
    final directory = Directory(Platform.environment['APPDATA']!);
    final chmlFrpDir = Directory('${directory.path}\\chmlfrp');
    final configDir = Directory('${chmlFrpDir.path}\\configs');
    if (!configDir.existsSync()) {
      configDir.createSync(recursive: true);
    }
    return configDir;
  }

  // 获取多环境配置
  static Future<File> getConfigFile(String environment) async {
    final configDir = await configDirectory;
    return File('${configDir.path}\\${environment}.ini');
  }

  // 生成多环境配置
  static Future<bool> generateEnvironmentConfig(
    String environment,
    String serverAddr,
    int serverPort,
    List<TunnelInfo> tunnels,
  ) async {
    final configFile = await getConfigFile(environment);
    final configDir = await configDirectory;
    
    if (!configDir.existsSync()) {
      configDir.createSync(recursive: true);
    }

    final token = ApiService.userToken;

    final configContent = StringBuffer();
    configContent.writeln('[common]');
    configContent.writeln('server_addr = $serverAddr');
    configContent.writeln('server_port = $serverPort');
    configContent.writeln('token = $token');
    configContent.writeln();

    for (final tunnel in tunnels) {
      configContent.writeln('[${tunnel.name}]');
      configContent.writeln('type = ${tunnel.type}');
      configContent.writeln('local_ip = ${tunnel.localip}');
      configContent.writeln('local_port = ${tunnel.nport}');
      if (['http', 'https'].contains(tunnel.type)) {
        configContent.writeln('custom_domains = ${tunnel.dorp}');
      } else {
        configContent.writeln('remote_port = ${tunnel.dorp}');
      }
      configContent.writeln();
    }

    await configFile.writeAsString(configContent.toString());
    return true;
  }

  // 读取配置文件
  static Future<Map<String, dynamic>> readConfig(String environment) async {
    final configFile = await getConfigFile(environment);
    if (!configFile.existsSync()) {
      return {};
    }

    final content = await configFile.readAsString();
    final lines = content.split('\n');
    final config = <String, dynamic>{};
    String currentSection = '';

    for (final line in lines) {
      final trimmedLine = line.trim();
      if (trimmedLine.startsWith('[') && trimmedLine.endsWith(']')) {
        currentSection = trimmedLine.substring(1, trimmedLine.length - 1);
        config[currentSection] = <String, String>{};
      } else if (trimmedLine.contains('=') && currentSection.isNotEmpty) {
        final parts = trimmedLine.split('=');
        if (parts.length >= 2) {
          final key = parts[0].trim();
          final value = parts.sublist(1).join('=').trim();
          (config[currentSection] as Map<String, String>)[key] = value;
        }
      }
    }

    return config;
  }

  // 保存配置
  static Future<bool> saveConfig(String environment, Map<String, dynamic> config) async {
    final configFile = await getConfigFile(environment);
    final configDir = await configDirectory;
    
    if (!configDir.existsSync()) {
      configDir.createSync(recursive: true);
    }

    final configContent = StringBuffer();
    
    config.forEach((section, values) {
      if (values is Map<String, String>) {
        configContent.writeln('[$section]');
        values.forEach((key, value) {
          configContent.writeln('$key = $value');
        });
        configContent.writeln();
      }
    });

    await configFile.writeAsString(configContent.toString());
    return true;
  }

  // 导入配置
  static Future<bool> importConfig(File configFile, String environment) async {
    if (!configFile.existsSync()) {
      return false;
    }

    final content = await configFile.readAsString();
    final targetConfigFile = await getConfigFile(environment);
    await targetConfigFile.writeAsString(content);
    return true;
  }

  // 导出配置
  static Future<File> exportConfig(String environment) async {
    final configFile = await getConfigFile(environment);
    if (!configFile.existsSync()) {
      throw Exception('配置文件不存在');
    }

    final exportDir = Directory('${Platform.environment['USERPROFILE']!}\\Downloads');
    final exportFile = File('${exportDir.path}\\chmlfrp_${environment}_${DateTime.now().millisecondsSinceEpoch}.ini');
    
    await exportFile.writeAsBytes(await configFile.readAsBytes());
    return exportFile;
  }

  // 检查配置是否存在
  static Future<bool> hasConfig(String environment) async {
    final configFile = await getConfigFile(environment);
    return configFile.existsSync();
  }

  // 删除配置
  static Future<bool> deleteConfig(String environment) async {
    final configFile = await getConfigFile(environment);
    if (configFile.existsSync()) {
      await configFile.delete();
      return true;
    }
    return false;
  }
}
