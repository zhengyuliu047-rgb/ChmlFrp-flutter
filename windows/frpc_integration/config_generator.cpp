#include <iostream>
#include <fstream>
#include <string>
#include <vector>
#include <sstream>

class ConfigGenerator {
public:
    // 隧道配置结构体
    struct TunnelConfig {
        std::string name;
        std::string type;
        std::string localIp;
        int localPort;
        int remotePort;
    };

    // 生成基础配置文件
    static bool generateBaseConfig(const std::string& configPath,
                                   const std::string& serverAddr,
                                   int serverPort,
                                   const std::string& token = "") {
        std::ofstream configFile(configPath);
        if (!configFile.is_open()) {
            return false;
        }

        configFile << "[common]" << std::endl;
        configFile << "server_addr = " << serverAddr << std::endl;
        configFile << "server_port = " << serverPort << std::endl;
        
        if (!token.empty()) {
            configFile << "token = " << token << std::endl;
        }

        configFile.close();
        return true;
    }

    // 添加隧道配置
    static bool addTunnelConfig(const std::string& configPath,
                                const std::string& tunnelName,
                                const std::string& tunnelType,
                                const std::string& localIp,
                                int localPort,
                                int remotePort) {
        std::ofstream configFile(configPath, std::ios::app);
        if (!configFile.is_open()) {
            return false;
        }

        configFile << std::endl;
        configFile << "[" << tunnelName << "]" << std::endl;
        configFile << "type = " << tunnelType << std::endl;
        configFile << "local_ip = " << localIp << std::endl;
        configFile << "local_port = " << localPort << std::endl;
        configFile << "remote_port = " << remotePort << std::endl;

        configFile.close();
        return true;
    }

    // 生成多隧道配置
    static bool generateMultiTunnelConfig(const std::string& configPath,
                                          const std::string& serverAddr,
                                          int serverPort,
                                          const std::string& token,
                                          const std::vector<TunnelConfig>& tunnels) {
        // 生成基础配置
        if (!generateBaseConfig(configPath, serverAddr, serverPort, token)) {
            return false;
        }

        // 添加各个隧道配置
        for (const auto& tunnel : tunnels) {
            if (!addTunnelConfig(configPath, tunnel.name, tunnel.type,
                                tunnel.localIp, tunnel.localPort, tunnel.remotePort)) {
                return false;
            }
        }

        return true;
    }

    // 读取配置文件
    static std::string readConfig(const std::string& configPath) {
        std::ifstream configFile(configPath);
        if (!configFile.is_open()) {
            return "";
        }

        std::stringstream buffer;
        buffer << configFile.rdbuf();
        configFile.close();
        
        return buffer.str();
    }

    // 验证配置文件
    static bool validateConfig(const std::string& configContent) {
        // 简单验证：检查是否包含必要的配置项
        return configContent.find("[common]") != std::string::npos &&
               configContent.find("server_addr") != std::string::npos &&
               configContent.find("server_port") != std::string::npos;
    }
};