# RehabTrack

An iOS app for EMG-based physical therapy, designed to work with a dual-sleeve wearable device that records muscle activity during rehabilitation sessions for patients recovering arm function post-trauma (surgery, stroke, fracture, etc.).

## Overview

RehabTrack connects patients with their physical therapists through EMG data visualization, exercise management, in-app messaging, and AI-powered exercise recommendations. The app serves two user roles with distinct interfaces:

**Patients** can track their recovery progress through interactive charts, complete assigned exercises, receive messages from their provider, and view AI-generated exercise suggestions.

**Medical Providers** can monitor all their patients' EMG data and progress, assign exercises, communicate via messaging, and review/approve AI-recommended exercises before they reach the patient.

## Architecture

| Layer | Technology | Notes |
|-------|-----------|-------|
| UI | SwiftUI | iOS 17+ target |
| Data | SwiftData | `@Model` classes with relationships |
| Pattern | MVVM | `@Observable` ViewModels (iOS 17 Observation framework) |
| Charts | Swift Charts | Two modes: waveform + progress trends |
| Services | Protocol-based | `DeviceService` and `AIService` with mock implementations |

### Project Structure

```
RehabTrack/
├── Models/              9 @Model classes + 4 enums
│   ├── User, Patient, Provider
│   ├── EMGSession, EMGReading
│   ├── Exercise, ExerciseCompletion
│   ├── Message, AIRecommendation
│   └── Enums/ (UserRole, MuscleGroup, ExerciseStatus, RecommendationStatus)
│
├── ViewModels/          10 @Observable view models
│   ├── AuthViewModel
│   ├── Patient/ (Dashboard, Progress, Exercise, Messages, AI)
│   └── Provider/ (PatientList, PatientDetail, Exercise, Messages, AIReview)
│
├── Views/               15 SwiftUI views
│   ├── Auth/LoginView
│   ├── Patient/ (Dashboard, Progress, ExerciseList, ExerciseDetail, Messages, AI, TabView)
│   ├── Provider/ (PatientList, PatientDetail, ExerciseAssign, Messages, AIReview, TabView)
│   └── Shared/ (EMGChartView, MetricCardView, MessageBubbleView, ExerciseRowView)
│
├── Services/            5 files
│   ├── DeviceService/ (protocol + MockDeviceService)
│   ├── AIService/ (protocol + MockAIService)
│   └── DataManager/ (CRUD facade over SwiftData)
│
└── Utilities/           3 files
    ├── MockDataGenerator (seeds realistic patient data)
    ├── Constants
    └── DateFormatters
```

## Current State (What's Built)

### Fully implemented

- **Authentication flow** — Role-based login screen (Patient vs. Provider), account selection from seeded users, logout
- **Patient Dashboard** — 4 metric cards (total sessions, avg peak amplitude with trend, recovery %, exercises due today), compact progress chart, fatigue index summary
- **EMG Progress Charts** — Swift Charts with two modes:
  - *Single session waveform*: raw amplitude over time with area gradient
  - *Progress over time*: session averages plotted over weeks, color-coded by muscle group, filterable
- **Exercise Management** — Patients view assigned exercises, log completions (sets/reps/notes), mark exercises complete. Providers assign new exercises via a form (name, description, target muscles, reps, sets, frequency)
- **Messaging** — Chat-style interface between patient and their provider, unread counts, auto-scroll
- **AI Recommendations** — Patients see AI-suggested exercises (read-only). Providers review, approve, or reject recommendations. Approving converts suggestions into real assigned exercises
- **Mock Data** — 3 patients at different recovery stages (early/mid/late), 8-20 EMG sessions each with realistic amplitude progression and fatigue curves, exercises at various statuses, message history, pending AI recommendations
- **Service Protocols** — `DeviceService` and `AIService` defined as protocols with mock implementations, designed for one-line swap to real implementations

### Mock data details

| Patient | Injury | Stage | Sessions | Target Muscles |
|---------|--------|-------|----------|----------------|
| Marcus Johnson | Right arm fracture | 8 weeks | 18 | Biceps, Triceps |
| Emily Rivera | Left forearm strain | 3 weeks | 8 | Forearm Flexors/Extensors |
| David Park | Rotator cuff surgery | 12 weeks | 20 | Deltoid, Biceps |

Provider: Dr. Sarah Chen (Physical Therapy - Upper Extremity)

## What's Not Yet Implemented

### Hardware Integration (BLE)
The `DeviceService` protocol is defined and a `MockDeviceService` generates simulated EMG data. To connect real hardware:
1. Create a `BLEDeviceService` class conforming to `DeviceService`
2. Use CoreBluetooth to discover and connect to the wearable sleeves
3. Parse the BLE characteristic data into `EMGReading` objects
4. Swap `MockDeviceService()` for `BLEDeviceService()` in `RehabTrackApp.swift`

The mock currently simulates a contraction-sustain-release envelope at 20 Hz. Real surface EMG typically runs at 1000 Hz — you'll want to downsample or store readings as compressed `Data` blobs for production.

### AI Integration
The `AIService` protocol is defined and `MockAIService` returns contextual suggestions based on session trends. To connect a real AI provider:
1. Create a class conforming to `AIService` (e.g., `ClaudeExerciseService` or `OpenAIExerciseService`)
2. Send the patient's EMG session data (averages, fatigue indices, muscle groups) as context to the API
3. Parse the response into `SuggestedExercise` objects
4. Swap `MockAIService()` for your implementation in `RehabTrackApp.swift`

Suggested prompt engineering: include the patient's injury description, weeks since injury, target muscles, recent session metrics (amplitude trends, fatigue indices), and current exercise list for the most relevant recommendations.

### Backend / Cloud
Currently all data is local (SwiftData on-device). For production:
- **Authentication**: Replace the local user picker with Firebase Auth, Sign in with Apple, or your own auth service
- **Database**: Migrate from SwiftData to a cloud database (Firestore, PostgreSQL, etc.) for multi-device sync and provider access
- **Messaging**: Replace local messages with a real-time messaging service (Firebase Cloud Messaging, Stream, etc.)
- **HIPAA Compliance**: EMG and patient health data requires HIPAA-compliant storage and transmission. Evaluate BAA-covered cloud providers

### Other TODO Items
- **Live recording UI**: A "Record Session" view that shows real-time EMG waveform during recording (the `MockDeviceService` supports this, but no UI is wired up yet)
- **Push notifications**: Notify patients of new messages, exercise reminders, AI recommendations
- **Onboarding**: First-time setup flow for new patients/providers
- **App icon and branding**: Custom app icon, launch screen, color theme refinement
- **Accessibility**: VoiceOver labels for all charts and interactive elements
- **Unit tests**: Test coverage for DataManager, MockDeviceService, MockAIService
- **SwiftUI Previews**: In-memory ModelContainer sample data for preview development
- **Export**: PDF/CSV export of EMG data and progress reports for clinical records
- **Multi-language support**: Localization for patient populations

## How to Run

1. Open `RehabTrack.xcodeproj` in Xcode 16+
2. Select an iPhone simulator (iOS 17.0 or later)
3. Build and Run (Cmd+R)
4. Mock data seeds automatically on first launch
5. Login as any user — try both Patient and Provider roles

If you modify the project structure and need to regenerate the `.xcodeproj`:
```bash
brew install xcodegen  # if not already installed
xcodegen generate
```

## Tech Stack

- **Swift 5** / **SwiftUI** / **iOS 17+**
- **SwiftData** for local persistence
- **Swift Charts** for EMG data visualization
- **MVVM** with `@Observable` (Observation framework)
- **XcodeGen** for project file generation
