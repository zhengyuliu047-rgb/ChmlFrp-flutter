#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>
#include <windows.h>
#include <string>
#include <iostream>
#include <fstream>

#include "flutter_window.h"
#include "utils.h"

// Callback function to find window
BOOL CALLBACK EnumWindowsProc(HWND hwnd, LPARAM lParam) {
    wchar_t windowTitle[256];
    GetWindowText(hwnd, windowTitle, 256);
    if (wcscmp(windowTitle, L"chmlfrp_flutter") == 0) {
        // Found window, show and activate it
        ShowWindow(hwnd, SW_SHOW);
        SetForegroundWindow(hwnd);
        return FALSE;
    }
    return TRUE;
}

int APIENTRY wWinMain(_In_ HINSTANCE instance, _In_opt_ HINSTANCE prev,
                      _In_ wchar_t *command_line, _In_ int show_command) {
    // Check if an instance is already running
    HANDLE hMutex = CreateMutex(NULL, TRUE, L"ChmlFrp_SingleInstance");
    if (GetLastError() == ERROR_ALREADY_EXISTS) {
        // Instance already running, find and show its window
        EnumWindows(EnumWindowsProc, NULL);
        CloseHandle(hMutex);
        return EXIT_SUCCESS;
    }

    // Attach to console when present (e.g., 'flutter run') or create a
    // new console when running with a debugger.
    if (!::AttachConsole(ATTACH_PARENT_PROCESS) && ::IsDebuggerPresent()) {
        CreateAndAttachConsole();
    }

    // Initialize COM for libraries and/or plugins
    ::CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);

    // Get application path
    wchar_t exePath[MAX_PATH];
    GetModuleFileName(NULL, exePath, MAX_PATH);
    std::wstring exePathW(exePath);
    std::string exePathA(exePathW.begin(), exePathW.end());
    std::string exeDir = exePathA.substr(0, exePathA.find_last_of("\\"));
    
    // Create config directory
    std::string configDir = exeDir + "\\configs";
    CreateDirectoryA(configDir.c_str(), NULL);

    flutter::DartProject project(L"data");

    std::vector<std::string> command_line_arguments =
        GetCommandLineArguments();

    // Enable Impeller rendering engine
    command_line_arguments.push_back("--enable-impeller");

    project.set_dart_entrypoint_arguments(std::move(command_line_arguments));

    FlutterWindow window(project);
    Win32Window::Point origin(10, 10);
    Win32Window::Size size(1280, 720);
    if (!window.Create(L"chmlfrp_flutter", origin, size)) {
        ::CoUninitialize();
        CloseHandle(hMutex);
        return EXIT_FAILURE;
    }
    window.SetQuitOnClose(true);

    ::MSG msg;
    while (::GetMessage(&msg, nullptr, 0, 0)) {
        ::TranslateMessage(&msg);
        ::DispatchMessage(&msg);
    }

    ::CoUninitialize();
    CloseHandle(hMutex);
    return EXIT_SUCCESS;
}
