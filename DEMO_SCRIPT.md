# ALU Nexus — Video Shooting Script (9:15, no live audience)

Read the SAY lines aloud while doing the ACTION steps. Rehearse once with the
mic off; the second take is usually the keeper. Target 7:00–9:30 total.

---

## Pre-flight (do all of this BEFORE hitting record)

**Screen layout (one monitor, one recording):**
1. Plug the phone in (keep it plugged; the mirror runs over USB).
2. Launch the phone mirror: double-click
   `C:\Users\Dranoh\scrcpy\scrcpy-win64-v4.0\scrcpy.exe`
   Place the phone window on the LEFT third of the screen.
   (You can type into the phone with your PC keyboard — use this for forms.)
3. Chrome on the RIGHT two-thirds with exactly two tabs:
   - Tab 1: console.firebase.google.com/project/alunexus-5416d/authentication/users
   - Tab 2: console.firebase.google.com/project/alunexus-5416d/firestore/databases/-default-/data
4. VS Code open BEHIND Chrome with these files as tabs, in this order:
   `lib/main.dart` · `lib/features/opportunities/presentation/cubit/opportunity_cubit.dart` ·
   `lib/features/auth/data/repositories/auth_repository.dart` · `firestore.rules`
   and a terminal panel ready in the project folder.
5. Phone: open ALU-Nexus. It must start at the **login screen** (signed out).
   Phone on Do Not Disturb so nothing pops over the recording.

**Recorder:** any screen recorder that captures the full screen with your mic.
Zero-install option: PowerPoint → Insert → Screen Recording → select the whole
screen → make sure Audio is on. (OBS Studio is the better tool if you have it.)

**Retake rule:** every take registers a NEW account. Use
`take1@alustudent.com`, `take2@alustudent.com`, ... so you never hit
"email already in use".

**Demo accounts (already seeded in production):**
| Role | Email | Password |
|---|---|---|
| Student | student@alustudent.com | Student123 |
| Startup | founder@alustudent.com | Founder123 |
| Admin | admin@alueducation.com | Admin1234 |

---

## SCENE 1 — Intro (0:00–0:40)
**Screen:** phone mirror on the login screen, console visible on the right.

**SAY:**
> "Hi, I'm David Muotoh-Francis, and this is ALU Nexus: a Flutter and
> Firebase marketplace that connects ALU students looking for internship
> experience with student-led startups in the ALU ecosystem. Right now that
> matching happens in WhatsApp groups: postings get lost, applications go
> unanswered, and students can't verify that a startup is real. ALU Nexus
> fixes that with three ideas: startups must be verified by an admin before
> they can post, students are matched to roles by the skills they select at
> onboarding, and every application moves through a transparent pipeline.
> The stack is Flutter with Cubit state management on a feature-first Clean
> Architecture, and Firebase Auth plus Cloud Firestore. Everything you'll
> see is running against the live Firebase project on the right."

## SCENE 2 — Authentication + Console (0:40–2:00) — *rubric: Firebase Auth*
**ACTION / SAY interleaved:**

1. Phone: tap **Join ALU Nexus**. Leave role as Student. Type name
   `Video Demo`, email `demo@gmail.com`, any password.
   Tap **Create Account** → the email field shows the ALU-domain error.
   **SAY:** "Authentication is restricted to the ALU community. A Gmail
   address fails validation before a request is ever sent."
2. Fix the email to `take1@alustudent.com` (or take2, take3...), password
   `Take1234`, confirm it, tap **Create Account**.
   **SAY:** "With a valid ALU address, Firebase Auth creates the account and
   the app moves me into onboarding."
3. Click Chrome **Tab 1 (Authentication)** → press the refresh icon in the
   users table.
   **SAY (pointing at the new row):** "And here's that account in the real
   Firebase Console: the UID matches, created seconds ago. My AuthCubit
   subscribes to Firebase's authStateChanges stream, and GoRouter's redirect
   consumes that state, so an unauthenticated user can never deep-link past
   the login screen. Session state persists across restarts."

## SCENE 3 — Onboarding + skill matching (2:00–3:00) — *rubric: UI/UX, Features*
1. Phone: onboarding page 1 → pick any Program, Year 2 → **Continue**.
2. Page 2 (Your Skills): tap **Flutter, Dart, Firebase** → **Continue**.
   **SAY:** "Onboarding data isn't decorative. These skill selections are
   stored on my user document and will rank the feed I'm about to see."
3. Page 3 → finish onboarding → the feed loads.
   **SAY (pointing at the top card):** "And there it is: the Flutter
   Developer role is featured with 'Matches 3 skills', because it overlaps
   most with what I just selected. Design-wise, this is the third iteration
   of the interface: Satoshi type, a five-color system where the cards
   rotate purple, red, and yellow, and each card's color follows you into
   its detail screen. Every list in the app has a loading shimmer, an error
   state with retry, and an empty state, so there's never a blank screen."

## SCENE 4 — Discovery, Apply, duplicate guard (3:00–4:15) — *rubric: CRUD create, Features*
1. Phone: tap the black **filter button** → pick Paid → **Apply**.
   **SAY:** "Filters run server-side in the Firestore query, not in the UI."
   Tap filter again → **Reset**.
2. Tap the featured **Flutter Developer Intern** card.
   **SAY:** "The detail view: role info, skills, requirements, and live
   stats. Notice the deadline chip and the bookmark, which persists locally."
3. Tap the **bookmark** icon. Tap **Apply Now**. Type this cover letter
   (type it via your PC keyboard into the mirror):
   `I build Flutter apps with Firebase backends and I am specifically excited about education technology in Africa. I can commit fifteen hours weekly.`
   Tap **Submit Application**.
4. Chrome **Tab 2 (Firestore)** → click the **applications** collection →
   click the newest document.
   **SAY:** "That's a CREATE: the application document is in Cloud
   Firestore in real time, with the applicant and opportunity fields
   denormalized so list screens render from a single query."
5. Phone: go back to the same opportunity → tap **Apply Now** again.
   **SAY (when it's blocked):** "Duplicate applications are rejected by a
   pre-submission query. Invalid input, expired deadlines, and network
   failures are all handled the same deliberate way."

## SCENE 5 — Startup side: UPDATE + realtime + CREATE (4:15–5:45) — *rubric: CRUD, State mgmt*
1. Phone: Profile tab → **Sign out** → login `founder@alustudent.com` /
   `Founder123`.
   **SAY:** "Same app, different role. GoRouter routes this account to the
   startup shell because the role lives on the user document."
2. Tap **Applicants** tab.
   **SAY:** "Here's my applicant pipeline, including the application I just
   submitted as a student a minute ago: real-time, no refresh."
3. On the new applicant (Video Demo / take account) tap **Update Status** →
   choose **Shortlisted**.
4. Chrome Tab 2 → applications → the same doc → point at `status`.
   **SAY:** "There's the UPDATE in the console: status is now shortlisted.
   The mechanism is one loop: the Cubit calls the repository, the repository
   writes to Firestore, Firestore commits and pushes a snapshot event back,
   the Cubit emits new state, and every BlocBuilder listening rebuilds. The
   student's tracker, my applicant list, and this console all converge on
   the same commit. Nothing polls."
5. Phone: Dashboard tab → **Post Opportunity**. Fill fast: title
   `Junior QA Tester`, short description (2 sentences), tap 2 skills,
   defaults for the rest → **Publish**.
6. Chrome Tab 2 → **opportunities** collection → newest doc.
   **SAY:** "A second CREATE: the posting is live in Firestore and instantly
   queryable by every student, because it carries the denormalized
   startupVerified flag the feed filters on."

## SCENE 6 — Admin verification (5:45–6:30) — *rubric: Product thinking, Features*
1. Phone: Profile → Sign out → login `admin@alueducation.com` / `Admin1234`.
2. The admin dashboard opens on **Pending** with PayEase Africa → tap
   **Approve** (add a short note if prompted).
3. Chrome Tab 2 → **startups** → seed-startup-4 → point at
   `verificationStatus: approved`; then open **admin_actions** → newest doc.
   **SAY:** "This is the trust workflow that makes the platform ALU-specific.
   Startups onboard into a pending state and cannot publish anything. An
   admin approves or rejects, the decision is written to the startup document
   and to an immutable audit log, and only then does the feed query, which
   filters on startupVerified server-side, ever expose their content to
   students. Fake postings can't reach students even by accident."

## SCENE 7 — Architecture in code (6:30–8:15) — *rubric: State mgmt 8, Code quality*
Switch to **VS Code** (Alt-Tab). Go tab by tab:

1. **lib/main.dart — point at lines 26 and 30** (`kDemoMode`, `kUseEmulators`).
   **SAY:** "The app has three run modes behind two flags: an in-memory demo
   mode, the Firebase Local Emulator Suite, and production, which is what
   you've been watching. All three run the identical UI, routing, and state
   layer; only the data layer swaps. That's my evidence the architecture's
   layers are genuinely decoupled, not just labeled."
2. **opportunity_cubit.dart — point at lines 19 to 33** (`loadOpportunities`).
   **SAY:** "This is the state management pattern everywhere: the Cubit owns
   a Firestore snapshots subscription; every event emits an immutable state:
   Loading, Loaded, or Error, and the UI just rebuilds from state. Changing
   a filter cancels this subscription and opens a new server-side-filtered
   query. Sealed states are why every screen has explicit loading and error
   handling: the compiler makes me handle them."
3. **auth_repository.dart — point at lines 9 and 10** (lazy getters).
   **SAY:** "One detail I'm proud of: repositories reach Firebase through
   lazy getters instead of constructor captures. Two lines, but it's what
   lets demo repositories subclass production ones and it's why the app can
   boot with no backend at all."
4. **firestore.rules — point at line 17, then line 37.**
   **SAY:** "Security is code, not console clicks. Users write only their own
   document; startups are mutable only by their owner or an admin;
   applications are visible only to the applicant and the receiving startup.
   Line 37 is a scoped exception: any signed-in client may update only the
   view and application counters, enforced field-by-field. I verified these
   rules behaviorally: a write to another user's document comes back
   PERMISSION_DENIED at exactly line 17."
5. **Terminal:** run `flutter analyze`, then `flutter test`.
   **SAY (over the output):** "Flutter analyze: zero issues. Sixteen unit
   tests on the validation layer, all passing, because a bug there would
   silently admit non-ALU users."

## SCENE 8 — Wrap (8:15–9:15)
**Screen:** back to the phone mirror on the feed.

**SAY:**
> "On scalability: every query is indexed and filtered server-side, with the
> thirteen composite indexes version-controlled and deployed with the app.
> The skill-matching that runs client-side today has a documented path to a
> Cloud Function, and notification fan-out moves to a Firestore trigger
> without any client changes. Honest limitations: push notifications and
> file uploads are scaffolded but not shipped, and in-app messaging is the
> next feature I'd build. The hardest engineering in this project wasn't
> visible today: my full technical report documents challenges like a
> five-layer networking failure on physical devices and an organization
> billing policy, and how each was diagnosed with real evidence. The code,
> report, and this demo are in the GitHub repository. Thanks for watching."

**Stop recording.**

---

## If something goes wrong mid-take
- Console not updating: click the small **refresh** icon in the console
  toolbar (Auth) or re-click the collection name (Firestore).
- Typed into the wrong field: long-press in the field → select all → delete.
- App misbehaves: force-close it from recents, reopen; state resumes.
- Flubbed a sentence: pause two seconds and repeat the sentence; cut it in
  any editor later (or just leave it, it's human).

## Reset between takes
1. Phone: Profile → Sign out (returns to the login screen).
2. Use the next `takeN@alustudent.com` email in Scene 2.
3. Seeded data is untouched by retakes; extra take-accounts and their
   applications are harmless clutter (or delete them in the console:
   Authentication → three-dot menu on the row → Delete).
