# Code Tour — study guide for the demo

Read top to bottom once, then open each file alongside. Every question an
evaluator is likely to ask maps to one of these stops.

---

## Stop 1 — Composition root: `lib/main.dart`

- `kDemoMode` flag chooses between demo cubits and real
  Firebase-backed cubits. Both satisfy the *same types*, which is why the
  rest of the app never checks the flag.
- `MultiBlocProvider` provides the five Cubits app-wide. They're created
  once in `initState` and closed in `dispose` — Cubits own stream
  subscriptions, so their lifecycle must be managed.
- **Likely question:** *"How would you switch this to production?"* →
  "Set `kDemoMode = false`; `Firebase.initializeApp` runs with the
  generated `firebase_options.dart`, and the same Cubit types are
  constructed with real repositories."

## Stop 2 — A repository: `lib/features/auth/data/repositories/auth_repository.dart`

- Note the **lazy getters**: `FirebaseAuth get _auth => FirebaseAuth.instance;`
  Firebase is only touched when a method runs — not at construction.
- `authStateChanges` maps the Firebase user to our domain `AppUser` by
  fetching the Firestore profile (`users/{uid}`).
- `signUpWithEmail` = Auth account + Firestore profile document in one flow.
- **Likely question:** *"Why not call Firestore from the screen?"* →
  "Screens depend on Cubits, Cubits on repositories. Swapping the data
  source (demo mode) proves the seam works."

## Stop 3 — A cubit: `lib/features/opportunities/presentation/cubit/opportunity_cubit.dart`

- Holds filter fields (`_searchQuery`, `_typeFilter`, ...) and one stream
  subscription. Every filter change cancels the old subscription and opens
  a new Firestore query — the UI just re-renders from state.
- Sealed states: `OpportunityInitial | Loading | Loaded | Error`.
- **Likely question:** *"Walk me through a status update reaching the
  screen."* → "Startup calls `updateStatus` → repository writes to
  Firestore → the `snapshots()` stream emits → Cubit `emit(Loaded(...))` →
  every `BlocBuilder<ApplicationCubit>` rebuilds. No polling, no manual
  refresh."

## Stop 4 — Demo mode: `lib/core/demo/demo_cubits.dart`

- `_DemoAuthRepository extends AuthRepository` overrides the I/O methods
  with in-memory data; `DemoAuthCubit extends AuthCubit` passes it up
  through the normal constructor.
- **This is the architecture proof**: the entire UI/state layer runs
  identically with or without Firebase.

## Stop 5 — Routing: `lib/router/app_router.dart`

- `refreshListenable` wraps `AuthCubit`'s stream, so any auth change
  re-evaluates `redirect`.
- The guard: unauthenticated → `/login`; authenticated but not onboarded →
  role-specific onboarding; `/home` dispatches by role (student / startup /
  admin).
- **Likely question:** *"Can a deep link skip login?"* → "No — redirect is
  centralized and runs on every navigation, not per-screen."

## Stop 6 — Skill matching: `opportunity_feed_screen.dart`, `_content()`

- Case-insensitive set overlap between `user.skills` (from onboarding) and
  each posting's `skills`. Highest overlap becomes the featured card with
  "Matches N of your skills".
- Complexity O(n·m); §8 of REPORT.md explains the server-side upgrade path
  (`arrayContainsAny` + Cloud Function ranking).

## Stop 7 — Bookmarks: `lib/core/services/bookmark_store.dart`

- Deliberate exception to Cubit: a `ChangeNotifier` singleton persisted to
  `SharedPreferences`.
- **Likely question:** *"Why not a Cubit + Firestore?"* → "Bookmarks are
  device-local personalization. A `Set<String>` of IDs with local
  persistence is the right altitude; Firestore sync would add cost and
  latency for no user value at this scale."

## Stop 8 — Security: `firestore.rules`

- Users write only their own doc; startup docs mutable by owner or admin;
  opportunities creatable only by the owning startup; applications readable
  only by applicant + receiving startup; `admin_actions` admin-only.
- The counter exception: any signed-in client may update *only*
  `viewCount`/`applicationCount` (checked via `affectedKeys().hasOnly`).

## Stop 9 — Data model choices (REPORT.md §4)

- Denormalized: `opportunities` embeds `startupName`/`startupVerified`;
  `applications` embeds display fields from both sides.
- **Likely question:** *"What if a startup renames itself?"* → "Accepted
  trade-off: reads are 100× more frequent than renames. A Cloud Function
  trigger on the startup doc would fan out the update; the read path
  doesn't change."

## Stop 10 — Verification workflow (the ALU-specific feature)

- `startups.verificationStatus`: pending → approved/rejected by admin, with
  note, audit-logged to `admin_actions`.
- Feed query hard-filters `startupVerified == true` — unverified content is
  excluded *at the query level*, not hidden client-side.

---

## Rapid-fire answers

- **Why Cubit over BLoC?** Interactions are direct method calls; event
  objects add ceremony without audit value here. Cubit keeps sealed states
  with less boilerplate. (REPORT.md §3.2)
- **Why Cubit over Provider?** Explicit `Loading | Loaded | Error` state
  machines vs ad-hoc `notifyListeners` — exhaustive UI handling.
- **Why GoRouter?** Declarative redirects driven by auth state; deep links
  can't bypass guards.
- **Why denormalize?** Firestore charges and delays per document read;
  list screens must render from one query.
- **Where does search happen?** Server-side field filters + client-side
  text filter over the streamed page; Algolia is the documented scale path.
- **How is the ALU-only rule enforced?** Validator (UX) + it can be
  enforced in security rules via `request.auth.token.email` matching — the
  client check is convenience, the rules are the boundary.
