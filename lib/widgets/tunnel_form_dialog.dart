import 'dart:math';
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/api_service.dart';

class TunnelFormDialog extends StatefulWidget {
  final TunnelInfo? tunnel;

  const TunnelFormDialog({super.key, this.tunnel});

  @override
  State<TunnelFormDialog> createState() => _TunnelFormDialogState();
}

class _TunnelFormDialogState extends State<TunnelFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nodeNameController = TextEditingController();
  final _tunnelNameController = TextEditingController();
  final _typeController = TextEditingController(text: 'tcp');
  final _localIpController = TextEditingController(text: '127.0.0.1');
  final _localPortController = TextEditingController();
  final _remotePortController = TextEditingController();
  
  List<NodeData> _nodes = [];
  bool _isLoading = false;
  bool _isSubmitting = false;
  bool _useRandomPort = true;

  // 隧道类型列表
  static const List<String> _tunnelTypes = ['tcp', 'udp', 'http', 'https'];

  // 表单装饰器
  static const InputDecoration _inputDecoration = InputDecoration(
    border: OutlineInputBorder(),
  );

  // IP地址验证正则表达式
  static final RegExp _ipRegex = RegExp(r'^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$');

  // 验证端口号
  String? _validatePort(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入端口号';
    }
    final port = int.tryParse(value);
    if (port == null || port < 1 || port > 65535) {
      return '请输入有效的端口号（1-65535）';
    }
    return null;
  }

  // 验证IP地址
  String? _validateIp(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入本地IP';
    }
    if (!_ipRegex.hasMatch(value)) {
      return '请输入有效的IP地址';
    }
    return null;
  }

  // 验证必填项
  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '请$fieldName';
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _loadNodes();
    
    // 如果是编辑模式，填充现有数据
    if (widget.tunnel != null) {
      _nodeNameController.text = widget.tunnel!.node;
      _tunnelNameController.text = widget.tunnel!.name;
      _typeController.text = widget.tunnel!.type;
      _localIpController.text = widget.tunnel!.localip;
      _localPortController.text = widget.tunnel!.nport.toString();
      _remotePortController.text = widget.tunnel!.dorp;
    }
  }

  @override
  void dispose() {
    _nodeNameController.dispose();
    _tunnelNameController.dispose();
    _typeController.dispose();
    _localIpController.dispose();
    _localPortController.dispose();
    _remotePortController.dispose();
    super.dispose();
  }

  // 加载节点列表
  Future<void> _loadNodes() async {
    if (_isLoading) return; // 防止重复加载
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final nodes = await ApiService.getNodesDataList();
      
      if (nodes.isEmpty) {
        // 显示权限不足的提示
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('权限不足，无法查看节点列表')),
          );
        }
      }
      
      // 根据用户等级筛选节点
      final filteredNodes = _filterNodesByUserLevel(nodes);
      setState(() {
        _nodes = filteredNodes;
        _isLoading = false;
      });
    } catch (error) {
      // 处理网络错误
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加载节点失败: $error')),
        );
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 根据用户等级筛选节点
  List<NodeData> _filterNodesByUserLevel(List<NodeData> nodes) {
    final userInfo = ApiService.userInfo;
    if (userInfo == null) {
      return [];
    }
    
    final userLevel = userInfo.usergroup;
    // 筛选逻辑：用户只能看到与自己等级相同或更低等级的节点
    // 这里假设节点的nodegroup字段表示节点的等级要求
    return nodes.where((node) {
      // 实现等级比较逻辑
      // 这里需要根据实际的等级定义来实现
      // 暂时简单处理，假设用户等级和节点分组可以直接比较
      final allowed = _isUserLevelAllowed(userLevel, node.nodegroup);
      return allowed;
    }).toList();
  }

  // 检查用户等级是否允许使用该节点
  bool _isUserLevelAllowed(String userLevel, String nodeGroup) {
    // 特殊处理：免费用户只能使用 nodegroup 为 user 的节点
    if (userLevel == '免费用户') {
      final allowed = nodeGroup == 'user';
      return allowed;
    }
    
    // 定义等级优先级（数字越小等级越高）
    final levelPriority = {
      'admin': 0,
      'vip3': 1,
      'vip2': 2,
      'vip1': 3,
      'user': 4,
      '免费用户': 5,
      'default': 6,
    };
    
    final userPriority = levelPriority[userLevel] ?? levelPriority['default']!;
    final nodePriority = levelPriority[nodeGroup] ?? levelPriority['default']!;
    
    // 用户等级优先级小于等于节点等级优先级时允许使用
    return userPriority <= nodePriority;
  }

  // 提交表单
  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() != true) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      String result;
      String remotePort;
      if (_useRandomPort) {
        // 生成一个1到65535之间的随机端口号
        final random = Random();
        remotePort = (random.nextInt(65534) + 1).toString();
      } else {
        remotePort = _remotePortController.text;
      }
      
      if (widget.tunnel == null) {
        // 创建新隧道
        result = await ApiService.createTunnel(
          _tunnelNameController.text,
          _nodeNameController.text,
          _typeController.text,
          _localIpController.text,
          _localPortController.text,
          remotePort,
        );
      } else {
        // 编辑现有隧道
        result = await ApiService.updateTunnel(
          widget.tunnel!,
          _tunnelNameController.text,
          _nodeNameController.text,
          _typeController.text,
          _localIpController.text,
          _localPortController.text,
          remotePort,
        );
      }

      if (mounted) {
        if (result.contains('成功')) {
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('操作失败: $result')),
          );
        }
      }
    } catch (error) {
      // 处理网络错误
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('操作失败: $error')),
        );
      }
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.tunnel == null ? '创建隧道' : '编辑隧道'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 节点选择
              _isLoading
                  ? const CircularProgressIndicator()
                  : DropdownButtonFormField<String>(
                      initialValue: _nodeNameController.text.isNotEmpty ? _nodeNameController.text : null,
                      decoration: _inputDecoration.copyWith(labelText: '节点'),
                      items: _nodes.map((node) {
                        return DropdownMenuItem(
                          value: node.name,
                          child: Text(node.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          _nodeNameController.text = value;
                        }
                      },
                      validator: (value) => _validateRequired(value, '选择节点'),
                    ),
              const SizedBox(height: 16),

              // 隧道名称
              TextFormField(
                controller: _tunnelNameController,
                decoration: _inputDecoration.copyWith(labelText: '隧道名称'),
                validator: (value) => _validateRequired(value, '输入隧道名称'),
              ),
              const SizedBox(height: 16),

              // 隧道类型
              DropdownButtonFormField<String>(
                initialValue: _typeController.text,
                decoration: _inputDecoration.copyWith(labelText: '类型'),
                items: _tunnelTypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.toUpperCase()),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    _typeController.text = value;
                  }
                },
                validator: (value) => _validateRequired(value, '选择隧道类型'),
              ),
              const SizedBox(height: 16),

              // 本地IP
              TextFormField(
                controller: _localIpController,
                decoration: _inputDecoration.copyWith(labelText: '本地IP'),
                validator: _validateIp,
              ),
              const SizedBox(height: 16),

              // 本地端口
              TextFormField(
                controller: _localPortController,
                decoration: _inputDecoration.copyWith(labelText: '本地端口'),
                keyboardType: TextInputType.number,
                validator: _validatePort,
              ),
              const SizedBox(height: 16),

              // 远程端口
              Column(
                children: [
                  TextFormField(
                    controller: _remotePortController,
                    decoration: _inputDecoration.copyWith(labelText: '远程端口'),
                    keyboardType: TextInputType.number,
                    enabled: !_useRandomPort,
                    validator: (value) {
                      if (_useRandomPort) {
                        return null;
                      }
                      return _validatePort(value);
                    },
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    title: const Text('使用随机端口'),
                    value: _useRandomPort,
                    onChanged: (value) {
                      setState(() {
                        _useRandomPort = value;
                      });
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('取消'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submitForm,
          child: _isSubmitting
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : Text(widget.tunnel == null ? '创建' : '保存'),
        ),
      ],
    );
  }
}
