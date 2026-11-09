/**
 * C++ Desktop App Template
 * 
 * Features:
 * - --version flag
 * - Auto-update checker on launch
 * 
 * Build and deploy with: git tag v1.1.0 && git push origin v1.1.0
 */

#include <iostream>
#include <string>
#include <cstdlib>
#include <fstream>
#include <sstream>

#ifdef _WIN32
    #include <windows.h>
    #include <wininet.h>
    #pragma comment(lib, "wininet.lib")
#endif

// ============================================
// CONFIGURATION - Update these for your app
// ============================================
const std::string APP_NAME = "DeployableApp";
const std::string APP_VERSION = "1.1.0";
const std::string REPO_OWNER = "Mohawk-RyanKilgore";
const std::string REPO_NAME = "cpp-installer-template";
// ============================================

// Function to fetch URL content (Windows only)
std::string fetchUrl(const std::string& url) {
#ifdef _WIN32
    std::string result;
    HINTERNET hInternet = InternetOpenA("DeployableApp", INTERNET_OPEN_TYPE_DIRECT, NULL, NULL, 0);
    if (hInternet) {
        HINTERNET hConnect = InternetOpenUrlA(hInternet, url.c_str(), NULL, 0, INTERNET_FLAG_RELOAD, 0);
        if (hConnect) {
            char buffer[4096];
            DWORD bytesRead;
            while (InternetReadFile(hConnect, buffer, sizeof(buffer) - 1, &bytesRead) && bytesRead > 0) {
                buffer[bytesRead] = '\0';
                result += buffer;
            }
            InternetCloseHandle(hConnect);
        }
        InternetCloseHandle(hInternet);
    }
    return result;
#else
    return "";
#endif
}

// Extract version from GitHub API response (simple parsing)
std::string extractLatestVersion(const std::string& json) {
    // Look for "tag_name":"vX.X.X"
    size_t pos = json.find("\"tag_name\"");
    if (pos == std::string::npos) return "";
    
    pos = json.find("\"", pos + 10);
    if (pos == std::string::npos) return "";
    
    size_t end = json.find("\"", pos + 1);
    if (end == std::string::npos) return "";
    
    std::string version = json.substr(pos + 1, end - pos - 1);
    // Remove 'v' prefix if present
    if (!version.empty() && version[0] == 'v') {
        version = version.substr(1);
    }
    return version;
}

// Compare version strings (simple: a.b.c format)
bool isNewerVersion(const std::string& latest, const std::string& current) {
    // Parse versions into components
    int latestMajor = 0, latestMinor = 0, latestPatch = 0;
    int currentMajor = 0, currentMinor = 0, currentPatch = 0;
    
    sscanf(latest.c_str(), "%d.%d.%d", &latestMajor, &latestMinor, &latestPatch);
    sscanf(current.c_str(), "%d.%d.%d", &currentMajor, &currentMinor, &currentPatch);
    
    if (latestMajor > currentMajor) return true;
    if (latestMajor < currentMajor) return false;
    if (latestMinor > currentMinor) return true;
    if (latestMinor < currentMinor) return false;
    return latestPatch > currentPatch;
}

void checkForUpdates() {
    std::cout << "Checking for updates..." << std::endl;
    
    std::string apiUrl = "https://api.github.com/repos/" + REPO_OWNER + "/" + REPO_NAME + "/releases/latest";
    std::string response = fetchUrl(apiUrl);
    
    if (response.empty()) {
        std::cout << "  Could not check for updates (no internet?)" << std::endl;
        return;
    }
    
    std::string latestVersion = extractLatestVersion(response);
    if (latestVersion.empty()) {
        std::cout << "  Could not determine latest version" << std::endl;
        return;
    }
    
    if (isNewerVersion(latestVersion, APP_VERSION)) {
        std::cout << "\n";
        std::cout << "  *** UPDATE AVAILABLE ***" << std::endl;
        std::cout << "  Current version: " << APP_VERSION << std::endl;
        std::cout << "  Latest version:  " << latestVersion << std::endl;
        std::cout << "\n  To update, run:" << std::endl;
        std::cout << "  powershell -c \"irm https://raw.githubusercontent.com/" 
                  << REPO_OWNER << "/" << REPO_NAME << "/main/install.ps1 | iex\"" << std::endl;
        std::cout << "\n";
    } else {
        std::cout << "  You're running the latest version (" << APP_VERSION << ")" << std::endl;
    }
}

void showVersion() {
    std::cout << APP_NAME << " version " << APP_VERSION << std::endl;
}

void showHelp() {
    std::cout << "Usage: " << APP_NAME << " [options]" << std::endl;
    std::cout << std::endl;
    std::cout << "Options:" << std::endl;
    std::cout << "  --version, -v    Show version information" << std::endl;
    std::cout << "  --help, -h       Show this help message" << std::endl;
    std::cout << "  --check-update   Check for updates without running app" << std::endl;
    std::cout << std::endl;
}

int main(int argc, char* argv[]) {
    // Handle command line arguments
    if (argc > 1) {
        std::string arg = argv[1];
        
        if (arg == "--version" || arg == "-v") {
            showVersion();
            return 0;
        }
        else if (arg == "--help" || arg == "-h") {
            showHelp();
            return 0;
        }
        else if (arg == "--check-update") {
            checkForUpdates();
            return 0;
        }
    }
    
    // Check for updates on launch
    checkForUpdates();
    std::cout << std::endl;
    
    // ============================================
    // YOUR APP CODE GOES HERE
    // ============================================
    std::cout << "Hello, World!" << std::endl;
    std::cout << std::endl;
    std::cout << APP_NAME << " v" << APP_VERSION << std::endl;
    // ============================================
    
    // Keep console open
    std::cout << "\nPress Enter to exit...";
    std::cin.get();
    
    return 0;
}
