# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

SelfCoach is a Flutter mobile application for holistic wellness management, focusing on personalized health plans for conditions like ADHD, sleep disorders, and hypertension. The MVP emphasizes personalized health management, user engagement, and affordability.

## Key Architecture

### Authentication & Session Management
- Uses **Supabase Auth** for authentication with OAuth flows and email/password
- Session management handled via `Supabase.instance.client.auth`
- Environment variables loaded from `.env` file using `flutter_dotenv`

### Navigation
- **GoRouter** for declarative routing with authentication-aware navigation
- Routes include home, welcome, and auth flow paths
- Session state determines initial route (`/` redirects based on auth status)

### State Management
- **Provider** package for state management (v6.0.3)
- State organized in `lib/state/` directory with separate files for auth and health state

### Data Layer
- API services in `lib/api/` for external integrations
- Models in `lib/models/` for data structures
- Uses **Dio** for robust HTTP requests and **http** for basic API calls

### Key Dependencies
- `supabase_flutter: ^2.5.6` - Authentication and backend services
- `provider: ^6.0.3` - State management
- `go_router: ^14.2.3` - Navigation
- `dio: ^5.7.0` - HTTP client
- `flutter_secure_storage: ^9.2.2` - Secure credential storage
- `syncfusion_flutter_charts: ^27.1.50` - Health metrics visualization
- `logger: ^2.4.0` - Logging

## Development Commands

### Running the App
```bash
flutter run
```

### Testing
```bash
flutter test
```

### Code Analysis
```bash
flutter analyze
```

### Dependencies
```bash
flutter pub get
flutter pub upgrade
```

### Platform-specific Builds
```bash
# iOS
flutter build ios

# Android
flutter build apk
flutter build appbundle

# Web
flutter build web
```

## Project Structure

```
lib/
├── api/                 # External service integrations
├── models/              # Data models and structures
├── screens/             # UI screens/pages
├── state/               # State management (Provider)
├── utils/               # Helper functions and validators
├── widgets/             # Reusable UI components
└── main.dart           # App entry point
```

## Environment Setup

1. Ensure `.env` file exists in project root with required environment variables:
   - `SUPABASE_URL` - Supabase project URL
   - `SUPABASE_ANON_KEY` - Supabase anonymous key

2. Platform-specific setup may be required for:
   - iOS: Podfile configuration for native dependencies
   - Android: Gradle configuration updates
   - Web: Ensure proper manifest.json and index.html setup

## Testing Strategy

- Unit tests for models and utilities
- Widget tests for UI components
- Integration tests for authentication flows
- Uses `mockito: ^5.0.16` for mocking in tests

## Code Style & Linting

- Follows `package:flutter_lints/flutter.yaml` standards
- Custom linting rules can be added to `analysis_options.yaml`
- Standard Flutter formatting conventions

## Health Data & Privacy

- Health metrics tracking for sleep, nutrition, and activity
- Secure storage for sensitive user data
- Privacy-compliant data handling (positioned as low-regulatory software service)

## Common Development Patterns

- Use Provider for state management across the app
- Implement proper error handling in authentication flows
- Follow MaterialApp.router pattern with GoRouter
- Use async/await with proper error handling for API calls
- Leverage flutter_secure_storage for sensitive data persistence