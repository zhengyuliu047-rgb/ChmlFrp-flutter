#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>
#include <windows.h>
#include <string>
#include <iostream>
#include <fstream>

#include "flutter_window.h"
#include "utils.h"

int APIENTRY wWinMain(_In_ HINSTANCE instance, _In_opt_ HINSTANCE prev,
                      _In_ wchar_t *command_line, _In_ int show_command) {
    // Attach to console when present (e.g., 'flutter run') or create a
    // new console when running with a debugger.
    if (!::AttachConsole(ATTACH_PARENT_PROCESS) && ::IsDebuggerPresent()) {
        CreateAndAttachConsole();
    }

    // 初始化COM，以便在库和/或插件中使用
    ::CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);

    // 获取应用程序路径
    wchar_t exePath[MAX_PATH];
    GetModuleFileName(NULL, exePath, MAX_PATH);
    std::wstring exePathW(exePath);
    std::string exePathA(exePathW.begin(), exePathW.end());
    std::string exeDir = exePathA.substr(0, exePathA.find_last_of("\\"));
    
    // 创建配置目录
    std::string configDir = exeDir + "\\configs";
    CreateDirectoryA(configDir.c_str(), NULL);

    flutter::DartProject project(L"data");

    std::vector<std::string> command_line_arguments =
        GetCommandLineArguments();

    // 启用 Impeller 渲染引擎
    command_line_arguments.push_back("--enable-impeller");

    project.set_dart_entrypoint_arguments(std::move(command_line_arguments));

    FlutterWindow window(project);
    Win32Window::Point origin(10, 10);
    Win32Window::Size size(1280, 720);
    if (!window.Create(L"chmlfrp_flutter", origin, size)) {
        ::CoUninitialize();
        return EXIT_FAILURE;
    }
    window.SetQuitOnClose(true);

    ::MSG msg;
    while (::GetMessage(&msg, nullptr, 0, 0)) {
        ::TranslateMessage(&msg);
        ::DispatchMessage(&msg);
    }

    ::CoUninitialize();
    return EXIT_SUCCESS;
}
