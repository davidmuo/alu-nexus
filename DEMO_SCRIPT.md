# ALU Nexus — Demo Script (rubric-mapped)

A ~10-minute walkthrough. Each section names the rubric criterion it earns,
what to show, and the one-sentence explanation to give while showing it.

> **Setup (production console):** set `kDemoMode = false`,
> `kUseEmulators = false` in `lib/main.dart`; open the Firebase Console with
> **Authentication → Users** and **Firestore → Data** visible; run the app.
>
> **Setup (emulator variant — works today):**
> ```
> firebase emulators:start --only auth,firestore --project=alunexus-b85a1
> bash tool/seed_emulator.sh
> flutter run -d chrome     # kDemoMode=false, kUseEmulators=true
> ```
> Keep the **Emulator UI** (http://localhost:4000) visible instead of the
> console — its Authentication and Firestore tabs update live the same way.
>
> **Demo accounts (seeded):**
>
> | Role | Email | Password |
> |---|---|---|
> | Student | `student@alustudent.com` | `Student123` |
> | Startup | `founder@alustudent.com` | `Founder123` |
> | Admin | `admin@alueducation.com` | `Admin1234` |
>
> The student account has seeded skills (Flutter, Dart, Firebase, Figma — so
> the skill-match ranking fires), one shortlisted application with a status
> note, and an unread notification. Register a *fresh* student on camera for
> the auth demo; switch to the seeded accounts for the role demos.

---

## 1. UI/UX Design & User Experience (10 pts)

**Show:** splash → login → home feed. Scroll the color-blocked cards; tap
the pill tabs (Discover / Saved / categories); open the filter sheet; open
an opportunity detail (dark screen).

**Say:** "The design system is bold color-blocking — electric purple, red,
and yellow cards on a clean canvas, Satoshi type, pill-shaped controls.
Color always carries meaning: each card's color follows you into its detail
screen, text auto-inverts for contrast, and semantic colors are reserved
for status. Every list has loading shimmer, error-with-retry, and empty
states — no state of the app is a blank screen."

**Interactions to demonstrate:** pull-to-refresh, bookmark toggle syncing
across feed/Saved tab/detail simultaneously, filter pills, the pipeline
visualization in the tracker.

## 2. Firebase Authentication (4 pts)

**Show:** register with a non-ALU email → validation blocks it. Register
with a fresh `something@alustudent.com` → account created; the new UID
appears in Authentication → Users (console or Emulator UI). Sign out, sign
in as `student@alustudent.com`, force-quit and reopen — session persists.

**Say:** "Auth is Firebase email/password gated to ALU domains at the
validator layer. `AuthCubit` subscribes to `authStateChanges`, and
GoRouter's redirect consumes that state — route protection is declarative,
so a deep link can never reach a protected screen unauthenticated."

## 3. Firebase CRUD Operations (6 pts)

**Show (data viewer side-by-side):**
- **Create** — sign in as `founder@alustudent.com`, post a new opportunity
  → document appears in `opportunities`; the student feed shows it in real
  time without refresh.
- **Read** — the feed itself: point out the query filters
  (`isActive == true`, `startupVerified == true`).
- **Update** — as the founder, open Applicants and shortlist/advance the
  seeded application → watch `applications/seed-app-1.status` change in the
  data viewer → sign in as the student → tracker pipeline has advanced.
- **Delete/close** — withdraw an application (soft-delete to `withdrawn`)
  and close an opportunity (`isActive: false`); explain why soft deletes
  preserve the audit trail.

**Say:** "Every mutation goes through a repository; the UI reacts to the
Firestore snapshot stream, not the local call — what you see on screen is
the backend echoing the write back."

## 4. State Management & Architecture (8 pts)

**Show:** the status update from §3 again, narrating the chain. Then open
`lib/features/opportunities/presentation/cubit/opportunity_cubit.dart`.

**Say:** "Five Cubits own all app state. A write commits to Firestore, the
snapshot stream emits, the Cubit emits a new immutable state, and every
`BlocBuilder` rebuilds — that's why the applicant list, tracker, and
profile stats all updated from one status change. States are sealed
(`Loading | Loaded | Error`), so loading and failure handling is
exhaustive. And because screens only know Cubits, the whole app also runs
in demo mode with in-memory repositories — proof the layers are decoupled."

**Bonus:** flip `kDemoMode = true` and hot-restart to show the same UI on
in-memory data.

## 5. Feature Implementation & Functionality (7 pts)

**Show quickly (as `student@alustudent.com`):**
- Skill matching: the Flutter Developer card ranks first with
  "★ Matches 3 skills" (skills came from onboarding).
- Duplicate application → apply twice to the same role → blocked with a
  clear message.
- Bookmarks: save from the feed → Saved pill tab → survives restart.
- Notifications: unread dot on the bell; open, mark all read.
- Verification workflow: register a new startup account → it's `pending`
  and cannot publish → sign in as admin → approve with a note → founder can
  now post, and the startup shows the verified badge.
- Invalid input: short cover letter, bad URL, weak password — all caught.

## 6. Technical Explanation (5 pts)

Covered by the narration above. Prepared trade-off answers live in
REPORT.md §3 (why Cubit over BLoC/Provider/Riverpod), §4 (why denormalized
documents), §8 (client-side vs server-side matching) and CODE_TOUR.md.

## 7. Code Quality (5 pts)

**Show:** `flutter analyze` → 0 issues; `flutter test` → 16 passing;
feature-first folder tree; doc comments on entities, repositories, stores.

## 8. Report Quality (5 pts)

REPORT.md / the submitted PDF — IEEE references, architecture diagram, data
model, security rules, scalability, challenges & lessons learned.

## 9. Product Thinking & Originality (5 pts)

**Say:** "Three decisions came from thinking about ALU specifically:
(1) startup *verification* — students must be protected from fake postings,
so publishing is gated on admin approval and the feed filters verified
startups at the query level; (2) *skill matching* — onboarding skills drive
the feed ranking, not decoration; (3) the *transparent pipeline* — informal
internships die in silence, so every application has a visible status,
notes, and interview dates. Together they turn an informal WhatsApp process
into an accountable marketplace."
