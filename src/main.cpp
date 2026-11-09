/**
 * Sample C++ Application - Curl Installable
 * 
 * This is a template app that can be distributed via:
 *   irm https://your-url.com/install.ps1 | iex
 * 
 * Replace this with your actual application logic.
 */

#include <iostream>
#include <string>
#include <cstdlib>

#ifdef _WIN32
    #include <windows.h>
#endif

const std::string APP_NAME = "DeployableApp";
const std::string APP_VERSION = "1.0.0";

void printBanner() {
    std::cout << R"(
  ____             _                   _     _      
 |  _ \  ___ _ __ | | ___  _   _  __ _| |__ | | ___ 
 | | | |/ _ \ '_ \| |/ _ \| | | |/ _` | '_ \| |/ _ \
 | |_| |  __/ |_) | | (_) | |_| | (_| | |_) | |  __/
 |____/ \___| .__/|_|\___/ \__, |\__,_|_.__/|_|\___|
            |_|            |___/                    
)" << std::endl;
    std::cout << "  " << APP_NAME << " v" << APP_VERSION << std::endl;
    std::cout << "  ================================\n" << std::endl;
}

void showHelp() {
    std::cout << "Usage: " << APP_NAME << " [command] [options]\n" << std::endl;
    std::cout << "Commands:" << std::endl;
    std::cout << "  help       Show this help message" << std::endl;
    std::cout << "  version    Show version information" << std::endl;
    std::cout << "  greet      Print a greeting message" << std::endl;
    std::cout << "  info       Show system information" << std::endl;
    std::cout << std::endl;
}

void showVersion() {
    std::cout << APP_NAME << " version " << APP_VERSION << std::endl;
}

void greet() {
    std::cout << "Hello from " << APP_NAME << "!" << std::endl;
    std::cout << "This app was installed via curl. Pretty cool, right?" << std::endl;
}

void showSystemInfo() {
    std::cout << "System Information:" << std::endl;
    std::cout << "  App Name:    " << APP_NAME << std::endl;
    std::cout << "  Version:     " << APP_VERSION << std::endl;
    
#ifdef _WIN32
    std::cout << "  Platform:    Windows" << std::endl;
    
    // Get username
    char username[256];
    DWORD username_len = 256;
    if (GetUserNameA(username, &username_len)) {
        std::cout << "  User:        " << username << std::endl;
    }
    
    // Get computer name
    char computername[256];
    DWORD computername_len = 256;
    if (GetComputerNameA(computername, &computername_len)) {
        std::cout << "  Computer:    " << computername << std::endl;
    }
#else
    std::cout << "  Platform:    Unix/Linux/macOS" << std::endl;
    
    const char* user = std::getenv("USER");
    if (user) {
        std::cout << "  User:        " << user << std::endl;
    }
#endif
}

int main(int argc, char* argv[]) {
    // No arguments - show banner and help
    if (argc < 2) {
        printBanner();
        showHelp();
        return 0;
    }
    
    std::string command = argv[1];
    
    if (command == "help" || command == "-h" || command == "--help") {
        showHelp();
    }
    else if (command == "version" || command == "-v" || command == "--version") {
        showVersion();
    }
    else if (command == "greet") {
        greet();
    }
    else if (command == "info") {
        showSystemInfo();
    }
    else {
        std::cerr << "Unknown command: " << command << std::endl;
        std::cerr << "Run '" << APP_NAME << " help' for usage information." << std::endl;
        return 1;
    }
    
    return 0;
}
