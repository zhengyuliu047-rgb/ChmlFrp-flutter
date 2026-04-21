// 用户信息模型
class UserInfo {
  final String username;
  final String usergroup;
  final String userimg;
  final String usertoken;
  final int id;
  final String term;
  final String qq;
  final String email;
  final int bandwidth;
  final int tunnel;
  final int tunnelCount;
  final String realname;
  final String regtime;
  final int integral;

  UserInfo({
    required this.username,
    required this.usergroup,
    required this.userimg,
    required this.usertoken,
    required this.id,
    required this.term,
    required this.qq,
    required this.email,
    required this.bandwidth,
    required this.tunnel,
    required this.tunnelCount,
    required this.realname,
    required this.regtime,
    required this.integral,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      username: json['username'] ?? '',
      usergroup: json['usergroup'] ?? '',
      userimg: json['userimg'] ?? '',
      usertoken: json['usertoken'] ?? '',
      id: json['id'] ?? 0,
      term: json['term'] ?? '',
      qq: json['qq'] ?? '',
      email: json['email'] ?? '',
      bandwidth: json['bandwidth'] ?? 0,
      tunnel: json['tunnel'] ?? 0,
      tunnelCount: json['tunnelCount'] ?? 0,
      realname: json['realname'] ?? '',
      regtime: json['regtime'] ?? '',
      integral: json['integral'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'usergroup': usergroup,
      'userimg': userimg,
      'usertoken': usertoken,
      'id': id,
      'term': term,
      'qq': qq,
      'email': email,
      'bandwidth': bandwidth,
      'tunnel': tunnel,
      'tunnelCount': tunnelCount,
      'realname': realname,
      'regtime': regtime,
      'integral': integral,
    };
  }
}

// 隧道状态枚举
enum TunnelStatus {
  alreadyRunning,
  started,
  failed,
  stopped,
  unknown
}

// 隧道信息模型
class TunnelInfo {
  final int id;
  final String ip;
  final String dorp;
  final String name;
  final String node;
  final String state;
  final String nodestate;
  final String type;
  final String localip;
  final int nport;
  final int cur_conns;

  TunnelInfo({
    required this.id,
    required this.ip,
    required this.dorp,
    required this.name,
    required this.node,
    required this.state,
    required this.nodestate,
    required this.type,
    required this.localip,
    required this.nport,
    required this.cur_conns,
  });

  factory TunnelInfo.fromJson(Map<String, dynamic> json) {
    return TunnelInfo(
      id: json['id'] ?? 0,
      ip: json['ip'] ?? '',
      dorp: json['dorp'] ?? '',
      name: json['name'] ?? '',
      node: json['node'] ?? '',
      state: json['state'] ?? '',
      nodestate: json['nodestate'] ?? '',
      type: json['type'] ?? '',
      localip: json['localip'] ?? '',
      nport: json['nport'] ?? 0,
      cur_conns: json['cur_conns'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ip': ip,
      'dorp': dorp,
      'name': name,
      'node': node,
      'state': state,
      'nodestate': nodestate,
      'type': type,
      'localip': localip,
      'nport': nport,
      'cur_conns': cur_conns,
    };
  }
}

// 节点基础信息模型
class NodeData {
  final int id;
  final String name;
  final String area;
  final String notes;
  final String nodegroup;
  final String china;
  final String web;
  final String udp;
  final String fangyu;

  NodeData({
    required this.id,
    required this.name,
    required this.area,
    required this.notes,
    required this.nodegroup,
    required this.china,
    required this.web,
    required this.udp,
    required this.fangyu,
  });

  factory NodeData.fromJson(Map<String, dynamic> json) {
    return NodeData(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      area: json['area'] ?? '',
      notes: json['notes'] ?? '',
      nodegroup: json['nodegroup'] ?? '',
      china: json['china'] ?? '',
      web: json['web'] ?? '',
      udp: json['udp'] ?? '',
      fangyu: json['fangyu'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'area': area,
      'notes': notes,
      'nodegroup': nodegroup,
      'china': china,
      'web': web,
      'udp': udp,
      'fangyu': fangyu,
    };
  }
}

// 节点详细信息模型
class NodeInfo extends NodeData {
  final String ip;
  final String state;
  final int port;
  final int adminPort;
  final String nodetoken;
  final String realIp;
  final String rport;
  final bool toowhite;
  final String coordinates;
  final String apitoken;
  final dynamic ipv6;

  NodeInfo({
    required super.id,
    required super.name,
    required super.area,
    required super.notes,
    required super.nodegroup,
    required super.china,
    required super.web,
    required super.udp,
    required super.fangyu,
    required this.ip,
    required this.state,
    required this.port,
    required this.adminPort,
    required this.nodetoken,
    required this.realIp,
    required this.rport,
    required this.toowhite,
    required this.coordinates,
    required this.apitoken,
    required this.ipv6,
  });

  factory NodeInfo.fromJson(Map<String, dynamic> json) {
    return NodeInfo(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      area: json['area'] ?? '',
      notes: json['notes'] ?? '',
      nodegroup: json['nodegroup'] ?? '',
      china: json['china'] ?? '',
      web: json['web'] ?? '',
      udp: json['udp'] ?? '',
      fangyu: json['fangyu'] ?? '',
      ip: json['ip'] ?? '',
      state: json['state'] ?? '',
      port: json['port'] ?? 0,
      adminPort: json['adminPort'] ?? 0,
      nodetoken: json['nodetoken'] ?? '',
      realIp: json['realIp'] ?? '',
      rport: json['rport'] ?? '',
      toowhite: json['toowhite'] ?? false,
      coordinates: json['coordinates'] ?? '',
      apitoken: json['apitoken'] ?? '',
      ipv6: json['ipv6'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'ip': ip,
      'state': state,
      'port': port,
      'adminPort': adminPort,
      'nodetoken': nodetoken,
      'realIp': realIp,
      'rport': rport,
      'toowhite': toowhite,
      'coordinates': coordinates,
      'apitoken': apitoken,
      'ipv6': ipv6,
    };
  }
}
