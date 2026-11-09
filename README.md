# DeployableApp - Curl Installable C++ Application

A C++ application template that can be installed with a single command.

## Quick Install (Windows)

```powershell
irm https://raw.githubusercontent.com/Mohawk-RyanKilgore/DeployableApptestingC++/main/install.ps1 | iex
```

This will:
- ✅ Download the latest release from GitHub
- ✅ Install to `%LOCALAPPDATA%\MyApp`
- ✅ Copy the exe to your Desktop
- ✅ Create a desktop shortcut
- ✅ Add to PATH (run from any terminal)

## Usage

After installation, run from any terminal:

```bash
myapp              # Show help
myapp greet        # Print greeting
myapp info         # Show system info
myapp version      # Show version
```

Or double-click the desktop shortcut.

---

## For Developers: How to Set This Up

### 1. Update the install script

Edit `install.ps1` and change these lines:

```powershell
$AppName = "MyApp"                  # Your app name
$RepoOwner = "YOUR_USERNAME"        # Your GitHub username
$RepoName = "YOUR_REPO"             # Your repo name
$ExeName = "myapp.exe"              # Your exe filename
```

### 2. Update the C++ app

Edit `src/main.cpp` to add your actual application logic.

### 3. Push to GitHub

```bash
git init
git add .
git commit -m "Initial commit"
git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO.git
git push -u origin main
```

### 4. Create a release

Tag and push to trigger the GitHub Action:

```bash
git tag v1.0.0
git push origin v1.0.0
```

The GitHub Action will:
- Build your app on Windows
- Create a GitHub Release
- Upload `myapp.exe` as a release asset

### 5. Share!

Now anyone can install your app with:

```powershell
irm https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/main/install.ps1 | iex
```

---

## Building Locally

### Prerequisites
- CMake 3.16+
- Visual Studio 2019+ or MinGW

### Build

```bash
cmake -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build --config Release
```

The exe will be at `build/bin/Release/myapp.exe`

---

## Project Structure

```
curl-installer-app/
├── src/
│   └── main.cpp           # Your C++ application
├── .github/
│   └── workflows/
│       └── release.yml    # Auto-build on tag push
├── install.ps1            # The curl-able installer
├── CMakeLists.txt         # CMake build config
└── README.md              # This file
```

## License

MIT License - feel free to use this as a template for your own projects.
