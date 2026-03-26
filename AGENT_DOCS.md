# Pose Detection System — Architecture & Implementation Plan

## Overview

Current system: Flutter Android app communicates with a backend server via
WebSocket for elderly pose detection.

New system: Add a Flutter Desktop PC app. PC generates a QR code, Android
scans it, and after pairing over LAN, the PC takes over the WebSocket
connection to the backend using the PC camera. After the session ends, PC
returns data to Android.

---

## Confirmed Requirements

| # | Requirement | Decision |
|---|-------------|----------|
| 1 | PC App framework | Flutter Desktop |
| 2 | Network topology | Same LAN (same WiFi required) |
| 3 | User authentication | Mandatory account system |
| 4 | Data returned to Android | TBD |
| 5 | Android role during session | Sends session info to PC, acts as lifecycle anchor — if Android closes, PC disconnects; if PC closes, Android exits session |
| 6 | QR token expiry | 10 minutes |
| 7 | Multi-user | 1-to-1 only |
| 8 | Connection drop handling | Same as requirement 5 |

---

## Key Design Decisions

**PC as Local WebSocket Server**
PC opens a local WebSocket server on a random port. The QR code contains the
PC's LAN IP and port. Android connects directly to PC over LAN without
routing through the internet.

**Flutter Monorepo**
Use `melos` to manage a monorepo. Shared logic (models, auth, WebSocket,
session management) lives in a `packages/shared` package reused by both
Android and Desktop apps.

**JWT Not in QR**
The QR code contains only the PC's LAN address and a short-lived HMAC pairing
token. The user JWT is sent over the local WebSocket after pairing is
established, preventing exposure if the QR is screenshot.

**Keypoints Over Raw Frames**
Run pose detection locally on PC via TFLite or MediaPipe (FFI). Send only
keypoints arrays to the backend instead of raw frames, reducing bandwidth
by approximately 95%.

---

## System Flow

### Phase 0 — Authentication

Android logs in and receives a JWT. PC does not authenticate independently —
it reuses the Android user's token, acting as an extension device.

---

### Phase 1 — QR Pairing

PC gets its local LAN IP, opens a local WebSocket server, generates a
one-time HMAC pairing token valid for 10 minutes, and renders it as a QR
code. Android scans the QR, connects to the PC's local WebSocket, and sends
the user's JWT and session config. PC validates the pairing token and
confirms the pairing. Both sides begin a heartbeat loop.

---

### Phase 2 — Session Handoff

PC connects to the backend WebSocket using the user's JWT. PC sends session
start info to the backend and receives a session ID in return. PC forwards
the session ID to Android over the local WebSocket. Android enters standby
mode. The heartbeat continues between PC and Android throughout the session.

---

### Phase 3 — Exercise Session

PC captures camera frames, runs local pose detection, and sends keypoints to
the backend via WebSocket. The backend returns real-time feedback including
scores, rep counts, and form corrections. PC renders the exercise UI with
skeleton overlay, rep counter, and alerts.

---

### Phase 4 — Lifecycle Management

A heartbeat ping runs every 5 seconds between PC and Android. The timeout
threshold is 15 seconds (3 missed pings).

- **Android closes or crashes:** PC detects the timeout, sends a session end
  event to the backend, closes the backend WebSocket, cleans up the local
  server, and shows a disconnection dialog.

- **PC closes or crashes:** Android detects the timeout, shows a disconnection
  dialog, and returns to the home screen. The backend WebSocket closes
  automatically when the PC process dies.

- **PC exercise failure (camera error, backend error):** PC sends a failure
  event to Android via local WebSocket. Android shows an error and returns
  to the home screen. PC releases the camera and shuts down the local server.

---

### Phase 5 — Data Return to Android

PC posts the exercise results to the backend REST API. Once saved, PC notifies
Android via the local WebSocket that the session is complete. Android fetches
the results from the backend and displays the summary screen.

---

## Repository Structure

```
pose_detection_app/
├── packages/
│   └── shared/
│       ├── lib/
│       │   ├── models/
│       │   ├── services/
│       │   │   ├── auth_service.dart
│       │   │   ├── websocket_service.dart
│       │   │   └── session_service.dart
│       │   └── utils/
│       │       ├── token_validator.dart
│       │       └── heartbeat_manager.dart
│       └── pubspec.yaml
│
├── apps/
│   ├── android/
│   │   ├── lib/
│   │   │   ├── screens/
│   │   │   │   ├── home_screen.dart
│   │   │   │   ├── qr_scan_screen.dart
│   │   │   │   └── session_result_screen.dart
│   │   │   └── main.dart
│   │   └── pubspec.yaml
│   │
│   └── desktop/
│       ├── lib/
│       │   ├── screens/
│       │   │   ├── qr_display_screen.dart
│       │   │   ├── exercise_screen.dart
│       │   │   └── result_screen.dart
│       │   ├── services/
│       │   │   ├── local_ws_server.dart
│       │   │   ├── camera_service.dart
│       │   │   └── lan_discovery.dart
│       │   └── main.dart
│       └── pubspec.yaml
│
├── melos.yaml
└── pubspec.yaml
```

---

## Key Dependencies

| Package | Purpose | Platform |
|---|---|---|
| `shelf` + `shelf_web_socket` | PC local WebSocket server | Desktop |
| `web_socket_channel` | WebSocket client | Both |
| `mobile_scanner` | QR scanning | Android |
| `qr_flutter` | QR generation | Desktop |
| `camera` or `opencv_dart` | Camera capture on PC | Desktop |
| `network_info_plus` | Get LAN IP | Desktop |
| `flutter_secure_storage` | Store JWT securely | Both |
| `melos` | Monorepo management | Dev tool |

---

## Implementation Plan

**Sprint 1 — Foundation (1 week)**
- Set up Flutter monorepo with `melos`
- Create `shared` package with models, auth service, session model
- Migrate existing Android app to use `shared` package
- Backend: add session start, session end, and session complete events

**Sprint 2 — PC App Core (1.5 weeks)**
- LAN discovery service to get PC local IP
- Local WebSocket server with pairing flow
- QR display screen with 10-minute countdown and auto-refresh
- Pairing token generation and HMAC validation

**Sprint 3 — Lifecycle and Heartbeat (0.5 weeks)**
- `HeartbeatManager` in shared package: ping every 5s, timeout at 15s
- PC handler: detect Android disconnect, close session
- Android handler: detect PC disconnect, exit session screen
- Android QR scan screen and local WS connection flow

**Sprint 4 — Exercise Session (1.5 weeks)**
- Camera service on Desktop
- PC WebSocket client connecting to backend with user JWT
- Local pose detection pipeline (keypoints only sent to backend)
- Real-time UI: skeleton overlay, rep counter, form alerts

**Sprint 5 — Integration and Edge Cases (1 week)**
- End-to-end test of all 5 phases
- Edge case testing: QR expired, network drop, app crash on both sides
- Handle multiple LAN interfaces (WiFi + Ethernet on PC)
- Security review: one-time-use tokens, WebSocket auth header validation

---

## Known Risks

- **Windows Firewall:** Opening a local WebSocket server port may be blocked
  by Windows Firewall. Users may need to grant a network permission on first
  run.

- **Flutter Desktop camera support:** The `camera` plugin on Desktop is
  limited. Evaluate `opencv_dart` (FFI-based) early in Sprint 2 to avoid
  a blocker.

- **LAN IP changes:** If the PC's IP changes during a session, the pairing
  breaks. Monitor IP changes and prompt the user to re-generate the QR if
  needed.

- **Multiple LAN interfaces:** PC may have both WiFi and Ethernet active.
  The LAN discovery service must select the correct interface, preferring
  the one on the same subnet as the Android device.
