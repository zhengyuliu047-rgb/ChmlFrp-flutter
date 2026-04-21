; ChmlFrp Flutter 安装脚本
; 由 Inno Setup 生成

#define MyAppName "ChmlFrp"
#define MyAppVersion "2.0"
#define MyAppPublisher "ChmlFrp Team"
#define MyAppURL "https://chml.frp"
#define MyAppExeName "chmlfrp_flutter.exe"
#define MyAppIcon "app_icon.ico"

[Setup]
; 安装程序配置
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={pf}\{#MyAppName}
DefaultGroupName={#MyAppName}
AllowNoIcons=yes
OutputDir=d:\windc\ChmlFrp-flutter-beautify-design-v2\Output
OutputBaseFilename=chmlfrp_flutter_setup
Compression=lzma
SolidCompression=yes
WizardStyle=modern

; 安装程序图标
SetupIconFile=d:\windc\ChmlFrp-flutter-beautify-design-v2\windows\runner\resources\app_icon.ico

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked
Name: "quicklaunchicon"; Description: "{cm:CreateQuickLaunchIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked; OnlyBelowVersion: 0,6.1

[Files]
; 主应用程序文件
Source: "d:\windc\ChmlFrp-flutter-beautify-design-v2\build\windows\x64\runner\Release\{#MyAppExeName}"; DestDir: "{app}"; Flags: ignoreversion
Source: "d:\windc\ChmlFrp-flutter-beautify-design-v2\build\windows\x64\runner\Release\flutter_windows.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "d:\windc\ChmlFrp-flutter-beautify-design-v2\build\windows\x64\runner\Release\frpc.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "d:\windc\ChmlFrp-flutter-beautify-design-v2\build\windows\x64\runner\Release\url_launcher_windows_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "d:\windc\ChmlFrp-flutter-beautify-design-v2\build\windows\x64\runner\Release\screen_retriever_windows_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "d:\windc\ChmlFrp-flutter-beautify-design-v2\build\windows\x64\runner\Release\window_manager_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "d:\windc\ChmlFrp-flutter-beautify-design-v2\build\windows\x64\runner\Release\system_tray_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion

; 数据目录 (包含 app.so 和 icudtl.dat)
Source: "d:\windc\ChmlFrp-flutter-beautify-design-v2\build\windows\x64\runner\Release\data\*"; DestDir: "{app}\data"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; IconFilename: "{app}\{#MyAppExeName}"
Name: "{group}\{cm:UninstallProgram,{#MyAppName}}"; Filename: "{uninstallexe}"
Name: "{commondesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; IconFilename: "{app}\{#MyAppExeName}"; Tasks: desktopicon
Name: "{userappdata}\Microsoft\Internet Explorer\Quick Launch\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; IconFilename: "{app}\{#MyAppExeName}"; Tasks: quicklaunchicon

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#MyAppName}}"; Flags: nowait postinstall skipifsilent

[UninstallDelete]
Type: filesandordirs; Name: "{app}"