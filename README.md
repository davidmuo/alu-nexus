# ALU Nexus

A Flutter + Firebase mobile application that connects ALU students seeking
internship experience with student-led startups inside the ALU ecosystem.

## Key features

| Feature | Notes |
|---|---|
| ALU-only authentication | Firebase Auth (email/password) restricted to `@alustudent.com` / `@alueducation.com` |
| Role-based onboarding | Separate student and startup flows; admins verify startups |
| Startup verification workflow | Startups register → admin approves/rejects → only verified startups can publish |
| Opportunity feed | Real-time Firestore stream with search, category, commitment and paid/unpaid filters |
| Skill matching | The feed's "Recommended for you" card is chosen by overlap between the student's onboarding skills and each posting's required skills |
| Applications | Cover-letter submission with duplicate prevention, live pipeline tracker (Applied → Reviewing → Shortlisted → Interviewing → Accepted), withdraw support |
| Bookmarks | Persisted locally (`SharedPreferences`), synced across every screen via a `ChangeNotifier` store |
| Notifications | Real-time unread badge, mark-one/mark-all read |
| Admin dashboard | Pending/approved/rejected tabs with audit-logged decisions |

## Getting started

```bash
flutter pub get
flutter run
```

Two flags in `lib/main.dart` select the backend:

| `kDemoMode` | `kUseEmulators` | Behavior |
|---|---|---|
| `true` | — | In-memory demo data; no Firebase needed at all |
| `false` | `true` | Real Firebase SDKs against the local **Emulator Suite** — run `firebase emulators:start --only auth,firestore` first (Emulator UI at localhost:4000) |
| `false` | `false` | Production Firebase (`flutterfire configure` per [SETUP.md](SETUP.md)) |

The demo repositories subclass the production ones, so all three modes run
the identical UI, routing, and state layer.

> Physical Android device + emulators: run `adb reverse tcp:9099 tcp:9099`
> and `adb reverse tcp:8080 tcp:8080` so the phone's localhost reaches the
> host machine.

## Architecture

Feature-first Clean Architecture with Cubit (bloc) state management:

```
lib/
├── core/            # theme, constants, validators, shared widgets, services
├── features/
│   └── <feature>/
│       ├── data/          # models (Firestore serialization) + repositories
│       ├── domain/        # entities
│       └── presentation/  # cubits + screens
├── router/          # GoRouter with auth-guard redirects
└── main.dart        # composition root (demo/live wiring)
```

Full rationale, diagrams, and scalability discussion: [REPORT.md](REPORT.md).
Demo walkthrough mapped to the grading rubric: [DEMO_SCRIPT.md](DEMO_SCRIPT.md).

## Quality

- `flutter analyze` — **0 issues**
- `flutter test` — validator unit tests, all passing
- No hard-coded UI data: every screen renders from Cubit state
