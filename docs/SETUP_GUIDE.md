# ProtectedRTC Setup Guide

Complete step-by-step guide for setting up and running ProtectedRTC on Windows.

## Prerequisites Installation

### 1. Install Node.js

1. Download Node.js 20 LTS from [nodejs.org](https://nodejs.org/)
2. Run the installer
3. Verify installation:
   ```bash
   node --version
   npm --version
   ```

### 2. Install .NET 8 SDK (for Desktop Client)

1. Download .NET 8 SDK from [dotnet.microsoft.com](https://dotnet.microsoft.com/download/dotnet/8.0)
2. Run the installer
3. Verify installation:
   ```bash
   dotnet --version
   ```

### 3. Install Visual Studio 2022 (Optional, Recommended)

For desktop client development:
1. Download [Visual Studio 2022 Community](https://visualstudio.microsoft.com/)
2. During installation, select:
   - .NET desktop development
   - Windows application development

### 4. Verify WebView2 Runtime

Windows 11 has this pre-installed. For Windows 10:
1. Check if installed: Look for "Microsoft Edge WebView2 Runtime" in Programs
2. If not installed, download from [Microsoft](https://developer.microsoft.com/microsoft-edge/webview2/)

## Project Setup

### Step 1: Extract Project Files

Extract the ProtectedRTC project to your desired location, e.g.:
```
C:\Projects\ProtectedRTC\
```

### Step 2: Install Signaling Server Dependencies

Open Command Prompt or PowerShell:

```bash
cd C:\Projects\ProtectedRTC\signaling-server
npm install
```

Expected output:
```
added 108 packages in 10s
```

### Step 3: Install Web Client Dependencies

```bash
cd ..\web-client
npm install
```

Expected output:
```
added 206 packages in 25s
```

### Step 4: Restore Desktop Client Packages

```bash
cd ..\desktop-client
dotnet restore
```

Expected output:
```
Restore completed in X.XX sec
```

## Running the Application

### Terminal 1: Start Signaling Server

```bash
cd signaling-server
npm run dev
```

Expected output:
```
🚀 ProtectedRTC Signaling Server running on port 3000
   Health check: http://localhost:3000/health
   WebSocket: ws://localhost:3000

   STUN server: stun:stun.l.google.com:19302
```

Keep this terminal running.

### Terminal 2: Start Web Client

Open a new terminal:

```bash
cd web-client
npm run dev
```

Expected output:
```
  VITE v5.x.x  ready in XXX ms

  ➜  Local:   http://localhost:5000/
  ➜  Network: use --host to expose
```

Keep this terminal running.

### Terminal 3: Run Desktop Client

#### Option A: Using Visual Studio

1. Open `desktop-client\ProtectedRTC.csproj` in Visual Studio
2. Wait for NuGet restore to complete
3. Press F5 or click "Start"

#### Option B: Using Command Line

Open a new terminal:

```bash
cd desktop-client
dotnet run
```

The application window should appear with capture protection enabled.

## First-Time Setup

### Testing the Application

1. **Desktop Client Window Opens**
   - You should see a "Protection: ACTIVE" message dialog
   - Click OK

2. **Enter Room Details**
   - Name: Enter your name (e.g., "Alice")
   - Room ID: Create a room ID (e.g., "test-room-123")
   - Click "Join Room"

3. **Grant Permissions**
   - Browser will ask for camera/microphone access
   - Click "Allow"

4. **You're In!**
   - You should see your video feed
   - The protection badge should show "🔒 Protection: ACTIVE"

### Testing with Two Participants

#### Method 1: Two Desktop Clients

1. Run the desktop client twice (two separate instances)
2. Both join the same Room ID
3. You should see each other's video

#### Method 2: Desktop + Browser

1. Desktop client joins room "test-123"
2. Open browser to `http://localhost:5000`
3. Join same room "test-123"
4. Both should connect

**Note:** Only the desktop client has capture protection. The browser version is for development/testing.

## Testing Capture Protection

### Test 1: Screenshot (Print Screen)

1. With desktop client running and in a call
2. Press `Print Screen` key
3. Open Paint (Win + R, type "mspaint")
4. Paste (Ctrl + V)
5. **Expected:** ProtectedRTC window appears as a black rectangle

### Test 2: Snipping Tool

1. Open Snipping Tool (Win + Shift + S)
2. Try to capture the ProtectedRTC window
3. **Expected:** Window appears black or is excluded

### Test 3: Screen Sharing

1. Open Microsoft Teams, Zoom, or Google Meet in another window
2. Start sharing your entire screen
3. Ask another participant what they see
4. **Expected:** ProtectedRTC window is black/hidden to them

## Configuration

### Changing Web Client URL (Desktop Client)

#### Method 1: Settings Menu

1. Click the ⚙️ (Settings) button in the desktop client
2. Update the "Web Client URL" field
3. Click "Save & Reload"

#### Method 2: Configuration File

Create `web-client-url.txt` in the desktop-client folder:
```
http://localhost:5000
```

Or for a deployed version:
```
https://your-app.example.com
```

### Changing Signaling Server URL (Web Client)

Create `web-client/.env`:
```env
VITE_SIGNALING_SERVER=http://localhost:3000
```

Or for production:
```env
VITE_SIGNALING_SERVER=https://signal.example.com
```

Restart the web client after changes.

## Common Issues and Solutions

### Issue: "Disconnected" in Web Client

**Cause:** Signaling server not running or wrong URL

**Solution:**
1. Check signaling server terminal is running
2. Verify it shows "running on port 3000"
3. Check `.env` file has correct URL

### Issue: "Protection: INACTIVE" in Desktop Client

**Cause:** Windows version too old or insufficient permissions

**Solution:**
1. Check Windows version:
   - Press Win + R
   - Type `winver`
   - Must be Windows 10 2004+ or Windows 11
2. Try running as Administrator:
   - Right-click on ProtectedRTC.exe
   - Select "Run as administrator"

### Issue: Camera/Microphone Not Working

**Cause:** Permissions not granted or device in use

**Solution:**
1. Check browser permissions (click lock icon in address bar)
2. Check Windows Privacy Settings:
   - Settings → Privacy → Camera
   - Settings → Privacy → Microphone
   - Ensure apps have access
3. Close other apps using camera/mic (Zoom, Teams, etc.)

### Issue: WebView2 Error on Startup

**Cause:** WebView2 Runtime not installed

**Solution:**
1. Download from [Microsoft](https://developer.microsoft.com/microsoft-edge/webview2/)
2. Install the "Evergreen Standalone Installer"
3. Restart the desktop client

### Issue: Build Errors in Desktop Client

**Cause:** Missing dependencies or wrong .NET version

**Solution:**
1. Verify .NET 8 SDK installed: `dotnet --version`
2. Clean and restore:
   ```bash
   dotnet clean
   dotnet restore
   dotnet build
   ```

### Issue: Port Already in Use

**Cause:** Another app using port 3000 or 5000

**Solution:**

For signaling server (port 3000):
```bash
# Find process using port
netstat -ano | findstr :3000
# Kill it (replace PID)
taskkill /PID <PID> /F
```

For web client (port 5000):
```bash
netstat -ano | findstr :5000
taskkill /PID <PID> /F
```

Or change the port in `signaling-server/src/server.ts` or `web-client/vite.config.ts`.

## Building for Distribution

### Build Signaling Server

```bash
cd signaling-server
npm run build
```

Output: `dist/server.js`

### Build Web Client

```bash
cd web-client
npm run build
```

Output: `dist/` folder (deploy to web server)

### Build Desktop Client

```bash
cd desktop-client
dotnet publish -c Release -r win-x64 --self-contained
```

Output: `bin/Release/net8.0-windows/win-x64/publish/`

This creates a standalone executable with all dependencies.

### Create Installer (Optional)

Use tools like:
- **WiX Toolset** - Create MSI installers
- **Inno Setup** - Create setup wizards
- **ClickOnce** - Auto-updating deployments

## Deployment

### Signaling Server Deployment

1. **Cloud VM** (AWS EC2, Azure VM, DigitalOcean):
   ```bash
   npm run build
   node dist/server.js
   ```

2. **Process Manager** (keep running):
   ```bash
   npm install -g pm2
   pm2 start dist/server.js --name protectedrtc-signal
   pm2 startup
   pm2 save
   ```

3. **Nginx Reverse Proxy** (for WSS):
   ```nginx
   server {
       listen 443 ssl;
       server_name signal.example.com;
       
       location / {
           proxy_pass http://localhost:3000;
           proxy_http_version 1.1;
           proxy_set_header Upgrade $http_upgrade;
           proxy_set_header Connection "upgrade";
       }
   }
   ```

### Web Client Deployment

1. Build: `npm run build`
2. Deploy `dist/` to:
   - **Netlify** - Drag & drop dist folder
   - **Vercel** - Connect GitHub repo
   - **AWS S3 + CloudFront** - Static hosting
   - **Nginx** - Serve static files

### Desktop Client Distribution

1. Build release version
2. Package with:
   - All DLLs from publish folder
   - WebView2 Runtime (or require separate install)
   - Configuration file template
3. Distribute via:
   - Direct download
   - GitHub Releases
   - Internal company portal

## Security Best Practices

### For Production:

1. **Use HTTPS/WSS**
   - Signaling server must use secure WebSocket (WSS)
   - Web client must be served over HTTPS

2. **Authentication**
   - Implement user authentication
   - Use room passwords
   - Validate all signaling messages

3. **TURN Server**
   - Add authenticated TURN server for NAT traversal
   - Use services like Twilio, Xirsys, or self-host coturn

4. **Rate Limiting**
   - Limit room creation
   - Prevent signaling spam
   - Monitor for abuse

## Next Steps

1. ✅ Get all three components running
2. ✅ Test basic video call
3. ✅ Verify capture protection
4. 📖 Read [ARCHITECTURE.md](ARCHITECTURE.md) for technical details
5. 🚀 Deploy to production (see Deployment section)

## Support

If you encounter issues:
1. Check console logs in all three terminals
2. Review browser console (F12) for web client errors
3. Check Windows Event Viewer for desktop client crashes
4. Refer to [README.md](../README.md) troubleshooting section
