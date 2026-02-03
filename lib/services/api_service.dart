import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/models.dart';

class ApiService {
  static const String baseUrl = 'https://cf-v2.uapis.cn';
  static const String baseUrlV1 = 'https://cf-v1.uapis.cn';

  // 存储用户信息
  static UserInfo? _userInfo;
  static UserInfo? get userInfo => _userInfo;
  static String get userId => _userInfo?.id.toString() ?? '';
  static String get userToken => _userInfo?.usertoken ?? '';

  // 获取登录状态文件路径
  static Future<File> get _loginStatusFile async {
    final directory = Directory(Platform.environment['APPDATA']!);
    final chmlFrpDir = Directory('${directory.path}\chmlfrp');
    if (!chmlFrpDir.existsSync()) {
      chmlFrpDir.createSync();
    }
    return File('${chmlFrpDir.path}\login_status.json');
  }

  // 初始化，尝试自动登录
  static Future<bool> init() async {
    try {
      final file = await _loginStatusFile;
      if (file.existsSync()) {
        final content = await file.readAsString();
        final json = jsonDecode(content);
        final token = json['usertoken'] as String?;
        if (token != null) {
          return await loginWithToken(token);
        }
      }
    } catch (e) {
      print('Error reading login status: $e');
    }
    return false;
  }

  // 通用HTTP请求方法
  static Future<Map<String, dynamic>?> _postRequest(
    String endpoint,
    Map<String, String> body,
  ) async {
    try {
      print('[DEBUG] Making POST request to: $endpoint');
      print('[DEBUG] Request body: $body');
      
      final response = await http.post(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: body,
      );

      print('[DEBUG] Response status code: ${response.statusCode}');
      print('[DEBUG] Response body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      print('HTTP Request Error: $e');
    }
    return null;
  }

  // 通用GET请求方法
  static Future<Map<String, dynamic>?> _getRequest(
    String endpoint,
    Map<String, String>? params,
  ) async {
    try {
      Uri uri = Uri.parse(endpoint);
      if (params != null) {
        uri = uri.replace(queryParameters: params);
      }

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      print('HTTP Request Error: $e');
    }
    return null;
  }

  // MARK: - 用户认证相关

  // 使用用户名密码登录
  static Future<bool> loginWithCredentials(
    String username,
    String password,
    Function(String)? onStatusUpdate,
  ) async {
    final result = await _postRequest(
      '$baseUrl/login',
      {
        'username': username,
        'password': password,
      },
    );

    if (result != null && result['state'] == 'success') {
      _userInfo = UserInfo.fromJson(result['data']);
      try {
        final file = await _loginStatusFile;
        final loginStatus = {
          'usertoken': _userInfo!.usertoken,
        };
        await file.writeAsString(jsonEncode(loginStatus));
      } catch (e) {
        print('Error saving login status: $e');
      }
      return true;
    } else {
      onStatusUpdate?.call(result?['msg'] ?? '登录失败');
      return false;
    }
  }

  // 使用Token登录
  static Future<bool> loginWithToken(String token) async {
    final result = await _postRequest(
      '$baseUrl/userinfo',
      {
        'token': token,
      },
    );

    if (result != null && result['state'] == 'success') {
      _userInfo = UserInfo.fromJson(result['data']);
      try {
        final file = await _loginStatusFile;
        final loginStatus = {
          'usertoken': _userInfo!.usertoken,
        };
        await file.writeAsString(jsonEncode(loginStatus));
      } catch (e) {
        print('Error saving login status: $e');
      }
      return true;
    }
    return false;
  }

  // 登出
  static Future<void> logout() async {
    _userInfo = null;
    try {
      final file = await _loginStatusFile;
      if (file.existsSync()) {
        await file.delete();
      }
    } catch (e) {
      print('Error deleting login status: $e');
    }
  }

  // MARK: - 隧道管理相关

  // 获取隧道列表
  static Future<List<TunnelInfo>> getTunnelList() async {
    if (_userInfo == null) return [];

    final result = await _postRequest(
      '$baseUrl/tunnel',
      {
        'token': userToken,
      },
    );

    if (result != null && result['state'] == 'success') {
      final List<dynamic> data = result['data'];
      return data
          .map((item) => TunnelInfo.fromJson(item))
          .toList();
    }
    return [];
  }

  // 删除隧道
  static Future<bool> deleteTunnel(int tunnelId) async {
    if (_userInfo == null) return false;

    // 使用与C# SDK相同的方式，使用GET请求并将参数作为查询字符串
    final params = {
      'token': userToken,
      'userid': userId,
      'nodeid': tunnelId.toString(),
    };

    print('[DEBUG] Deleting tunnel with params: $params');

    final result = await _getRequest(
      '$baseUrlV1/api/deletetl.php',
      params,
    );

    print('[DEBUG] Delete tunnel response: $result');

    return result != null && result['code'] == 200;
  }

  // 创建隧道
  static Future<Map<String, dynamic>?> createTunnel(
    String tunnelName,
    String nodeName,
    String portType,
    String localIp,
    int localPort,
    int? remotePort,
    String? bandDomain,
    bool encryption,
    bool compression,
    String? extraParams,
  ) async {
    if (_userInfo == null) {
      print('[DEBUG] User not logged in, cannot create tunnel');
      return {'code': 401, 'msg': '请先登录'};
    }

    print('[DEBUG] Creating tunnel with parameters:');
    print('[DEBUG] tunnelName: $tunnelName');
    print('[DEBUG] nodeName: $nodeName');
    print('[DEBUG] portType: $portType');
    print('[DEBUG] localIp: $localIp');
    print('[DEBUG] localPort: $localPort');
    print('[DEBUG] remotePort: $remotePort');
    print('[DEBUG] bandDomain: $bandDomain');
    print('[DEBUG] encryption: $encryption');
    print('[DEBUG] compression: $compression');
    print('[DEBUG] extraParams: $extraParams');
    print('[DEBUG] userToken: $userToken');

    // 构建请求体
    final body = {
      'token': userToken,
      'tunnelname': tunnelName,
      'node': nodeName,
      'localip': localIp,
      'porttype': portType,
      'localport': localPort,
      'encryption': encryption,
      'compression': compression,
    };

    // 根据端口类型添加相应的参数
    if (portType == 'tcp' || portType == 'udp') {
      if (remotePort != null) {
        body['remoteport'] = remotePort;
      }
    } else if (portType == 'http' || portType == 'https') {
      if (bandDomain != null) {
        body['banddomain'] = bandDomain;
      }
    }

    // 添加额外参数
    if (extraParams != null && extraParams.isNotEmpty) {
      body['extraparams'] = extraParams;
    }

    print('[DEBUG] Request body: $body');

    try {
      // 使用POST请求，Content-Type为application/json
      final response = await http.post(
        Uri.parse('$baseUrl/create_tunnel'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      print('[DEBUG] Response status code: ${response.statusCode}');
      print('[DEBUG] Response body: ${response.body}');

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        print('[DEBUG] API response: $result');
        return result;
      } else {
        print('[DEBUG] API request failed with status code: ${response.statusCode}');
        return {'code': response.statusCode, 'msg': '请求失败: ${response.statusCode}'};
      }
    } catch (e) {
      print('HTTP Request Error: $e');
      return {'code': 500, 'msg': '网络错误: $e'};
    }
  }

  // 更新隧道
  static Future<String> updateTunnel(
    TunnelInfo tunnelInfo,
    String tunnelName,
    String nodeName,
    String type,
    String localIp,
    String localPort,
    String remotePort,
  ) async {
    if (_userInfo == null) return '请先登录';

    // 使用与C# SDK相同的方式，使用GET请求并将参数作为查询字符串
    final params = {
      'usertoken': userToken,
      'userid': userId,
      'tunnelid': tunnelInfo.id.toString(),
      'name': tunnelName,
      'node': nodeName,
      'type': type,
      'localip': localIp,
      'nport': localPort,
      'dorp': remotePort,
      'encryption': 'false',
      'compression': 'false',
      'ap': '',
    };

    print('[DEBUG] Updating tunnel with params: $params');

    final result = await _getRequest(
      '$baseUrlV1/api/cztunnel.php',
      params,
    );

    print('[DEBUG] Update tunnel response: $result');

    return result?['error'] ?? '更新失败';
  }

  // 刷新用户信息
  static Future<bool> refreshUserInfo() async {
    if (_userInfo == null) return false;
    
    final result = await _postRequest(
      '$baseUrl/userinfo',
      {
        'token': userToken,
      },
    );

    if (result != null && result['state'] == 'success') {
      _userInfo = UserInfo.fromJson(result['data']);
      return true;
    }
    return false;
  }

  // MARK: - 节点管理相关

  // 获取节点列表
  static Future<List<NodeData>> getNodesDataList() async {
    final result = await _getRequest('$baseUrl/node', null);

    if (result != null && result['state'] == 'success') {
      final List<dynamic> data = result['data'];
      return data
          .map((item) => NodeData.fromJson(item))
          .toList();
    }
    return [];
  }

  // 获取节点详细信息
  static Future<NodeInfo?> getNodeInfo(String nodeName) async {
    if (_userInfo == null) return null;

    final result = await _postRequest(
      '$baseUrl/nodeinfo',
      {
        'token': userToken,
        'node': nodeName,
      },
    );

    if (result != null) {
      if (result['state'] == 'success') {
        return NodeInfo.fromJson(result['data']);
      } else if (result['code'] == 403) {
        print('[DEBUG] Permission denied when getting node info: ${result['msg']}');
      }
    }
    return null;
  }

  // MARK: - 签到相关

  // 用户签到
  static Future<Map<String, dynamic>?> signIn({
    required String lotNumber,
    required String captchaOutput,
    required String passToken,
    required String genTime,
  }) async {
    if (_userInfo == null) return null;

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/qiandao'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'token': userToken,
          'lot_number': lotNumber,
          'captcha_output': captchaOutput,
          'pass_token': passToken,
          'gen_time': genTime,
        }),
      );

      print('[DEBUG] Sign in response status code: ${response.statusCode}');
      print('[DEBUG] Sign in response body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      print('Sign in HTTP Request Error: $e');
    }
    return null;
  }
}
