# SproutLy

SproutLy is a comprehensive, interactive mobile application designed to help parents and therapists support children (especially those with special needs or autism) through visual schedules, emotion regulation, and structured routines. 

## 🌟 Key Features

*   **Visual Schedules & Boards:** Create custom visual schedules to help children understand their day. Includes various board types:
    *   **Schedule Board:** Step-by-step daily routines.
    *   **First-Then Board:** Simple cause-and-effect structure (e.g., "First work, Then play").
    *   **Waiting Board:** Visual timers to help children cope with waiting periods.
    *   **Emotion Board:** Helps children identify their feelings and guides them through emotional regulation steps, followed by a reward.
*   **Activity Catalog:** A rich library of customizable activities (e.g., self-care like "Memakai Sepatu" or "Sikat Gigi", therapy, learning, and play). Activities can be broken down into individual visual steps.
*   **SproutVoice (TTS):** Integrated Text-to-Speech to read activity instructions aloud, making the app accessible for pre-readers.
*   **Behavior Analytics:** Track progress over time with built-in analytics, activity logs, and a visual calendar history.
*   **SproutBuddy:** An AI-powered companion (powered by Google Gemini) to provide tailored recommendations and interactive support.
*   **Therapist Integration:** Link your child's progress with professional therapists for better monitoring and tailored advice.

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (v3.11.5 or higher)
- Android Studio / Xcode for emulators
- A Google Gemini API Key

### Installation

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/miaikoo/sproutly.git
    cd sprout_ly_app
    ```

2.  **Install Dependencies:**
    ```bash
    flutter pub get
    ```

3.  **Run the App:**
    Because the app relies on the Gemini API for SproutBuddy and recommendations, you must pass your API key as a Dart define during compilation:
    ```bash
    flutter run --dart-define=GEMINI_API_KEY=your_gemini_api_key_here
    ```

4.  **Build APK (Android):**
    ```bash
    flutter build apk --dart-define=GEMINI_API_KEY=your_gemini_api_key_here
    ```

## 🛠 Tech Stack

- **Framework:** Flutter (Dart)
- **State Management:** Riverpod
- **Routing:** GoRouter
- **Database/Backend:** Firebase (Auth, Firestore, Storage)
- **AI Integration:** Google Gemini API
- **Local Storage:** Shared Preferences
- **Accessibility:** Flutter TTS (Text-to-Speech)

## 🎨 Assets & Icons

- All custom illustrations and icons are located in `assets/images/` and `assets/icons/`.
- App launcher icons are generated using the `flutter_launcher_icons` package.

---
*Built with ❤️ for Gemastik 2026*
