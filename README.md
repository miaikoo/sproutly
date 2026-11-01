<p align="center">
  <img src="assets/images/Logo.png" alt="Sprout.ly logo" width="96">
</p>

<h1 align="center">Sprout.ly</h1>

<p align="center">
  An AI-assisted visual support app that helps parents of autistic children build daily routines at home.<br>
  Built by team Green Enough for GEMASTIK XIX (Software Development).
</p>

<p align="center">
  <a href="https://youtu.be/7dXHDLK55Y4">
    <img src="https://i.ytimg.com/vi/7dXHDLK55Y4/hqdefault.jpg" alt="Watch the Sprout.ly demo video" width="480">
  </a>
  <br>
  <a href="https://youtu.be/7dXHDLK55Y4">Watch the demo video</a>
</p>

## The problem

Evidence-based early intervention for Autism Spectrum Disorder is recommended at 20–40 hours a week, but professional therapy typically covers 1–2 hours. Most of the work of building daily living skills therefore happens at home, with parents acting as co-therapists.

Visual schedules help, but research suggests they don't produce lasting change without consistent prompting, reinforcement and evaluation. Practitioners we interviewed also told us that existing tools are subscription-based and hard to adapt to an Indonesian context, and that communication with parents still relies on group chats and quarterly reports.

Sprout.ly brings those pieces together in one Indonesian-language app. It supports parents and therapists rather than replacing them: it is not a diagnostic tool or a substitute for professional therapy, and every AI output is a suggestion the parent can accept or ignore.

## Modules

| Module | What it does |
| --- | --- |
| **SproutPlan** | Schedule, first-then, waiting and emotion boards, built from an activity catalog or the parent's own cards and photos |
| **SproutVoice** | On-device Indonesian text-to-speech for step-by-step instructions and praise, plus activity reminders and points/EXP that can be spent in the companion store |
| **SproutGuide** | AI activity recommendations and progress analysis, each with a short reason |
| **SproutTrack** | Completion, mood and transition analytics over 7 days, 30 days or all time, with a calendar history and reports |
| **SproutLink** | Links a child to a therapist, who can view progress and leave session notes |

## How the AI is designed

- **Reinforcement level is decided by rules, not a model.** Praise has to be immediate, consistent and available offline, so a deterministic policy picks gentle, standard or celebratory from the current mood and the last five logs.
- **The language model only sees what it needs.** Requests carry attributes such as age, preferences and recent activity outcomes, without the child's name or photo.
- **Output is checked before it is shown.** Replies are parsed as JSON and matched against the activity catalog, and a recommendation outside the catalog is replaced with a default activity.
- **A service failure doesn't stop the routine.** Rule-based fallbacks cover recommendations and analysis, and voice prompting and reinforcement run on the device.

## Tech stack

| Layer | Tools |
| --- | --- |
| App | Flutter, Dart, Riverpod, go_router |
| Backend | Firebase Authentication, Cloud Firestore, Firebase Storage |
| AI | REST calls with Dio, `flutter_tts` for on-device speech |
| Design | Figma |

## Running the project

You need Flutter with Dart SDK `^3.11.5`, an Android device or emulator, and a Gemini API key.

```bash
git clone https://github.com/miaikoo/sproutly.git
cd sproutly
flutter pub get
flutter run --dart-define=GEMINI_API_KEY=your_key_here
flutter test
```

The repository is configured for the team's Firebase project. To use your own, run `flutterfire configure` and deploy `firestore.rules` and `storage.rules`.

A key passed with `--dart-define` is compiled into the app, so don't distribute a build containing an unrestricted key. For a shared build, set `AI_PROXY_URL` to a backend that holds the key.

## Project status

Sprout.ly was submitted as a competition prototype and hasn't been released to families. The notes below list where this code differs from the [final proposal](#notes-proposal-vs-this-code).

### Evaluation

The proposal defines these as a test plan, and no results are claimed here:

- **Functional testing:** black-box scenarios for all 14 functional requirements, in [PENGUJIAN_FUNGSIONAL.md](PENGUJIAN_FUNGSIONAL.md).
- **Usability testing:** 10 core tasks and the System Usability Scale (target ≥ 68), in [EVALUASI_USABILITY.md](EVALUASI_USABILITY.md).
- **Expert validation:** a Likert-scale review with autism therapists (target recommendation acceptance ≥ 70%).
- **Effect on daily living skills:** a pilot study left as future work, so Sprout.ly's effectiveness for children hasn't been tested.

The automated test suite (118 tests) covers the services and core logic.

### Notes: proposal vs this code

| Area | Final proposal | This code |
| --- | --- | --- |
| Language model | Llama 3.3 70B Instruct through OpenRouter | Gemini 2.0 Flash through the Gemini API |
| Praise wording | Personalised by the language model, with fixed sentences as a fallback | Fixed sentences only; the level is still chosen by the rule-based policy |
| Recommendation evidence | A traceable statement such as "based on 12 activity logs in the last 7 days" | The model's confidence shown as a percentage |
| Diagnosis and medication guardrail | Banned in the system prompt and checked in the output | Banned in the analysis prompt only; output isn't checked for it |
| AI usage limits | One recommendation a day and one analysis a week per child | Not enforced |
| Recommendation history | Saved, so acceptance rate can be measured | Not saved, so acceptance rate can't be calculated yet |
| Therapist linking | Invite code with therapist confirmation in the workflow diagram | Parent links by therapist email, with no confirmation step |
| Server-side logic | Firebase Cloud Functions | Not used; the app calls services directly |
| Data model | Also includes `care_links`, `recommendations`, `insights`, `store_items` and `activity_catalog` collections | Not in Firestore; the link is a field on the child, and the catalog and store are bundled in the app |

### Other known limitations

- Release builds are signed with the debug key, so they can't be published to the Play Store yet.
- iOS, web and desktop folders come from the Flutter template; the proposal targets Android.

## Team

Green Enough, supervised by Hadziq Fabroyir, S.Kom., Ph.D.

- Miskiyah
- Hikmia Sofia Nur Izzati
- Siti Zahra Ananda Kurniawan

## License

No license has been chosen for this code, so all rights are reserved by its authors. Third-party libraries and assets keep their own licenses.
