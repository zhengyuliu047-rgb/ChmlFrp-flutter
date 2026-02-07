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
  final _bandDomainController = TextEditingController();
  
  List<NodeData> _nodes = [];
  bool _isLoading = false;
  bool _isSubmitting = false;
  bool _encryption = false;
  bool _compression = false;

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
    _bandDomainController.dispose();
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
            const SnackBar(content: Text('权限不足，无法查看节点列表', style: TextStyle(fontFamily: "HarmonyOS Sans"))),
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
          SnackBar(content: Text('加载节点失败: $error', style: TextStyle(fontFamily: "HarmonyOS Sans"))),
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
      int? remotePort;
      if (_remotePortController.text.isNotEmpty) {
        remotePort = int.tryParse(_remotePortController.text);
      }
      
      int localPort = int.parse(_localPortController.text);
      String bandDomain = _bandDomainController.text;
      
      if (widget.tunnel == null) {
        // 创建新隧道
        final result = await ApiService.createTunnel(
          _tunnelNameController.text,
          _nodeNameController.text,
          _typeController.text,
          _localIpController.text,
          localPort,
          remotePort,
          bandDomain.isNotEmpty ? bandDomain : null,
          _encryption,
          _compression,
          null
        );

        if (mounted) {
          if (result != null && result['code'] == 200) {
            Navigator.pop(context, true);
          } else {
            String errorMsg = result?['msg'] ?? '创建失败';
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('操作失败: $errorMsg', style: TextStyle(fontFamily: "HarmonyOS Sans"))),
            );
          }
        }
      } else {
        // 编辑现有隧道 - 暂时保持原有实现
        String result = await ApiService.updateTunnel(
          widget.tunnel!,
          _tunnelNameController.text,
          _nodeNameController.text,
          _typeController.text,
          _localIpController.text,
          _localPortController.text,
          _remotePortController.text,
        );

        if (mounted) {
          if (result.contains('成功')) {
            Navigator.pop(context, true);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('操作失败: $result', style: TextStyle(fontFamily: "HarmonyOS Sans"))),
            );
          }
        }
      }
    } catch (error) {
      // 处理网络错误
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('操作失败: $error', style: TextStyle(fontFamily: "HarmonyOS Sans"))),
        );
      }
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  // 生成随机端口
  void _generateRandomPort() {
    final random = Random();
    // 生成 10000-65535 之间的随机端口
    final port = 10000 + random.nextInt(55536);
    setState(() {
      _remotePortController.text = port.toString();
    });
  }

  // 显示节点选择对话框
  Future<void> _showNodeSelectionDialog() async {
    final selectedNode = await showDialog<NodeData>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('选择节点', style: TextStyle(fontFamily: "HarmonyOS Sans")),
          content: SizedBox(
            width: 400,
            height: 300,
            child: ListView.builder(
              itemCount: _nodes.length,
              itemBuilder: (context, index) {
                final node = _nodes[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    title: Text(node.name, style: TextStyle(fontFamily: "HarmonyOS Sans")),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('区域: ${node.area}', style: TextStyle(fontFamily: "HarmonyOS Sans")),
                        Wrap(
                          spacing: 4,
                          runSpacing: 2,
                          children: _generateNodeTags(node),
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.pop(context, node);
                    },
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('取消', style: TextStyle(fontFamily: "HarmonyOS Sans")),
            ),
          ],
        );
      },
    );
    
    if (selectedNode != null) {
      setState(() {
        _nodeNameController.text = selectedNode.name;
      });
    }
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
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      margin: const EdgeInsets.only(right: 4, top: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontFamily: "HarmonyOS Sans",
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.tunnel == null ? '创建隧道' : '编辑隧道', style: TextStyle(fontFamily: "HarmonyOS Sans")),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 节点选择
              _isLoading
                  ? const CircularProgressIndicator()
                  : GestureDetector(
                      onTap: _showNodeSelectionDialog,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _nodeNameController.text.isNotEmpty 
                                ? _nodeNameController.text 
                                : '点击选择节点',
                              style: TextStyle(
                                fontFamily: "HarmonyOS Sans",
                                color: _nodeNameController.text.isEmpty ? Colors.grey : null,
                              ),
                            ),
                            Icon(Icons.arrow_drop_down),
                          ],
                        ),
                      ),
                    ),
              const SizedBox(height: 16),

              // 一行两个字段的布局
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _tunnelNameController,
                      decoration: _inputDecoration.copyWith(labelText: '隧道名称'),
                      validator: (value) => _validateRequired(value, '输入隧道名称'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _typeController.text,
                      decoration: _inputDecoration.copyWith(labelText: '类型'),
                      items: _tunnelTypes.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(type.toUpperCase(), style: TextStyle(fontFamily: "HarmonyOS Sans")),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _typeController.text = value;
                          });
                        }
                      },
                      validator: (value) => _validateRequired(value, '选择隧道类型'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 本地IP和本地端口
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _localIpController,
                      decoration: _inputDecoration.copyWith(labelText: '本地IP'),
                      validator: _validateIp,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _localPortController,
                      decoration: _inputDecoration.copyWith(labelText: '本地端口'),
                      keyboardType: TextInputType.number,
                      validator: _validatePort,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 根据端口类型显示不同的字段
              _typeController.text == 'tcp' || _typeController.text == 'udp'
                  ? Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _remotePortController,
                            decoration: _inputDecoration.copyWith(labelText: '远程端口'),
                            keyboardType: TextInputType.number,
                            validator: _validatePort,
                          ),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: _generateRandomPort,
                          child: const Text('随机端口', style: TextStyle(fontFamily: "HarmonyOS Sans",fontSize: 14, fontWeight: FontWeight.w500)),
                        ),
                      ],
                    )
                  : Container(),
              
              _typeController.text == 'http' || _typeController.text == 'https'
                  ? TextFormField(
                      controller: _bandDomainController,
                      decoration: _inputDecoration.copyWith(labelText: '绑定域名'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '请输入绑定域名';
                        }
                        return null;
                      },
                    )
                  : Container(),
              
              const SizedBox(height: 16),

              // 数据加密和数据压缩
              Row(
                children: [
                  Expanded(
                    child: SwitchListTile(
                      title: const Text('数据加密', style: TextStyle(fontFamily: "HarmonyOS Sans",fontSize: 16, )),
                      value: _encryption,
                      onChanged: (value) {
                        setState(() {
                          _encryption = value;
                        });
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                  ),
                  Expanded(
                    child: SwitchListTile(
                      title: const Text('数据压缩', style: TextStyle(fontFamily: "HarmonyOS Sans",fontSize: 16, )),
                      value: _compression,
                      onChanged: (value) {
                        setState(() {
                          _compression = value;
                        });
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
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
          child: const Text('取消' ,style: TextStyle(fontFamily: "HarmonyOS Sans",fontSize: 14, fontWeight: FontWeight.w500)),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submitForm,
          child: _isSubmitting
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : Text(widget.tunnel == null ? '创建' : '保存', style: TextStyle(fontFamily: "HarmonyOS Sans",fontSize: 14, fontWeight: FontWeight.w500)),
        ),
      ],
    );
  }
}
