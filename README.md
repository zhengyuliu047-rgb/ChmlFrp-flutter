# ChmlFrp Flutter Client - Visual Design V2

> **全新视觉版本 V2** - ChmlFrp 的 Flutter 图形化界面客户端，采用现代化 UI 设计，带来更优雅、更流畅的用户体验。

![Version](https://img.shields.io/badge/version-1.4.1-blue)
![Flutter](https://img.shields.io/badge/Flutter-3.10.4-02569B)
![Platform](https://img.shields.io/badge/Platform-Windows-lightgrey)
![License](https://img.shields.io/badge/License-GPL--3.0-green)

## ✨ V2 设计亮点

- **全新视觉语言** - 采用 HarmonyOS Sans 字体系统，打造统一的设计语言
- **优雅交互动效** - 流畅的页面切换动画与微交互动效
- **现代桌面体验** - 支持系统托盘、窗口管理、开机自启等桌面功能
- **数据可视化** - 内置隧道运行时长图表，直观展示运行状态
- **深色主题支持** - 精心设计的全局主题系统

## 📸 应用截图

_敬请期待_

## 🚀 核心功能

### 用户系统
- 用户登录与认证
- 自动登录
- 用户信息展示

### 仪表盘
- 系统状态概览
- 隧道运行统计
- 运行时长可视化

### 隧道管理
- 隧道列表与状态监控
- 一键启动/停止隧道
- 创建与编辑隧道
- 隧道删除管理

### 节点管理
- 可用节点浏览
- 节点详情查看
- 节点状态实时更新

### 系统功能
- 系统设置面板
- 运行日志查看
- 系统托盘支持
- 开机自动启动
- 关于信息

## 🏗️ 项目结构

```
chmlfrp_flutter/
├── assets/                     # 静态资源
│   ├── bin/                    # frpc/frps 可执行文件
│   ├── fonts/                  # 字体资源 (HarmonyOS Sans)
│   └── images/                 # 图片资源
├── lib/                        # Dart 源代码
│   ├── models/                 # 数据模型定义
│   ├── pages/                  # 页面组件
│   │   ├── dashboard_page      # 仪表盘
│   │   ├── login_page          # 登录页
│   │   ├── logs_page           # 日志页
│   │   ├── main_page           # 主页面
│   │   ├── node_list_page      # 节点列表
│   │   ├── settings_page       # 设置页
│   │   └── tunnel_list_page    # 隧道列表
│   ├── res/                    # 资源常量
│   ├── services/               # 业务服务
│   │   ├── api_service         # API 接口服务
│   │   └── frpc_service        # frpc 进程管理
│   ├── theme/                  # 主题配置
│   ├── utils/                  # 工具类
│   ├── widgets/                # 自定义组件
│   │   ├── about_dialog        # 关于对话框
│   │   ├── cherry_blossom      # 樱花粒子动效
│   │   ├── tunnel_form_dialog  # 隧道表单对话框
│   │   └── uptime_chart        # 运行时长图表
│   └── main.dart               # 应用入口
├── windows/                    # Windows 平台支持
│   ├── flutter/                # Flutter 运行时配置
│   ├── frpc_integration/       # frpc 集成模块
│   └── runner/                 # 应用启动器
├── pubspec.yaml                # 依赖配置
└── README.md                   # 项目说明
```

## 🛠️ 技术栈

| 类别 | 技术 |
|------|------|
| **框架** | Flutter 3.0+ / Dart SDK 3.10.4 |
| **网络请求** | http |
| **本地存储** | shared_preferences |
| **状态管理** | provider |
| **进程管理** | process_run |
| **窗口管理** | window_manager |
| **系统托盘** | system_tray |
| **图表组件** | fl_chart |
| **URL 启动** | url_launcher |
| **开机启动** | launch_at_startup |

## 📦 开发指南

### 环境要求

- Flutter SDK 3.10.4+
- Dart SDK 3.10.4+
- Windows 桌面开发环境

### 快速开始

```bash
# 1. 克隆项目
git clone https://github.com/zhengyuliu047-rgb/ChmlFrp-flutter.git
cd ChmlFrp-flutter

# 2. 安装依赖
flutter pub get

# 3. 运行项目
flutter run -d windows
```

### 构建发布

```bash
# 构建 Windows Release 版本
flutter build windows --release

# 构建产物位于
build/windows/x64/runner/Release/
```

## 🎨 设计资源

- **字体**: HarmonyOS Sans (已获授权用于本项目)
- **图标**: Flutter 默认图标
- **配色**: 自定义主题系统 (见 `lib/theme/app_theme.dart`)

## 📄 许可证

本项目采用 GPL-3.0 许可证，详见 [LICENSE](LICENSE) 文件。

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

---

<p align="center">Made with ❤️ using Flutter</p>
