# ProtectedRTC: Capture-Resistant Real-Time Communication

A Windows desktop application that provides WebRTC-based video calling with OS-level screen capture protection. The application allows you to participate in video calls that remain visible on your screen but are excluded from screen sharing and screenshot tools.

## 🎯 Key Features

- **Real-Time Communication**: 1:1 video calls with audio, video, and screen sharing
- **Capture Protection**: Windows API-based protection that excludes the app window from screen capture
- **Device Control**: Toggle microphone, camera, and screen sharing
- **Modern UI**: Clean, responsive interface built with React
- **Peer-to-Peer**: WebRTC-based direct communication with STUN/TURN support

## 📁 Project Structure

```
ProtectedRTC/
├── desktop-client/       # Windows WPF application (.NET 8)
├── web-client/          # React frontend (TypeScript + Vite)
├── signaling-server/    # Node.js WebSocket server (Socket.IO)
└── docs/               # Architecture and documentation
```

## 🛠️ Technology Stack

### Desktop Client (Windows)
- .NET 8
- WPF (Windows Presentation Foundation)
- WebView2
- Win32 API (SetWindowDisplayAffinity)

### Web Client
- React 18
- TypeScript
- Vite
- WebRTC APIs
- Socket.IO Client

### Signaling Server
- Node.js 20
- Express
- Socket.IO
- TypeScript

## 📋 Prerequisites

### For Running the Desktop Client:
- **Windows 10** (version 2004 or later) or **Windows 11**
- **.NET 8 SDK** - [Download](https://dotnet.microsoft.com/download/dotnet/8.0)
- **WebView2 Runtime** - Usually pre-installed on Windows 11

### For Development:
- **Node.js 20+** - [Download](https://nodejs.org/)
- **Visual Studio 2022** (for desktop client development)
- **Git**

## 🚀 Quick Start

### 1. Clone the Repository
```bash
git clone <repository-url>
cd ProtectedRTC
```

### 2. Start the Signaling Server
```bash
cd signaling-server
npm install
npm run dev
```
The server will start on `http://localhost:3000`

### 3. Start the Web Client
```bash
cd web-client
npm install
npm run dev
```
The web client will start on `http://localhost:5000`

### 4. Build and Run the Desktop Client (Windows)

#### Option A: Using Visual Studio
1. Open `desktop-client/ProtectedRTC.csproj` in Visual Studio 2022
2. Restore NuGet packages (Build → Restore NuGet Packages)
3. Build the solution (Ctrl+Shift+B)
4. Run (F5 or click Start)

#### Option B: Using Command Line
```bash
cd desktop-client
dotnet restore
dotnet build
dotnet run
```

## 📖 Usage Guide

### Starting a Call

1. **Launch the Desktop Client** (for full protection) or open the web client in a browser
2. **Enter your name** and a **Room ID**
3. **Click "Join Room"** - share the same Room ID with others to join
4. **Grant permissions** when prompted for camera and microphone access

### During a Call

- **Microphone**: Click the mic button to mute/unmute
- **Camera**: Click the camera button to turn video on/off
- **Screen Share**: Click the screen share button and select what to share
- **Leave**: Click the red phone button to exit the call

### Testing Capture Protection (Desktop Client Only)

After launching the Windows desktop client:

1. **Screenshot Test**: Press `PrintScreen` and paste into Paint - the ProtectedRTC window should appear black
2. **Snipping Tool Test**: Try to capture the window - it should be excluded or appear black
3. **Screen Share Test**: Share your entire screen in Teams/Zoom/Meet - the ProtectedRTC window should not be visible to others

## 🔧 Configuration

### Web Client Configuration

Create a `.env` file in `web-client/`:
```env
VITE_SIGNALING_SERVER=http://localhost:3000
```

### Desktop Client Configuration

The desktop client will look for `web-client-url.txt` in its directory:
```
http://localhost:5000
```

Or use the Settings button (⚙️) in the app to configure the URL.

## 🏗️ Architecture

### How It Works

```
┌─────────────────┐         WebSocket          ┌──────────────────┐
│  Participant A  │ ◄─────────────────────────► │ Signaling Server │
│  (Desktop App)  │                             │   (Node.js)      │
└─────────────────┘                             └──────────────────┘
        │                                               ▲
        │                                               │
        │          WebRTC Peer Connection              │
        │          (Audio/Video/Screen)                │
        │                                               │
        ▼                                               │
┌─────────────────┐         WebSocket          ────────┘
│  Participant B  │ ────────────────────────────
│  (Desktop App)  │
└─────────────────┘
```

### Capture Protection Mechanism

The desktop client uses Windows API `SetWindowDisplayAffinity` with the `WDA_EXCLUDEFROMCAPTURE` flag:

```csharp
SetWindowDisplayAffinity(windowHandle, WDA_EXCLUDEFROMCAPTURE);
```

This instructs Windows to exclude the window from:
- Desktop duplication APIs
- Screen capture APIs
- Print Screen functionality
- Third-party screen recording tools

## 📚 Development

### Building for Production

#### Signaling Server
```bash
cd signaling-server
npm run build
npm start
```

#### Web Client
```bash
cd web-client
npm run build
```
Deploy the `dist/` folder to a web server.

#### Desktop Client
```bash
cd desktop-client
dotnet publish -c Release -r win-x64 --self-contained
```
The executable will be in `bin/Release/net8.0-windows/win-x64/publish/`

## ⚠️ Important Notes

### Limitations

1. **Windows Only**: Capture protection only works on Windows 10 (2004+) and Windows 11
2. **Not Foolproof**: Advanced screen capture methods (physical cameras, hardware capture cards) cannot be blocked
3. **Browser vs Desktop**: Only the Windows desktop client provides capture protection - the web version in a browser does NOT
4. **Compatibility**: Some older screen capture tools may still capture the window

### Security Considerations

- This is **not** a security tool for protecting sensitive data
- Media streams use WebRTC's built-in DTLS-SRTP encryption
- Signaling server should use WSS (secure WebSocket) in production
- Consider implementing authentication for production use

## 🐛 Troubleshooting

### Desktop Client Issues

**"Protection: INACTIVE" warning**
- Ensure you're running Windows 10 (2004+) or Windows 11
- Try running as Administrator
- Check Windows version: `winver` in Run dialog

**WebView2 not loading**
- Install WebView2 Runtime from [Microsoft](https://developer.microsoft.com/microsoft-edge/webview2/)

**Can't connect to web client**
- Verify the web client is running on the configured URL
- Check Settings (⚙️ button) and update the URL if needed

### Web Client Issues

**"Disconnected" status**
- Ensure signaling server is running
- Check the URL in `.env` or browser console

**Camera/Mic not working**
- Grant browser permissions when prompted
- Check system privacy settings (Windows Settings → Privacy)

**Screen share not working**
- Use a compatible browser (Chrome, Edge, Firefox)
- Grant screen share permissions when prompted

## 📄 License

MIT License - See LICENSE file for details

## 🤝 Contributing

This is a reference implementation for educational purposes. For production use, consider:
- Adding user authentication
- Implementing TURN server for better NAT traversal
- Adding end-to-end encryption
- Creating multi-party call support
- Adding chat functionality

## 📞 Support

For issues and questions:
- Check the `/docs` folder for detailed architecture documentation
- Review the troubleshooting section above
- Examine console logs for error messages

## 🔗 Related Documentation

- [WebRTC Documentation](https://webrtc.org/)
- [SetWindowDisplayAffinity API](https://docs.microsoft.com/windows/win32/api/winuser/nf-winuser-setwindowdisplayaffinity)
- [WebView2 Documentation](https://docs.microsoft.com/microsoft-edge/webview2/)
- [Socket.IO Documentation](https://socket.io/docs/)
