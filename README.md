# Holdy 🛑🤔

> **Impulsive Buying Intervention App** — Pause and think before you buy.

Holdy is an iOS app designed for Apple Developer Academy Challenge 4. It acts as an "impulse brake" for Gen Z shoppers (21–28 years old) who struggle with impulsive buying both online and offline. By utilizing conversational AI (Google Gemini) with a psychological framework, Holdy guides users through a reflective pause, helping them make more rational purchasing decisions without feeling judged.

---

## ✨ Key Features

- 💬 **AI Reflective Chat**: Conversational AI that asks psychological framework-based questions to help you rethink your purchase.
- 📸 **Camera & Image Analysis**: See something you like in a physical store? Snap a photo, and the AI will analyze the item and start a reflection session.
- 📱 **Screenshot Shortcut (OCR)**: Screenshot an item on Shopee or TikTok Shop, and Holdy will automatically extract the name and price to start a session.
- 🔗 **Share Extension**: Share a product link directly to Holdy to evaluate it seamlessly.
- 🧩 **Widgets**: Lock Screen and Home Screen widgets for passive awareness and quick access.
- 🔔 **Smart Reminders**: 5-minute incomplete session reminders and weekly recap notifications.

---

## 🛠 Tech Stack

- **Frontend**: SwiftUI (iOS 17+)
- **Architecture**: Feature-based MVVM with Core Layer
- **Database**: SwiftData (Local persistence)
- **AI Backend**: Google Gemini 3.6 Flash via REST / SDK
- **On-device ML**: Apple Vision framework (for OCR)
- **Frameworks**: WidgetKit, UserNotifications, AppIntents (Shortcuts)

---

## 🚀 Getting Started

### Prerequisites
- Xcode 15.0 or later
- iOS 17.0 or later (iPhone only)
- Active Google Gemini API Key

### Installation & Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/zildjianvitoo/holdy.git
   cd holdy
   ```

2. **Setup Gemini API Key**
   - Get your API key from [Google AI Studio](https://aistudio.google.com/).
   - *(Note for team: Add instructions here on where to place the API key in the code or environment variables once the project is set up).*

3. **Open the project**
   - Open `holdy.xcodeproj` in Xcode.
   - Wait for Swift Package Manager to resolve dependencies.

4. **Build and Run**
   - Select an iOS 17+ Simulator or your physical iPhone.
   - Hit `Cmd + R` to run the app.

---

## 📚 Documentation

For more detailed information on how the app is built and how to contribute, please refer to the following documents:

- 📄 [**Product Requirements Document (PRD)**](PRD_HOLDY.md) — Detailed feature scope, UX flows, data models, and API specs.
- 🤝 [**Contributing Guide**](CONTRIBUTING.md) — Git branching strategy (Git Flow), Conventional Commits, PR guidelines, and architecture rules.

---

## 👥 Team

Built for **Apple Developer Academy Challenge 4**.
