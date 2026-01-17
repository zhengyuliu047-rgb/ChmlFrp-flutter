#include <iostream>
#include <windows.h>
#include <process.h>
#include <string>
#include <vector>
#include <sstream>
#include <chrono>
#include <thread>

class ProcessManager {
private:
    HANDLE frpcProcess = NULL;
    DWORD frpcProcessId = 0;
    bool isRunning = false;

public:
    ~ProcessManager() {
        stopFrpc();
    }

    // 启动FRPC进程
    bool startFrpc(const std::string& frpcPath, const std::string& configPath) {
        if (isRunning) {
            return true;
        }

        // 创建进程信息结构
        STARTUPINFO si;
        PROCESS_INFORMATION pi;

        ZeroMemory(&si, sizeof(si));
        si.cb = sizeof(si);
        si.dwFlags = STARTF_USESHOWWINDOW;
        si.wShowWindow = SW_HIDE; // 隐藏窗口运行

        ZeroMemory(&pi, sizeof(pi));

        // 构建命令行
        std::string command = "\"" + frpcPath + "\" -c \"" + configPath + "\"";
        LPWSTR cmdLine = new WCHAR[command.length() + 1];
        MultiByteToWideChar(CP_ACP, 0, command.c_str(), -1, cmdLine, (int)command.length() + 1);

        // 创建进程
        if (!CreateProcess(NULL,
                          cmdLine,
                          NULL,
                          NULL,
                          FALSE,
                          CREATE_NEW_CONSOLE,
                          NULL,
                          NULL,
                          &si,
                          &pi)) {
            delete[] cmdLine;
            return false;
        }

        delete[] cmdLine;

        // 保存进程信息
        frpcProcess = pi.hProcess;
        frpcProcessId = pi.dwProcessId;
        isRunning = true;

        // 关闭线程句柄（保留进程句柄用于监控）
        CloseHandle(pi.hThread);

        return true;
    }

    // 停止FRPC进程
    bool stopFrpc() {
        if (!isRunning || frpcProcess == NULL) {
            return true;
        }

        // 先尝试正常终止
        if (!TerminateProcess(frpcProcess, 0)) {
            // 终止失败，尝试其他方式
            std::string killCommand = "taskkill /F /PID " + std::to_string(frpcProcessId);
            system(killCommand.c_str());
        }

        // 关闭进程句柄
        CloseHandle(frpcProcess);
        frpcProcess = NULL;
        frpcProcessId = 0;
        isRunning = false;

        return true;
    }

    // 检查FRPC进程是否运行
    bool isFrpcRunning() {
        if (!isRunning || frpcProcess == NULL) {
            return false;
        }

        DWORD exitCode;
        if (!GetExitCodeProcess(frpcProcess, &exitCode)) {
            isRunning = false;
            return false;
        }

        return exitCode == STILL_ACTIVE;
    }

    // 获取FRPC进程ID
    DWORD getFrpcProcessId() {
        return frpcProcessId;
    }

    // 重启FRPC进程
    bool restartFrpc(const std::string& frpcPath, const std::string& configPath) {
        stopFrpc();
        std::this_thread::sleep_for(std::chrono::milliseconds(500)); // 等待进程完全终止
        return startFrpc(frpcPath, configPath);
    }

    // 监控FRPC进程（后台线程）
    void monitorFrpc(const std::string& frpcPath, const std::string& configPath, int checkInterval = 5000) {
        while (isRunning) {
            std::this_thread::sleep_for(std::chrono::milliseconds(checkInterval));
            
            if (!isFrpcRunning()) {
                // FRPC进程异常退出，自动重启
                std::cout << "FRPC process exited unexpectedly, restarting..." << std::endl;
                restartFrpc(frpcPath, configPath);
            }
        }
    }

    // 启动监控线程
    void startMonitoring(const std::string& frpcPath, const std::string& configPath) {
        std::thread monitorThread([this, frpcPath, configPath]() {
            this->monitorFrpc(frpcPath, configPath);
        });
        monitorThread.detach(); // 后台运行
    }
};

// 全局进程管理器实例
ProcessManager g_processManager;

// 导出函数供外部调用
extern "C" {
    __declspec(dllexport) bool StartFrpc(const char* frpcPath, const char* configPath) {
        return g_processManager.startFrpc(frpcPath, configPath);
    }

    __declspec(dllexport) bool StopFrpc() {
        return g_processManager.stopFrpc();
    }

    __declspec(dllexport) bool IsFrpcRunning() {
        return g_processManager.isFrpcRunning();
    }

    __declspec(dllexport) void StartMonitoring(const char* frpcPath, const char* configPath) {
        g_processManager.startMonitoring(frpcPath, configPath);
    }
}

// 示例用法
int main() {
    std::string frpcPath = "frpc.exe";
    std::string configPath = "frpc.ini";

    // 启动FRPC
    if (g_processManager.startFrpc(frpcPath, configPath)) {
        std::cout << "FRPC started successfully, PID: " << g_processManager.getFrpcProcessId() << std::endl;
        
        // 启动监控
        g_processManager.startMonitoring(frpcPath, configPath);
        
        // 运行一段时间
        std::cout << "Running for 30 seconds..." << std::endl;
        std::this_thread::sleep_for(std::chrono::seconds(30));
        
        // 停止FRPC
        g_processManager.stopFrpc();
        std::cout << "FRPC stopped" << std::endl;
    } else {
        std::cout << "Failed to start FRPC" << std::endl;
    }

    return 0;
}