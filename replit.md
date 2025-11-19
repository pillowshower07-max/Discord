# ProtectedRTC Project

## Overview
ProtectedRTC is a capture-resistant real-time communication client for Windows that provides WebRTC-based video calling with OS-level screen capture protection. The application window is visible locally but excluded from screen sharing and screenshot tools using Windows SetWindowDisplayAffinity API.

## Project Structure
- **desktop-client/** - Windows WPF application (.NET 8) with capture protection
- **web-client/** - React frontend (TypeScript + Vite) with WebRTC interface
- **signaling-server/** - Node.js WebSocket server (Express + Socket.IO)
- **docs/** - Architecture and setup documentation

## Technology Stack
- Desktop: .NET 8, WPF, WebView2, Win32 APIs
- Frontend: React 18, TypeScript, Vite, WebRTC, Socket.IO Client
- Backend: Node.js 20, Express, Socket.IO, TypeScript

## Current State
✅ Signaling server implemented with room management and message routing
✅ WebRTC web client with video, audio, and screen sharing
✅ Windows WPF desktop client with SetWindowDisplayAffinity protection
✅ Complete documentation (README, ARCHITECTURE, SETUP_GUIDE)
✅ All components ready for local testing and deployment

## Recent Changes (2025-01-19)
- Created complete three-tier architecture
- Implemented WebRTC signaling server with Socket.IO
- Built React web client with media controls
- Created WPF desktop client with capture protection
- Added comprehensive documentation

## User Preferences
- Build for Windows local deployment (not cloud-based)
- Complete exportable codebase for manual execution
- Focus on capture protection as core feature

## Notes
- This project cannot run on Replit (Windows-specific)
- Created for export and local Windows execution
- Signaling server can run on Replit for development testing
- Desktop client requires Windows 10 2004+ or Windows 11
