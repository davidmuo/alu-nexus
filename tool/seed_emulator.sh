#!/usr/bin/env bash
# Seed the Firebase Emulator Suite with a demo-ready world for ALU Nexus.
# Run while emulators are up:  bash tool/seed_emulator.sh
# Safe to re-run: existing accounts are signed in instead of recreated.
#
# Demo accounts:
#   student@alustudent.com  / Student123   (3 applications in different stages, notifications)
#   founder@alustudent.com  / Founder123   (owns NexEd Solutions; 3 incoming applications)
#   admin@alueducation.com  / Admin1234    (1 pending startup to verify on camera)

set -e
PROJECT="alunexus-b85a1"
AUTH="http://localhost:9099/identitytoolkit.googleapis.com/v1"
FS="http://localhost:8080/v1/projects/$PROJECT/databases/(default)/documents"
# The literal token "owner" bypasses security rules on the emulator only.
HDR=(-H "Authorization: Bearer owner" -H "Content-Type: application/json")

uid_of() { # email password -> uid (sign up, or sign in if it already exists)
  local resp
  resp=$(curl -s -X POST "$AUTH/accounts:signUp?key=fake" \
    -H "Content-Type: application/json" \
    -d "{\"email\":\"$1\",\"password\":\"$2\",\"returnSecureToken\":true}")
  if echo "$resp" | grep -q EMAIL_EXISTS; then
    resp=$(curl -s -X POST "$AUTH/accounts:signInWithPassword?key=fake" \
      -H "Content-Type: application/json" \
      -d "{\"email\":\"$1\",\"password\":\"$2\",\"returnSecureToken\":true}")
  fi
  echo "$resp" | grep -o '"localId": *"[^"]*"' | sed 's/.*: *"//;s/"//'
}

ts() { # days-offset -> ISO timestamp (GNU or BSD date)
  date -u -d "$1 days" +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || date -u -v"$1"d +%Y-%m-%dT%H:%M:%SZ
}

now=$(ts +0)

echo "Creating accounts..."
ADMIN_UID=$(uid_of "admin@alueducation.com" "Admin1234")
FOUNDER_UID=$(uid_of "founder@alustudent.com" "Founder123")
STUDENT_UID=$(uid_of "student@alustudent.com" "Student123")

echo "Creating user profiles..."
curl -s -X PATCH "$FS/users/$ADMIN_UID" "${HDR[@]}" -d "{\"fields\":{
  \"email\":{\"stringValue\":\"admin@alueducation.com\"},
  \"displayName\":{\"stringValue\":\"ALU Admin\"},
  \"role\":{\"stringValue\":\"admin\"},
  \"isOnboardingComplete\":{\"booleanValue\":true},
  \"createdAt\":{\"timestampValue\":\"$(ts -60)\"}}}" > /dev/null

curl -s -X PATCH "$FS/users/$FOUNDER_UID" "${HDR[@]}" -d "{\"fields\":{
  \"email\":{\"stringValue\":\"founder@alustudent.com\"},
  \"displayName\":{\"stringValue\":\"Kwame Osei\"},
  \"role\":{\"stringValue\":\"startup\"},
  \"isOnboardingComplete\":{\"booleanValue\":true},
  \"createdAt\":{\"timestampValue\":\"$(ts -90)\"}}}" > /dev/null

curl -s -X PATCH "$FS/users/$STUDENT_UID" "${HDR[@]}" -d "{\"fields\":{
  \"email\":{\"stringValue\":\"student@alustudent.com\"},
  \"displayName\":{\"stringValue\":\"Amara Diallo\"},
  \"role\":{\"stringValue\":\"student\"},
  \"skills\":{\"arrayValue\":{\"values\":[{\"stringValue\":\"Flutter\"},{\"stringValue\":\"Dart\"},{\"stringValue\":\"Firebase\"},{\"stringValue\":\"Figma\"}]}},
  \"isOnboardingComplete\":{\"booleanValue\":true},
  \"createdAt\":{\"timestampValue\":\"$(ts -45)\"}}}" > /dev/null

# ── Startups ────────────────────────────────────────────────
seed_startup() { # id ownerId name tagline description industry status stage opps followers foundedDaysAgo focus_json
  curl -s -X PATCH "$FS/startups/$1" "${HDR[@]}" -d "{\"fields\":{
    \"ownerId\":{\"stringValue\":\"$2\"},
    \"name\":{\"stringValue\":\"$3\"},
    \"tagline\":{\"stringValue\":\"$4\"},
    \"description\":{\"stringValue\":\"$5\"},
    \"industry\":{\"stringValue\":\"$6\"},
    \"verificationStatus\":{\"stringValue\":\"$7\"},
    \"stage\":{\"stringValue\":\"$8\"},
    \"isActive\":{\"booleanValue\":true},
    \"opportunitiesCount\":{\"integerValue\":\"$9\"},
    \"followersCount\":{\"integerValue\":\"${10}\"},
    \"focusAreas\":{\"arrayValue\":{\"values\":${12}}},
    \"foundedAt\":{\"timestampValue\":\"$(ts -${11})\"},
    \"createdAt\":{\"timestampValue\":\"$(ts -${11})\"},
    \"updatedAt\":{\"timestampValue\":\"$now\"}}}" > /dev/null
  echo "  startup: $3 ($7)"
}

echo "Creating startups..."
seed_startup "seed-startup-1" "$FOUNDER_UID" "NexEd Solutions" \
  "Reimagining access to quality education across Africa" \
  "Edtech startup building adaptive learning tools for secondary and tertiary students in Sub-Saharan Africa. Our app personalizes study plans for 5,000+ active learners." \
  "Education" "approved" "growth" 3 47 400 \
  '[{"stringValue":"Software Development"},{"stringValue":"UI/UX Design"},{"stringValue":"Marketing"}]'

seed_startup "seed-startup-2" "pseudo-owner-agrolink" "AgroLink Rwanda" \
  "Connecting smallholder farmers to premium markets" \
  "B2B agri-tech marketplace helping Rwandan farmers sell directly to supermarkets, hotels and exporters — increasing farmer income by 40% on average." \
  "Agriculture" "approved" "mvp" 2 23 200 \
  '[{"stringValue":"Business Development"},{"stringValue":"Operations"},{"stringValue":"Research & Analysis"}]'

seed_startup "seed-startup-3" "pseudo-owner-mindbridge" "MindBridge Health" \
  "Mental wellness for African university students" \
  "Anonymous peer-support and licensed therapist sessions via mobile app, partnered with 12 universities across East Africa." \
  "Health & Wellness" "approved" "growth" 1 89 700 \
  '[{"stringValue":"Community Management"},{"stringValue":"Software Development"},{"stringValue":"Marketing"}]'

seed_startup "seed-startup-4" "pseudo-owner-payease" "PayEase Africa" \
  "Cross-border payments for African SMEs" \
  "PayEase enables SMEs to send and receive payments across 15 African countries in local currencies, cutting transfer fees from 8% to under 1.5%. ALU registration: ALU-VEN-2026-014." \
  "Finance" "pending" "scaling" 0 12 120 \
  '[{"stringValue":"Software Development"},{"stringValue":"Finance"},{"stringValue":"Business Development"}]'

# ── Opportunities ───────────────────────────────────────────
seed_opp() { # id startupId startupName title type skills_json paid comp commitment duration location deadlineDays postedDaysAgo applicants views
  curl -s -X PATCH "$FS/opportunities/$1" "${HDR[@]}" -d "{\"fields\":{
    \"startupId\":{\"stringValue\":\"$2\"},
    \"startupName\":{\"stringValue\":\"$3\"},
    \"startupVerified\":{\"booleanValue\":true},
    \"title\":{\"stringValue\":\"$4\"},
    \"description\":{\"stringValue\":\"Join our team and get real, hands-on experience shipping work that matters. You will collaborate directly with the founding team, own real deliverables, and build a portfolio piece you can talk about in any interview.\"},
    \"type\":{\"stringValue\":\"$5\"},
    \"skills\":{\"arrayValue\":{\"values\":$6}},
    \"commitment\":{\"stringValue\":\"$9\"},
    \"duration\":{\"stringValue\":\"${10}\"},
    \"isPaid\":{\"booleanValue\":$7},
    \"compensation\":{\"stringValue\":\"$8\"},
    \"location\":{\"stringValue\":\"${11}\"},
    \"isActive\":{\"booleanValue\":true},
    \"applicationCount\":{\"integerValue\":\"${14}\"},
    \"viewCount\":{\"integerValue\":\"${15}\"},
    \"maxApplicants\":{\"integerValue\":\"15\"},
    \"deadline\":{\"timestampValue\":\"$(ts +${12})\"},
    \"responsibilities\":{\"arrayValue\":{\"values\":[{\"stringValue\":\"Own weekly deliverables end to end\"},{\"stringValue\":\"Collaborate in sprint planning and reviews\"},{\"stringValue\":\"Present your work to the founding team\"}]}},
    \"requirements\":{\"arrayValue\":{\"values\":[{\"stringValue\":\"Relevant coursework or personal projects\"},{\"stringValue\":\"10-15 hours per week availability\"},{\"stringValue\":\"Strong communication and follow-through\"}]}},
    \"perks\":{\"stringValue\":\"Mentorship from the founding team, certificate of completion, and a reference letter for standout performance.\"},
    \"createdAt\":{\"timestampValue\":\"$(ts -${13})\"},
    \"updatedAt\":{\"timestampValue\":\"$now\"}}}" > /dev/null
  echo "  opportunity: $4"
}

echo "Creating opportunities..."
seed_opp "seed-opp-1" "seed-startup-1" "NexEd Solutions" "Flutter Developer Intern" "Software Development" \
  '[{"stringValue":"Flutter"},{"stringValue":"Dart"},{"stringValue":"Firebase"}]' \
  true '\$150/mo' "Part-time" "3 months" "Remote" 14 2 12 89

seed_opp "seed-opp-2" "seed-startup-1" "NexEd Solutions" "UI/UX Design Intern" "UI/UX Design" \
  '[{"stringValue":"Figma"},{"stringValue":"User Research"},{"stringValue":"Prototyping"}]' \
  false '' "Flexible" "2 months" "Remote" 7 5 8 54

seed_opp "seed-opp-3" "seed-startup-1" "NexEd Solutions" "Marketing Intern" "Marketing" \
  '[{"stringValue":"Social Media"},{"stringValue":"Copywriting"}]' \
  true '\$80/mo' "Part-time" "2 months" "Hybrid" 20 3 19 102

seed_opp "seed-opp-4" "seed-startup-2" "AgroLink Rwanda" "Market Research Analyst" "Research & Analysis" \
  '[{"stringValue":"Market Research"},{"stringValue":"Excel"},{"stringValue":"Data Analysis"}]' \
  true '\$100/mo' "Part-time" "2 months" "Kigali" 10 4 5 31

seed_opp "seed-opp-5" "seed-startup-2" "AgroLink Rwanda" "Operations Assistant" "Operations" \
  '[{"stringValue":"Operations"},{"stringValue":"Communication"}]' \
  false '' "Flexible" "3 months" "Hybrid" 2 8 3 27

seed_opp "seed-opp-6" "seed-startup-3" "MindBridge Health" "Community Manager Intern" "Community Management" \
  '[{"stringValue":"Social Media"},{"stringValue":"Community Management"},{"stringValue":"Content Creation"}]' \
  true '\$120/mo' "Flexible" "3 months" "Remote" 18 1 21 143

# ── Applications ────────────────────────────────────────────
seed_app() { # id oppId oppTitle startupId startupName applicantId applicantName applicantEmail status daysAgo extra_json
  curl -s -X PATCH "$FS/applications/$1" "${HDR[@]}" -d "{\"fields\":{
    \"opportunityId\":{\"stringValue\":\"$2\"},
    \"opportunityTitle\":{\"stringValue\":\"$3\"},
    \"startupId\":{\"stringValue\":\"$4\"},
    \"startupName\":{\"stringValue\":\"$5\"},
    \"applicantId\":{\"stringValue\":\"$6\"},
    \"applicantName\":{\"stringValue\":\"$7\"},
    \"applicantEmail\":{\"stringValue\":\"$8\"},
    \"coverLetter\":{\"stringValue\":\"I have followed $5 for a while and the mission genuinely resonates with me. Between my coursework and personal projects I have built exactly the skills this role asks for, and I can commit the hours consistently. I would love the chance to prove it.\"},
    \"status\":{\"stringValue\":\"$9\"},
    \"skills\":{\"arrayValue\":{\"values\":[{\"stringValue\":\"Communication\"},{\"stringValue\":\"Teamwork\"}]}},
    \"isRead\":{\"booleanValue\":true},
    \"appliedAt\":{\"timestampValue\":\"$(ts -${10})\"},
    \"updatedAt\":{\"timestampValue\":\"$now\"}${11}}}" > /dev/null
  echo "  application: $7 -> $3 ($9)"
}

echo "Creating applications..."
# Student's own application history (3 stages of the pipeline)
seed_app "seed-app-1" "seed-opp-3" "Marketing Intern" "seed-startup-1" "NexEd Solutions" \
  "$STUDENT_UID" "Amara Diallo" "student@alustudent.com" "shortlisted" 4 \
  ",\"statusNote\":{\"stringValue\":\"Great profile! We would love to chat next week.\"}"

seed_app "seed-app-2" "seed-opp-4" "Market Research Analyst" "seed-startup-2" "AgroLink Rwanda" \
  "$STUDENT_UID" "Amara Diallo" "student@alustudent.com" "interviewing" 9 \
  ",\"statusNote\":{\"stringValue\":\"Interview scheduled - Google Meet link sent to your email.\"},\"interviewDate\":{\"timestampValue\":\"$(ts +3)\"}"

seed_app "seed-app-3" "seed-opp-6" "Community Manager Intern" "seed-startup-3" "MindBridge Health" \
  "$STUDENT_UID" "Amara Diallo" "student@alustudent.com" "pending" 1 ""

# Incoming applications for the founder's startup (from pseudo students)
seed_app "seed-app-4" "seed-opp-1" "Flutter Developer Intern" "seed-startup-1" "NexEd Solutions" \
  "pseudo-student-1" "Thabo Mokoena" "t.mokoena@alustudent.com" "pending" 1 ""

seed_app "seed-app-5" "seed-opp-1" "Flutter Developer Intern" "seed-startup-1" "NexEd Solutions" \
  "pseudo-student-2" "Fatima Hassan" "f.hassan@alustudent.com" "reviewing" 3 ""

seed_app "seed-app-6" "seed-opp-2" "UI/UX Design Intern" "seed-startup-1" "NexEd Solutions" \
  "pseudo-student-3" "Chidi Okonkwo" "c.okonkwo@alustudent.com" "shortlisted" 5 \
  ",\"statusNote\":{\"stringValue\":\"Impressive portfolio. Moving you forward.\"}"

# ── Notifications ───────────────────────────────────────────
seed_notif() { # id userId title body type refId isRead daysAgo
  curl -s -X PATCH "$FS/notifications/$1" "${HDR[@]}" -d "{\"fields\":{
    \"userId\":{\"stringValue\":\"$2\"},
    \"title\":{\"stringValue\":\"$3\"},
    \"body\":{\"stringValue\":\"$4\"},
    \"type\":{\"stringValue\":\"$5\"},
    \"referenceId\":{\"stringValue\":\"$6\"},
    \"isRead\":{\"booleanValue\":$7},
    \"createdAt\":{\"timestampValue\":\"$(ts -$8)\"}}}" > /dev/null
}

echo "Creating notifications..."
seed_notif "seed-notif-1" "$STUDENT_UID" "You have been shortlisted" \
  "NexEd Solutions shortlisted you for Marketing Intern. Check your application for details." \
  "applicationStatusUpdate" "seed-app-1" false 0
seed_notif "seed-notif-2" "$STUDENT_UID" "Interview scheduled" \
  "AgroLink Rwanda scheduled an interview with you for Market Research Analyst in 3 days." \
  "interviewScheduled" "seed-app-2" false 0
seed_notif "seed-notif-3" "$STUDENT_UID" "New opportunity matches your skills" \
  "NexEd Solutions posted Flutter Developer Intern matching your Flutter and Firebase skills." \
  "newOpportunity" "seed-opp-1" true 2
seed_notif "seed-notif-4" "$STUDENT_UID" "Application received" \
  "MindBridge Health received your application for Community Manager Intern." \
  "applicationReceived" "seed-app-3" true 1
seed_notif "seed-notif-5" "$FOUNDER_UID" "New applicant" \
  "Thabo Mokoena applied for Flutter Developer Intern." \
  "applicationReceived" "seed-app-4" false 1
seed_notif "seed-notif-6" "$FOUNDER_UID" "New applicant" \
  "Fatima Hassan applied for Flutter Developer Intern." \
  "applicationReceived" "seed-app-5" true 3

echo
echo "Done. Demo accounts:"
echo "  STUDENT  student@alustudent.com / Student123   (3 applications, 2 unread notifications)"
echo "  STARTUP  founder@alustudent.com / Founder123   (3 incoming applications)"
echo "  ADMIN    admin@alueducation.com / Admin1234    (PayEase Africa pending verification)"
echo "Emulator UI: http://localhost:4000"
