# chmlfrp_flutter

ChmlFrp 的 Flutter 图形化界面客户端，支持 Windows 平台，提供直观易用的用户界面，实现隧道管理、节点管理等核心功能。

## 项目结构

```
chmlfrp_flutter/
├── assets/             # 静态资源
│   └── images/         # 图片资源
├── lib/                # Dart 代码
│   ├── models/         # 数据模型
│   ├── pages/          # 页面
│   ├── services/       # 服务
│   ├── theme/          # 主题
│   ├── utils/          # 工具类
│   └── widgets/        # 自定义组件
├── windows/            # Windows 平台特定代码
│   ├── flutter/        # Flutter 运行时
│   ├── frpc_integration/ # frpc 集成
│   └── runner/         # 应用启动器
├── pubspec.yaml        # 依赖配置
└── README.md           # 项目说明
```

## 核心功能

### 用户认证
- 登录界面
- 自动登录
- 登出功能
- 用户信息展示

### 隧道管理
- 隧道列表展示
- 隧道状态监控
- 启动/停止隧道
- 创建新隧道
- 删除隧道
- 编辑隧道信息

### 节点管理
- 节点列表展示
- 节点详情查看
- 节点状态监控

### 其他功能
- 系统设置
- 日志查看
- 美观的用户界面

## 技术栈

- Flutter 3.0+
- Dart
- Windows 桌面支持
- HTTP 客户端
- 本地存储

## 开发环境

1. 安装 Flutter SDK
2. 配置 Windows 桌面开发环境
3. 克隆项目
4. 安装依赖：`flutter pub get`
5. 运行项目：`flutter run -d windows`

## 构建发布

```bash
# 构建 Windows 发布版本
flutter build windows
```

## 许可证

本项目采用 GPL-3.0 许可证，详见 LICENSE.md 文件。
