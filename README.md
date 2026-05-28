<div align="center">

# 👓 EchoSee

### *Your Smart Glasses Companion — Hear More, See More*

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Supabase](https://img.shields.io/badge/Supabase-Backend-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white)](https://supabase.com)
[![License](https://img.shields.io/badge/License-MIT-yellow?style=for-the-badge)](LICENSE)
[![Version](https://img.shields.io/badge/Version-1.0.0-blue?style=for-the-badge)](https://github.com/usmanch-15/Echosee)

<br/>

> **EchoSee** is an AI-powered Flutter mobile app that acts as a companion for Bluetooth smart glasses. It provides real-time speech-to-text transcription, multi-language translation, lip movement tracking, and environmental sound recognition — all in one seamless experience.

</div>

---

## 📋 Table of Contents

- [Features](#-features)
- [Tech Stack](#-tech-stack)
- [Architecture](#-architecture)
- [Project Structure](#-project-structure)
- [Getting Started](#-getting-started)
- [Database Schema](#-database-schema)
- [API Reference](#-api-reference)
- [Features Matrix (Free vs Premium)](#-features-matrix)
- [Common Issues & Solutions](#-common-issues--solutions)
- [Contributing](#-contributing)

---

## ✨ Features

| Feature | Description |
|---|---|
| 🎙️ **Speech-to-Text** | Real-time transcription using the device microphone with high accuracy |
| 🌍 **Multi-Language Translation** | Translate transcripts into multiple languages instantly |
| 👄 **Lip Tracking** | Detect and track lip movements via camera using Google ML Kit |
| 🔊 **Sound Recognition** | Classify environmental sounds using the YamNet TFLite model |
| 👥 **Speaker Identification** | Differentiate and label multiple speakers in a conversation |
| ☁️ **Cloud Sync** | All transcripts synced securely to Supabase (PostgreSQL) |
| 🌙 **Dark / Light Theme** | Full theme switching support |
| 🔐 **Auth System** | Email/password signup, login, and password reset |
| 💎 **Premium Tier** | Unlock offline mode, exports, full translation, and more |

---

## 🛠 Tech Stack


**Frontend**
- [Flutter](https://flutter.dev) `>=3.0.0` — Cross-platform UI framework
- [Provider](https://pub.dev/packages/provider) — State management
- [speech_to_text](https://pub.dev/packages/speech_to_text) — Real-time speech recognition
- [camera](https://pub.dev/packages/camera) — Camera access for lip tracking
- [google_mlkit_face_detection](https://pub.dev/packages/google_mlkit_face_detection) — ML-powered face/lip detection
- [tflite_flutter](https://pub.dev/packages/tflite_flutter) — On-device YamNet sound classification
- [flutter_blue_plus](https://pub.dev/packages/flutter_blue_plus) — Bluetooth smart glasses connectivity
- [sound_stream](https://pub.dev/packages/sound_stream) — Continuous audio stream processing

**Backend**
- [Supabase](https://supabase.com) — PostgreSQL database, authentication, and REST API

**Storage**
- [shared_preferences](https://pub.dev/packages/shared_preferences) — Local preferences
- Supabase cloud storage — Transcript and user data persistence

---

## 🏗 Architecture

EchoSee follows a clean layered architecture:

```
Presentation Layer  →  Providers (State)  →  Services / Repositories  →  Supabase / Device APIs
```

**Design Pattern:** Provider-based MVVM  
**State Management:** `ChangeNotifier` with `Provider`  
**Backend:** Supabase REST API with RPC functions  

### Core Providers

| Provider | Responsibility |
|---|---|
| `AuthProvider` | Login, signup, logout, session & premium management |
| `TranscriptProvider` | CRUD for transcripts, translation, speaker naming |
| `AppThemeProvider` | Light/Dark theme toggling and persistence |

---

## 📁 Project Structure

```
lib/
├── main.dart                          # App entry point & Supabase init
├── core/
│   ├── constants/
│   │   ├── app_colors.dart            # Color palette
│   │   ├── app_strings.dart           # String constants
│   │   ├── app_styles.dart            # Text styles
│   │   └── keys.dart                  # Global keys
│   ├── theme/                         # Light & dark ThemeData
│   └── utils/
│       └── navigation_service.dart    # Named route management
├── data/
│   ├── models/
│   │   ├── user_model.dart
│   │   ├── transcript_model.dart
│   │   └── user_settings_model.dart
│   └── repositories/
│       ├── supabase_user_repository.dart
│       ├── supabase_transcript_repository.dart
│       ├── translation_repository.dart
│       └── settings_repository.dart
├── providers/
│   ├── auth_provider.dart
│   ├── transcript_provider.dart
│   └── app_theme_provider.dart
├── services/
│   ├── speech_service.dart            # Speech-to-text engine
│   ├── lip_tracking_service.dart      # Face + lip detection
│   └── yamnet_service.dart            # Sound classification
└── presentation/
    ├── screens/
    │   ├── splash_screen.dart
    │   ├── login_screen.dart
    │   ├── signup_screen.dart
    │   ├── main_screen.dart
    │   ├── transcript_list_screen.dart
    │   ├── transcript_detail_screen.dart
    │   ├── sound_recognition_screen.dart
    │   ├── lip_tracking_screen.dart
    │   ├── history_screen.dart
    │   ├── profile_screen.dart
    │   ├── settings_screen.dart
    │   └── payment_screen.dart
    └── widgets/
        └── [Reusable UI components]
```

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK `>=3.0.0 <4.0.0`
- Dart SDK `>=3.0.0`
- Android Studio / VS Code with Flutter plugin
- A [Supabase](https://supabase.com) account

### Installation

**1. Clone the repository**
```bash
git clone https://github.com/usmanch-15/Echosee.git
cd Echosee
```

**2. Install dependencies**
```bash
flutter pub get
```

**3. Configure Supabase**

Open `lib/main.dart` and replace the placeholders with your Supabase project credentials:

```dart
await Supabase.initialize(
  url: 'YOUR_SUPABASE_URL',
  anonKey: 'YOUR_SUPABASE_ANON_KEY',
);
```

**4. Set up the database**

Run the SQL schema from the [Database Schema](#-database-schema) section in your Supabase SQL editor.

**5. Run the app**
```bash
flutter run
```

### Test Account (Demo)

```
Email:    demo@echosee.app
Password: DemoPassword123
```

---

## 🗄 Database Schema

### `users`
```sql
CREATE TABLE users (
  id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email            VARCHAR UNIQUE NOT NULL,
  name             VARCHAR NOT NULL,
  profile_image_url VARCHAR,
  created_at       TIMESTAMP DEFAULT NOW(),
  is_premium       BOOLEAN DEFAULT false,
  premium_expiry   TIMESTAMP,
  preferences      JSONB DEFAULT '{}',
  usage_stats      JSONB DEFAULT '{}'
);
```

### `transcripts`
```sql
CREATE TABLE transcripts (
  id                 UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id            UUID REFERENCES users(id) ON DELETE CASCADE,
  title              VARCHAR NOT NULL,
  content            TEXT NOT NULL,
  date               TIMESTAMP NOT NULL,
  duration           INTEGER,
  language           VARCHAR DEFAULT 'en',
  has_translation    BOOLEAN DEFAULT false,
  is_starred         BOOLEAN DEFAULT false,
  translated_content TEXT,
  translated_language VARCHAR,
  created_at         TIMESTAMP DEFAULT NOW(),
  updated_at         TIMESTAMP DEFAULT NOW()
);
```

### `speaker_segments`
```sql
CREATE TABLE speaker_segments (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  transcript_id UUID REFERENCES transcripts(id) ON DELETE CASCADE,
  speaker_id    INTEGER NOT NULL,
  speaker_name  VARCHAR,
  text          TEXT NOT NULL,
  start_time    INTEGER,
  end_time      INTEGER
);
```

### `translations`
```sql
CREATE TABLE translations (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  transcript_id   UUID REFERENCES transcripts(id) ON DELETE CASCADE,
  translated_text TEXT NOT NULL,
  target_language VARCHAR NOT NULL,
  created_at      TIMESTAMP DEFAULT NOW(),
  UNIQUE(transcript_id, target_language)
);
```

---

## 🔌 API Reference

EchoSee uses Supabase's auto-generated REST API.

### Auth
| Method | Endpoint | Description |
|---|---|---|
| `POST` | `/auth/v1/token` | Login |
| `POST` | `/auth/v1/signup` | Register |
| `POST` | `/auth/v1/recover` | Reset password |

### Users
| Method | Endpoint | Description |
|---|---|---|
| `GET` | `/rest/v1/users?id=eq.{id}` | Get user profile |
| `PUT` | `/rest/v1/users?id=eq.{id}` | Update profile |
| `DELETE` | `/rest/v1/users?id=eq.{id}` | Delete account |

### Transcripts
| Method | Endpoint | Description |
|---|---|---|
| `GET` | `/rest/v1/transcripts?user_id=eq.{id}` | List transcripts |
| `POST` | `/rest/v1/transcripts` | Create transcript |
| `PUT` | `/rest/v1/transcripts?id=eq.{id}` | Update transcript |
| `DELETE` | `/rest/v1/transcripts?id=eq.{id}` | Delete transcript |

---

## 💎 Features Matrix

| Feature | Free | Premium |
|---|:---:|:---:|
| Speech-to-Text | ✅ | ✅ |
| Basic Transcription | ✅ | ✅ |
| Cloud Sync | ✅ | ✅ |
| Translation | 1 language | All languages |
| Speaker Identification | Limited | ✅ Full |
| Lip Tracking | Limited | ✅ Full |
| Sound Recognition | Limited | ✅ Full |
| Export Transcripts | ❌ | ✅ |
| Offline Mode | ❌ | ✅ |
| Priority Support | ❌ | ✅ |

---

## 🐛 Common Issues & Solutions

**Microphone not working?**
- Ensure microphone permissions are granted in device settings
- Check `permission_handler` setup in `AndroidManifest.xml` and `Info.plist`

**Translation not available?**
- Verify the user has a valid premium subscription
- Confirm the target language code is correct (e.g., `es` for Spanish, `fr` for French)

**Supabase connection failed?**
- Double-check the `SUPABASE_URL` and `SUPABASE_ANON_KEY` in `main.dart`
- Ensure your device has an active internet connection
- Review the RLS (Row Level Security) policies on your Supabase tables

**Camera / Lip Tracking issues?**
- Grant camera permissions explicitly
- Ensure `google_mlkit_face_detection` model files are downloaded properly

---

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork this repository
2. Create a new branch: `git checkout -b feature/your-feature-name`
3. Commit your changes: `git commit -m 'Add: your feature description'`
4. Push to your branch: `git push origin feature/your-feature-name`
5. Open a Pull Request

Please make sure your code follows the existing architecture and passes all tests before submitting.

---

## 📄 License

This project is licensed under the [MIT License](LICENSE).

---

<div align="center">

Made with ❤️ using Flutter & Supabase

⭐ **If you found this project helpful, please give it a star!** ⭐

</div>
