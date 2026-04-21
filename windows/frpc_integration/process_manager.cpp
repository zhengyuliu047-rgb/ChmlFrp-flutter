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

    // Start FRPC process
    bool startFrpc(const std::string& frpcPath, const std::string& configPath) {
        if (isRunning) {
            return true;
        }

        // Create process info structure
        STARTUPINFO si;
        PROCESS_INFORMATION pi;

        ZeroMemory(&si, sizeof(si));
        si.cb = sizeof(si);
        si.dwFlags = STARTF_USESHOWWINDOW;
        si.wShowWindow = SW_HIDE;

        ZeroMemory(&pi, sizeof(pi));

        // Build command line
        std::string command = "\"" + frpcPath + "\" -c \"" + configPath + "\"";
        int cmdLen = static_cast<int>(command.length()) + 1;
        LPWSTR cmdLine = new WCHAR[cmdLen];
        MultiByteToWideChar(CP_ACP, 0, command.c_str(), -1, cmdLine, cmdLen);

        // Create process
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

        // Save process info
        frpcProcess = pi.hProcess;
        frpcProcessId = pi.dwProcessId;
        isRunning = true;

        // Close thread handle (keep process handle for monitoring)
        CloseHandle(pi.hThread);

        return true;
    }

    // Stop FRPC process
    bool stopFrpc() {
        if (!isRunning || frpcProcess == NULL) {
            return true;
        }

        // Try to terminate normally first
        if (!TerminateProcess(frpcProcess, 0)) {
            // Termination failed, try other methods
            std::string killCommand = "taskkill /F /PID " + std::to_string(frpcProcessId);
            system(killCommand.c_str());
        }

        // Close process handle
        CloseHandle(frpcProcess);
        frpcProcess = NULL;
        frpcProcessId = 0;
        isRunning = false;

        return true;
    }

    // Check if FRPC process is running
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

    // Get FRPC process ID
    DWORD getFrpcProcessId() {
        return frpcProcessId;
    }

    // Restart FRPC process
    bool restartFrpc(const std::string& frpcPath, const std::string& configPath) {
        stopFrpc();
        std::this_thread::sleep_for(std::chrono::milliseconds(500));
        return startFrpc(frpcPath, configPath);
    }

    // Monitor FRPC process (background thread)
    void monitorFrpc(const std::string& frpcPath, const std::string& configPath, int checkInterval = 5000) {
        while (isRunning) {
            std::this_thread::sleep_for(std::chrono::milliseconds(checkInterval));
            
            if (!isFrpcRunning()) {
                // FRPC process exited unexpectedly, auto restart
                std::cout << "FRPC process exited unexpectedly, restarting..." << std::endl;
                restartFrpc(frpcPath, configPath);
            }
        }
    }

    // Start monitoring thread
    void startMonitoring(const std::string& frpcPath, const std::string& configPath) {
        std::thread monitorThread([this, frpcPath, configPath]() {
            monitorFrpc(frpcPath, configPath);
        });
        monitorThread.detach();
    }
};

// Global process manager instance
ProcessManager g_processManager;

// Export functions for external calls
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
