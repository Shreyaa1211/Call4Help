# 🚨 Call4Help — Voice-Activated Women Safety App

A Flutter app that listens for the wake word **"help"** — even when the app is in the background — and automatically sends an SOS email with the user's live GPS location to their emergency contacts.

Built for hands-free use in situations where unlocking a phone or pressing a button isn't possible.

## ✨ Features

- 🎙️ **Wake-word detection** — on-device keyword spotting with [Picovoice Porcupine](https://picovoice.ai/platform/porcupine/); no audio leaves the phone
- 🔁 **Always listening** — runs as an Android foreground service with a persistent notification, so it works when the app is closed
- ⏱️ **5-second cancel window** — a full-screen countdown lets the user cancel a false alarm before anything is sent
- 📍 **Live location** — grabs a high-accuracy GPS fix and includes a Google Maps link
- 📧 **Automatic SOS email** — sends the alert to emergency contacts over Gmail SMTP
- ✅ **Clear status UI** — "Listening", "SOS Activated" and "SOS Sent" states

## 🛠️ Tech Stack

| Area | Tools |
|---|---|
| Framework | Flutter (Dart) |
| Wake word | `porcupine_flutter` |
| Background execution | `flutter_background_service`, `flutter_local_notifications` |
| Location | `geolocator` |
| Alerts | `mailer` (Gmail SMTP) |
| Permissions & storage | `permission_handler`, `shared_preferences` |

## ⚙️ How It Works

```
"help" detected ──► SOS screen + 5s countdown ──► (not cancelled) ──► get GPS ──► email contacts
        ▲                                   │
 foreground service                      CANCEL ──► back to listening
```

## 📂 Project Structure

```
lib/
├── main.dart                     # App entry, starts the background service
├── config/
│   └── secrets.example.dart      # Template for API keys (copy to secrets.dart)
├── screens/
│   ├── home_screen.dart          # Wake-word listener, countdown & status UI
│   └── background_service.dart   # Foreground service that keeps listening
└── services/
    └── sos_service.dart          # Location lookup + SOS email
Assets/
└── help.ppn                      # Porcupine wake-word model for "help"
```

## 🚀 Getting Started

**Prerequisites:** Flutter SDK (Dart ^3.7.2) and an Android device or emulator with a microphone.

```bash
git clone https://github.com/Shreyaa1211/call4help.git
cd call4help
flutter pub get
```

**Add your keys.** Secrets are kept out of git, so copy the template and fill it in:

```bash
cp lib/config/secrets.example.dart lib/config/secrets.dart
```

| Value | Where to get it |
|---|---|
| `picovoiceAccessKey` | Free account at [console.picovoice.ai](https://console.picovoice.ai/) |
| `senderGmail` / `senderGmailAppPassword` | A Gmail account with 2-Step Verification and an [App Password](https://myaccount.google.com/apppasswords) |
| `sosRecipients` | Emails of your emergency contacts |

> The bundled `help.ppn` model is tied to the Picovoice account that created it. If your key rejects it, train a free "help" keyword in the Picovoice Console and replace `Assets/help.ppn`.

**Run it:**

```bash
flutter run
```

Grant microphone, location and notification permissions when asked, then say **"help"**.

## 🔮 Future Improvements

- SMS and WhatsApp alerts alongside email
- Manage emergency contacts in the app
- Periodic live-location updates after an SOS
- iOS background support
