# ProtectedRTC Distribution Guide

## Creating a Distributable Package

### Option 1: Quick Distribution (Portable Folder)

**Step 1: Build the Application**
```powershell
cd desktop-client
.\publish.bat
```

This creates a `publish` folder with `ProtectedRTC.exe` and all dependencies.

**Step 2: Share with Friends**
- Zip the entire `publish` folder
- Share the .zip file
- Friends extract and run `ProtectedRTC.exe`

**Requirements for Users:**
- Windows 10 (version 2004+) or Windows 11
- WebView2 Runtime (usually pre-installed on Windows 11)

---

### Option 2: Professional Installer (Recommended)

#### Using Inno Setup (Free)

**1. Download Inno Setup:**
- Visit: https://jrsoftware.org/isdl.php
- Download and install Inno Setup

**2. Create Installer Script:**
Save this as `desktop-client\installer.iss`:

```iss
[Setup]
AppName=ProtectedRTC
AppVersion=1.0.0
DefaultDirName={autopf}\ProtectedRTC
DefaultGroupName=ProtectedRTC
OutputDir=installer-output
OutputBaseFilename=ProtectedRTC-Setup
Compression=lzma2
SolidCompression=yes
ArchitecturesAllowed=x64
ArchitecturesInstallIn64BitMode=x64

[Files]
Source: "publish\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs

[Icons]
Name: "{group}\ProtectedRTC"; Filename: "{app}\ProtectedRTC.exe"
Name: "{autodesktop}\ProtectedRTC"; Filename: "{app}\ProtectedRTC.exe"

[Run]
Filename: "{app}\ProtectedRTC.exe"; Description: "Launch ProtectedRTC"; Flags: nowait postinstall skipifsilent
```

**3. Build Installer:**
- Open `installer.iss` in Inno Setup
- Click "Build" → "Compile"
- Find `ProtectedRTC-Setup.exe` in `desktop-client\installer-output\`

**4. Share the Installer:**
- Share `ProtectedRTC-Setup.exe` (single file!)
- Friends double-click to install
- Desktop shortcut created automatically

---

## What Your Friends Need to Do

### If You Share the Portable Folder (.zip):
1. Extract the .zip file
2. Double-click `ProtectedRTC.exe`
3. If prompted, install WebView2 Runtime: https://go.microsoft.com/fwlink/p/?LinkId=2124703

### If You Share the Installer (.exe):
1. Double-click `ProtectedRTC-Setup.exe`
2. Follow installation wizard
3. Launch from Desktop shortcut or Start Menu
4. If prompted, install WebView2 Runtime (link provided in error message)

---

## Important Configuration

### Signaling Server Setup

Your friends need a signaling server to connect with each other. You have two options:

#### Option A: Use Your Server (Recommended)
1. Deploy the signaling server to a cloud service (Replit, Heroku, Railway, etc.)
2. Get the public URL (e.g., `https://your-server.repl.co`)
3. Tell friends to configure it in the app:
   - Open ProtectedRTC
   - Click "Settings" (gear icon)
   - Enter the server URL
   - Click "Save"

#### Option B: Each User Runs Their Own Server
1. Share the `signaling-server` folder
2. Friends need Node.js installed
3. They run:
   ```bash
   cd signaling-server
   npm install
   npm start
   ```
4. Configure app to use `http://localhost:3000`

---

## Web Client Configuration

The desktop app needs the web client interface. Options:

### Option 1: Embed Web Client in Desktop App (Recommended)
You can bundle the web client into the .exe by:
1. Build web client: `cd web-client && npm run build`
2. Copy `web-client/dist` contents into desktop app
3. Modify `MainWindow.xaml.cs` to serve files locally

### Option 2: Host Web Client Online
1. Deploy web client to Netlify/Vercel/GitHub Pages
2. Get the public URL
3. Configure in app settings

### Option 3: Run Locally
Each user runs:
```bash
cd web-client
npm install
npm run dev
```
App connects to `http://localhost:5000`

---

## Testing the Distribution

Before sharing:

1. **Test on a clean Windows machine** (or clean VM)
2. **Verify these work:**
   - ✅ App launches without errors
   - ✅ WebView2 loads the interface
   - ✅ Protection status shows "ACTIVE"
   - ✅ Can join a room with another user
   - ✅ Video/audio works
   - ✅ Screen sharing works
   - ✅ Screen capture tools can't capture the window

---

## Troubleshooting

### "WebView2 Runtime not found"
- Download: https://go.microsoft.com/fwlink/p/?LinkId=2124703
- Install and restart the app

### "Cannot connect to web client"
- Check web client URL in Settings
- Ensure web client is running (if local)
- Check firewall isn't blocking connections

### "Signaling server connection failed"
- Verify signaling server is running
- Check server URL in web client configuration
- Ensure firewall allows WebSocket connections

---

## File Sizes

- **Portable folder:** ~150-200 MB (includes .NET runtime)
- **Installer:** ~80-120 MB (compressed)
- Single file mode reduces this further

---

## Next Steps

1. Run `publish.bat` to create the executable
2. Test it on your machine
3. Choose distribution method (portable vs installer)
4. Decide on signaling server hosting
5. Share with friends!

**Pro Tip:** For the best user experience, create an installer and host the signaling server online. This way friends just install and run—no technical setup required!
