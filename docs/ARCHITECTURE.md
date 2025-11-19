# ProtectedRTC Architecture

## System Overview

ProtectedRTC is a three-tier application consisting of:
1. **Windows Desktop Client** - WPF application with capture protection
2. **Web Client** - React-based WebRTC interface
3. **Signaling Server** - Node.js WebSocket server for peer coordination

## Component Architecture

### 1. Desktop Client (Windows WPF)

```
MainWindow.xaml.cs
├── Window Initialization
│   ├── SetWindowDisplayAffinity (WDA_EXCLUDEFROMCAPTURE)
│   └── GetWindowDisplayAffinity (verification)
├── WebView2 Integration
│   ├── CoreWebView2 initialization
│   └── Web client hosting
└── Settings Management
    └── SettingsWindow.xaml.cs
```

**Key Technologies:**
- WPF for native Windows UI
- WebView2 for embedding web content
- Win32 API interop for capture protection

**Capture Protection Flow:**
```
1. Window loaded event triggers
2. Get window handle (HWND) via WindowInteropHelper
3. Call SetWindowDisplayAffinity(hwnd, WDA_EXCLUDEFROMCAPTURE)
4. Verify with GetWindowDisplayAffinity
5. Update UI status indicator
```

### 2. Web Client (React + WebRTC)

```
App.tsx (Root)
├── WebRTCService (singleton)
│   ├── Socket.IO connection to signaling server
│   ├── RTCPeerConnection management
│   ├── Media stream handling
│   └── Signaling message handling
├── JoinRoom Component
│   └── Room joining UI
└── CallInterface Component
    ├── VideoTile (local + remote)
    ├── ControlBar (mic, camera, screen share)
    └── Media device controls
```

**WebRTC Service Responsibilities:**
- Manage WebSocket connection to signaling server
- Create and manage RTCPeerConnection instances for each peer
- Handle ICE candidates, SDP offers/answers
- Manage local media streams (camera, mic, screen)
- Distribute media streams to peers

### 3. Signaling Server (Node.js + Socket.IO)

```
server.ts
├── Room Management
│   ├── Create/delete rooms
│   ├── Track participants per room
│   └── Participant join/leave events
└── Message Routing
    ├── Offer forwarding
    ├── Answer forwarding
    └── ICE candidate forwarding
```

**Data Structures:**
```typescript
Room {
  id: string
  participants: Map<socketId, Participant>
}

Participant {
  id: string (socket ID)
  username: string
  roomId: string
}
```

## WebRTC Signaling Flow

### Room Join Sequence

```
Client A                    Signaling Server              Client B
   │                               │                          │
   │──join-room───────────────────►│                          │
   │                               │                          │
   │◄──room-joined─────────────────│                          │
   │   (list of participants)      │                          │
   │                               │                          │
   │                               │◄──join-room──────────────│
   │                               │                          │
   │◄──participant-joined──────────│                          │
   │                               │──room-joined────────────►│
   │                               │──participant-joined─────►│
```

### WebRTC Connection Establishment

```
Client A                    Signaling Server              Client B
   │                               │                          │
   │  Create RTCPeerConnection     │                          │
   │──createOffer()                │                          │
   │──setLocalDescription()        │                          │
   │                               │                          │
   │──offer───────────────────────►│                          │
   │                               │──offer──────────────────►│
   │                               │                          │
   │                               │      Create RTCPeerConnection
   │                               │      setRemoteDescription()
   │                               │      createAnswer()
   │                               │      setLocalDescription()
   │                               │                          │
   │                               │◄──answer─────────────────│
   │◄──answer──────────────────────│                          │
   │                               │                          │
   │  setRemoteDescription()       │                          │
   │                               │                          │
   ├──ice-candidate──────────────►│──ice-candidate──────────►│
   │◄──ice-candidate───────────────│◄──ice-candidate──────────│
   │                               │                          │
   │                    WebRTC Connection Established         │
   │◄═══════════════════════════════════════════════════════►│
   │           Direct P2P Media Streaming (DTLS-SRTP)         │
```

### ICE Candidate Exchange

```
1. Each peer gathers ICE candidates (local, server-reflexive, relay)
2. Candidates sent via signaling server
3. Peers add candidates to their RTCPeerConnection
4. Best candidate pair selected for media transmission
```

## Media Flow Architecture

### Local Media Capture

```
User Action                     getUserMedia()              MediaStream
   │                                   │                         │
   │──Enable Camera────────────────────►                         │
   │                                   ├──Video Track───────────►│
   │                                   └──Audio Track───────────►│
   │                                                              │
   │◄─────────────────────────MediaStream─────────────────────────┘
   │
   └──Add to RTCPeerConnection
```

### Screen Share Flow

```
User Action                  getDisplayMedia()             MediaStream
   │                                │                           │
   │──Start Screen Share────────────►                           │
   │                                ├──Screen Video Track──────►│
   │                                                             │
   │◄────────────────────────MediaStream──────────────────────────┘
   │
   ├──Add to RTCPeerConnection
   │
   └──Track 'ended' event (user stops sharing)
      └──Stop screen share
```

## Capture Protection Mechanism

### Windows API: SetWindowDisplayAffinity

```c
BOOL SetWindowDisplayAffinity(
  HWND hWnd,         // Window handle
  DWORD dwAffinity   // Display affinity flag
);
```

**Flag Used:** `WDA_EXCLUDEFROMCAPTURE (0x00000011)`

**Effect:**
- Window excluded from Desktop Duplication API
- Print Screen captures show window as black
- Screen recording tools see black window
- Screen sharing in Teams/Zoom/Meet shows black window

**Requirements:**
- Windows 10 Build 19041 (version 2004) or later
- Windows 11 (all builds)

**Limitations:**
- Does not protect against:
  - Physical cameras pointed at screen
  - Hardware video capture devices
  - VM-level capture tools
  - Kernel-mode capture tools

### Verification Process

```csharp
1. Set affinity: SetWindowDisplayAffinity(hwnd, WDA_EXCLUDEFROMCAPTURE)
2. Verify: GetWindowDisplayAffinity(hwnd, out affinity)
3. Check: affinity == WDA_EXCLUDEFROMCAPTURE
4. Update UI with protection status
```

## Security Considerations

### WebRTC Security

**Built-in:**
- DTLS-SRTP for media encryption
- ICE consent for connectivity
- Same-origin policy for web context

**Recommendations:**
- Use TURN server with authentication
- Implement user authentication
- Use WSS (secure WebSocket) for signaling
- Validate all signaling messages

### Capture Protection Security

**What It Protects:**
- Standard screen capture tools
- Screen sharing applications
- Screenshot utilities
- Screen recording software

**What It Doesn't Protect:**
- Malware with kernel-level access
- Physical monitoring (cameras)
- Hardware capture devices
- VM host-level capture

## Deployment Architecture

### Development Setup

```
Localhost:
├── Desktop Client (standalone app)
│   └── Points to: http://localhost:5000
├── Web Client (Vite dev server)
│   └── Port: 5000
└── Signaling Server
    └── Port: 3000
```

### Production Setup

```
Cloud Infrastructure:
├── Signaling Server (VM/Container)
│   ├── Domain: wss://signal.example.com
│   ├── SSL/TLS certificate
│   └── STUN/TURN configuration
│
└── Web Client (Static hosting)
    ├── Domain: https://app.example.com
    ├── CDN for assets
    └── Points to signaling server

Desktop Client (User's Windows PC):
└── Points to: https://app.example.com
```

## Performance Considerations

### WebRTC Quality Settings

**Video Constraints:**
```javascript
{
  video: {
    width: { ideal: 1280 },
    height: { ideal: 720 },
    frameRate: { ideal: 30 }
  }
}
```

**Screen Share Constraints:**
```javascript
{
  video: {
    width: { ideal: 1920 },
    height: { ideal: 1080 },
    frameRate: { ideal: 30 }
  }
}
```

### Bandwidth Considerations

- 720p video: ~1-2 Mbps per stream
- Screen share: ~2-4 Mbps (varies with content)
- Audio: ~50-100 Kbps per stream

### Scalability

**Current Architecture (Mesh):**
- Best for 2-4 participants
- Each peer sends to all other peers
- N-to-N connections: N*(N-1)/2 connections

**For More Participants:**
- Implement SFU (Selective Forwarding Unit)
- Or use MCU (Multipoint Control Unit)
- Consider commercial services (Twilio, Agora, etc.)

## Error Handling

### Connection Failures

1. **Signaling Server Unreachable**
   - Display "Disconnected" status
   - Attempt reconnection with exponential backoff

2. **WebRTC Connection Failed**
   - Check ICE candidates gathered
   - Verify STUN/TURN accessibility
   - Display error to user

3. **Media Device Access Denied**
   - Show permission instructions
   - Gracefully degrade (audio-only, etc.)

### Recovery Strategies

- Automatic reconnection for signaling
- ICE restart for failed connections
- Renegotiation on track changes
- Graceful degradation (audio-only fallback)

## Future Enhancements

### Planned Features

1. **Multi-Party Calls**
   - SFU architecture
   - Layout management
   - Speaker detection

2. **Chat Integration**
   - WebRTC Data Channels
   - Message history
   - File sharing

3. **Recording**
   - Local recording (MediaRecorder)
   - Server-side recording option
   - Privacy controls

4. **Advanced Settings**
   - Bandwidth controls
   - Quality presets
   - Device selection persistence

5. **Authentication**
   - User accounts
   - Room passwords
   - Access control
