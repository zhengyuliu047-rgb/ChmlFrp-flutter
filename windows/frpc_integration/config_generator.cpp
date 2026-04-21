#include <iostream>
#include <fstream>
#include <string>
#include <vector>
#include <sstream>

// Tunnel configuration structure
struct TunnelConfig {
    std::string name;
    std::string type;
    std::string localIp;
    int localPort;
    int remotePort;
};

class ConfigGenerator {
public:
    // Generate basic configuration file
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

    // Add tunnel configuration
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

    // Generate multi-tunnel configuration
    static bool generateMultiTunnelConfig(const std::string& configPath,
                                          const std::string& serverAddr,
                                          int serverPort,
                                          const std::string& token,
                                          const std::vector<TunnelConfig>& tunnels) {
        // Generate basic configuration
        if (!generateBaseConfig(configPath, serverAddr, serverPort, token)) {
            return false;
        }

        // Add each tunnel configuration
        for (const auto& tunnel : tunnels) {
            if (!addTunnelConfig(configPath, tunnel.name, tunnel.type,
                                tunnel.localIp, tunnel.localPort, tunnel.remotePort)) {
                return false;
            }
        }

        return true;
    }

    // Read configuration file
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

    // Validate configuration file
    static bool validateConfig(const std::string& configContent) {
        // Simple validation: check for required configuration items
        return configContent.find("[common]") != std::string::npos &&
               configContent.find("server_addr") != std::string::npos &&
               configContent.find("server_port") != std::string::npos;
    }
};
