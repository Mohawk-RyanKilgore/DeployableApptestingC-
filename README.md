# C++ Desktop App Deployment Template

A template for building and deploying C++ desktop applications via a single curl/PowerShell command.

## For Users: Install the App

**PowerShell:**
```powershell
irm https://raw.githubusercontent.com/Mohawk-RyanKilgore/DeployableApptestingC-/main/install.ps1 | iex
```

**Command Prompt (cmd):**
```cmd
powershell -c "irm https://raw.githubusercontent.com/Mohawk-RyanKilgore/DeployableApptestingC-/main/install.ps1 | iex"
```

This will:
- ✅ Download the latest release
- ✅ Install to `%LOCALAPPDATA%\DeployableApp`
- ✅ Copy exe to Desktop
- ✅ Create desktop shortcut
- ✅ Add to PATH (run from any terminal)

---

## For Developers: How to Use This Template

### 1. Clone/Fork this repo

### 2. Customize the app

Edit these files:
| File | What to change |
|------|----------------|
| `src/main.cpp` | Your C++ application code |
| `install.ps1` | `$AppName`, `$RepoOwner`, `$RepoName`, `$ExeName` |
| `CMakeLists.txt` | `project(YourAppName)` and `OUTPUT_NAME` |

### 3. Push your changes

```bash
git add .
git commit -m "My app update"
git push
```

### 4. Release a new version

```bash
git tag v1.0.0
git push origin v1.0.0
```

GitHub Actions will automatically:
1. Build your C++ code on Windows
2. Create a GitHub Release
3. Upload the `.exe` as a downloadable asset

### 5. Users can now install/update

```powershell
irm https://raw.githubusercontent.com/YOUR_USER/YOUR_REPO/main/install.ps1 | iex
```

Running the install command again will update to the latest version.

---

## Project Structure

```
├── src/
│   └── main.cpp              # Your C++ code (starts as Hello World)
├── .github/
│   └── workflows/
│       └── release.yml       # Auto-build on version tag
├── install.ps1               # PowerShell installer script
├── CMakeLists.txt            # CMake build configuration
├── .gitignore
└── README.md
```

---

## Configuration Reference

### install.ps1 variables

```powershell
$AppName = "DeployableApp"              # Display name & install folder
$RepoOwner = "Mohawk-RyanKilgore"       # GitHub username
$RepoName = "DeployableApptestingC-"    # Repository name
$ExeName = "deployableapp.exe"          # Output executable name
```

### CMakeLists.txt settings

```cmake
project(DeployableApp VERSION 1.0.0 LANGUAGES CXX)

set_target_properties(${PROJECT_NAME} PROPERTIES
    OUTPUT_NAME "deployableapp"    # Must match $ExeName (without .exe)
)
```

---

## Versioning

Use semantic versioning for releases:
- `v1.0.0` - Major release
- `v1.1.0` - New features
- `v1.1.1` - Bug fixes

---

## License

MIT License - Use this template freely for your own projects.
