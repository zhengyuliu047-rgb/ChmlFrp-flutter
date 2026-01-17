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
  final String location;
  final String type;
  final String state;
  final int uptime_seconds;
  final double load15;
  final int users;
  final int bandwidth;
  final int traffic;
  final int port;
  final int adminPort;
  final int memory_total;
  final int storage_total;
  final int storage_used;
  final double total_traffic_in;
  final double total_traffic_out;
  final String cpu_info;
  final String nodetoken;
  final String realIp;
  final String rport;
  final bool toowhite;

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
    required this.location,
    required this.type,
    required this.state,
    required this.uptime_seconds,
    required this.load15,
    required this.users,
    required this.bandwidth,
    required this.traffic,
    required this.port,
    required this.adminPort,
    required this.memory_total,
    required this.storage_total,
    required this.storage_used,
    required this.total_traffic_in,
    required this.total_traffic_out,
    required this.cpu_info,
    required this.nodetoken,
    required this.realIp,
    required this.rport,
    required this.toowhite,
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
      location: json['location'] ?? '',
      type: json['type'] ?? '',
      state: json['state'] ?? '',
      uptime_seconds: json['uptime_seconds'] ?? 0,
      load15: json['load15'] ?? 0.0,
      users: json['users'] ?? 0,
      bandwidth: json['bandwidth'] ?? 0,
      traffic: json['traffic'] ?? 0,
      port: json['port'] ?? 0,
      adminPort: json['adminPort'] ?? 0,
      memory_total: json['memory_total'] ?? 0,
      storage_total: json['storage_total'] ?? 0,
      storage_used: json['storage_used'] ?? 0,
      total_traffic_in: json['total_traffic_in'] ?? 0.0,
      total_traffic_out: json['total_traffic_out'] ?? 0.0,
      cpu_info: json['cpu_info'] ?? '',
      nodetoken: json['nodetoken'] ?? '',
      realIp: json['realIp'] ?? '',
      rport: json['rport'] ?? '',
      toowhite: json['toowhite'] ?? false,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'ip': ip,
      'location': location,
      'type': type,
      'state': state,
      'uptime_seconds': uptime_seconds,
      'load15': load15,
      'users': users,
      'bandwidth': bandwidth,
      'traffic': traffic,
      'port': port,
      'adminPort': adminPort,
      'memory_total': memory_total,
      'storage_total': storage_total,
      'storage_used': storage_used,
      'total_traffic_in': total_traffic_in,
      'total_traffic_out': total_traffic_out,
      'cpu_info': cpu_info,
      'nodetoken': nodetoken,
      'realIp': realIp,
      'rport': rport,
      'toowhite': toowhite,
    };
  }
}
