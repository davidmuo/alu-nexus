#!/usr/bin/env bash
# Seed PRODUCTION Firestore with the demo world, writing exclusively through
# the deployed security rules using real authenticated accounts.
# Usage: bash tool/seed_production.sh <WEB_API_KEY>
# Idempotent: existing accounts are signed in instead of recreated.

set -e
KEY="${1:?Usage: bash tool/seed_production.sh <WEB_API_KEY>}"
PROJECT="alunexus-5416d"
AUTH="https://identitytoolkit.googleapis.com/v1"
FS="https://firestore.googleapis.com/v1/projects/$PROJECT/databases/(default)/documents"

# email password -> "uid idToken"
account() {
  local resp
  resp=$(curl -s -X POST "$AUTH/accounts:signUp?key=$KEY" \
    -H "Content-Type: application/json" \
    -d "{\"email\":\"$1\",\"password\":\"$2\",\"returnSecureToken\":true}")
  if echo "$resp" | grep -q EMAIL_EXISTS; then
    resp=$(curl -s -X POST "$AUTH/accounts:signInWithPassword?key=$KEY" \
      -H "Content-Type: application/json" \
      -d "{\"email\":\"$1\",\"password\":\"$2\",\"returnSecureToken\":true}")
  fi
  local uid tok
  uid=$(echo "$resp" | grep -o '"localId": *"[^"]*"' | sed 's/.*: *"//;s/"//')
  tok=$(echo "$resp" | grep -o '"idToken": *"[^"]*"' | sed 's/.*: *"//;s/"//')
  echo "$uid $tok"
}

write() { # idToken path fieldsJson
  local resp
  resp=$(curl -s -X PATCH "$FS/$2" \
    -H "Authorization: Bearer $1" -H "Content-Type: application/json" \
    -d "{\"fields\":$3}")
  if echo "$resp" | grep -q '"error"'; then
    echo "  !! FAILED $2: $(echo "$resp" | head -c 160)"
    return 1
  fi
}

ts() { date -u -d "$1 days" +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || date -u -v"$1"d +%Y-%m-%dT%H:%M:%SZ; }
now=$(ts +0)

echo "Creating accounts..."
read ADMIN_UID ADMIN_TOK <<< "$(account admin@alueducation.com Admin1234)"
read FOUNDER_UID FOUNDER_TOK <<< "$(account founder@alustudent.com Founder123)"
read STUDENT_UID STUDENT_TOK <<< "$(account student@alustudent.com Student123)"
read AGRO_UID AGRO_TOK <<< "$(account agrolink.founder@alustudent.com Agro1234)"
read MIND_UID MIND_TOK <<< "$(account mindbridge.founder@alustudent.com Mind1234)"
read PAY_UID PAY_TOK <<< "$(account payease.founder@alustudent.com Pay12345)"
read S1_UID S1_TOK <<< "$(account t.mokoena@alustudent.com Thabo1234)"
read S2_UID S2_TOK <<< "$(account f.hassan@alustudent.com Fatima123)"
read S3_UID S3_TOK <<< "$(account c.okonkwo@alustudent.com Chidi1234)"
echo "  9 accounts ready (admin: $ADMIN_UID)"

profile() { # token uid email name role extraJson
  write "$1" "users/$2" "{
    \"email\":{\"stringValue\":\"$3\"},
    \"displayName\":{\"stringValue\":\"$4\"},
    \"role\":{\"stringValue\":\"$5\"},
    \"isOnboardingComplete\":{\"booleanValue\":true},
    \"createdAt\":{\"timestampValue\":\"$(ts -45)\"}$6}"
}

echo "Creating user profiles..."
profile "$ADMIN_TOK" "$ADMIN_UID" admin@alueducation.com "ALU Admin" admin ""
profile "$FOUNDER_TOK" "$FOUNDER_UID" founder@alustudent.com "Kwame Osei" startup ""
profile "$AGRO_TOK" "$AGRO_UID" agrolink.founder@alustudent.com "Aline Uwase" startup ""
profile "$MIND_TOK" "$MIND_UID" mindbridge.founder@alustudent.com "Tunde Bakare" startup ""
profile "$PAY_TOK" "$PAY_UID" payease.founder@alustudent.com "Zanele Dube" startup ""
profile "$S1_TOK" "$S1_UID" t.mokoena@alustudent.com "Thabo Mokoena" student ""
profile "$S2_TOK" "$S2_UID" f.hassan@alustudent.com "Fatima Hassan" student ""
profile "$S3_TOK" "$S3_UID" c.okonkwo@alustudent.com "Chidi Okonkwo" student ""
profile "$STUDENT_TOK" "$STUDENT_UID" student@alustudent.com "Amara Diallo" student ",
    \"skills\":{\"arrayValue\":{\"values\":[{\"stringValue\":\"Flutter\"},{\"stringValue\":\"Dart\"},{\"stringValue\":\"Firebase\"},{\"stringValue\":\"Figma\"}]}}"

startup() { # token id ownerId name tagline desc industry status stage opps followers ageDays focusJson
  write "$1" "startups/$2" "{
    \"ownerId\":{\"stringValue\":\"$3\"},
    \"name\":{\"stringValue\":\"$4\"},
    \"tagline\":{\"stringValue\":\"$5\"},
    \"description\":{\"stringValue\":\"$6\"},
    \"industry\":{\"stringValue\":\"$7\"},
    \"verificationStatus\":{\"stringValue\":\"$8\"},
    \"stage\":{\"stringValue\":\"$9\"},
    \"isActive\":{\"booleanValue\":true},
    \"opportunitiesCount\":{\"integerValue\":\"${10}\"},
    \"followersCount\":{\"integerValue\":\"${11}\"},
    \"focusAreas\":{\"arrayValue\":{\"values\":${13}}},
    \"foundedAt\":{\"timestampValue\":\"$(ts -${12})\"},
    \"createdAt\":{\"timestampValue\":\"$(ts -${12})\"},
    \"updatedAt\":{\"timestampValue\":\"$now\"}}" && echo "  startup: $4 ($8)"
}

echo "Creating startups..."
startup "$FOUNDER_TOK" seed-startup-1 "$FOUNDER_UID" "NexEd Solutions" \
  "Reimagining access to quality education across Africa" \
  "Edtech startup building adaptive learning tools for secondary and tertiary students in Sub-Saharan Africa. Our app personalizes study plans for 5,000+ active learners." \
  "Education" approved growth 4 47 400 \
  '[{"stringValue":"Software Development"},{"stringValue":"UI/UX Design"},{"stringValue":"Marketing"}]'
startup "$AGRO_TOK" seed-startup-2 "$AGRO_UID" "AgroLink Rwanda" \
  "Connecting smallholder farmers to premium markets" \
  "B2B agri-tech marketplace helping Rwandan farmers sell directly to supermarkets, hotels and exporters, increasing farmer income by 40% on average." \
  "Agriculture" approved mvp 3 23 200 \
  '[{"stringValue":"Business Development"},{"stringValue":"Operations"},{"stringValue":"Research & Analysis"}]'
startup "$MIND_TOK" seed-startup-3 "$MIND_UID" "MindBridge Health" \
  "Mental wellness for African university students" \
  "Anonymous peer-support and licensed therapist sessions via mobile app, partnered with 12 universities across East Africa." \
  "Health & Wellness" approved growth 3 89 700 \
  '[{"stringValue":"Community Management"},{"stringValue":"Software Development"},{"stringValue":"Marketing"}]'
startup "$PAY_TOK" seed-startup-4 "$PAY_UID" "PayEase Africa" \
  "Cross-border payments for African SMEs" \
  "PayEase enables SMEs to send and receive payments across 15 African countries in local currencies, cutting transfer fees from 8% to under 1.5%. ALU registration: ALU-VEN-2026-014." \
  "Finance" pending scaling 0 12 120 \
  '[{"stringValue":"Software Development"},{"stringValue":"Finance"},{"stringValue":"Business Development"}]'

opp() { # token id startupId startupName title type skillsJson paid comp commitment duration location deadlineDays postedDays applicants views
  write "$1" "opportunities/$2" "{
    \"startupId\":{\"stringValue\":\"$3\"},
    \"startupName\":{\"stringValue\":\"$4\"},
    \"startupVerified\":{\"booleanValue\":true},
    \"title\":{\"stringValue\":\"$5\"},
    \"description\":{\"stringValue\":\"Join our team and get real, hands-on experience shipping work that matters. You will collaborate directly with the founding team, own real deliverables, and build a portfolio piece you can talk about in any interview.\"},
    \"type\":{\"stringValue\":\"$6\"},
    \"skills\":{\"arrayValue\":{\"values\":$7}},
    \"commitment\":{\"stringValue\":\"${10}\"},
    \"duration\":{\"stringValue\":\"${11}\"},
    \"isPaid\":{\"booleanValue\":$8},
    \"compensation\":{\"stringValue\":\"$9\"},
    \"location\":{\"stringValue\":\"${12}\"},
    \"isActive\":{\"booleanValue\":true},
    \"applicationCount\":{\"integerValue\":\"${15}\"},
    \"viewCount\":{\"integerValue\":\"${16}\"},
    \"maxApplicants\":{\"integerValue\":\"15\"},
    \"deadline\":{\"timestampValue\":\"$(ts +${13})\"},
    \"responsibilities\":{\"arrayValue\":{\"values\":[{\"stringValue\":\"Own weekly deliverables end to end\"},{\"stringValue\":\"Collaborate in sprint planning and reviews\"},{\"stringValue\":\"Present your work to the founding team\"}]}},
    \"requirements\":{\"arrayValue\":{\"values\":[{\"stringValue\":\"Relevant coursework or personal projects\"},{\"stringValue\":\"10-15 hours per week availability\"},{\"stringValue\":\"Strong communication and follow-through\"}]}},
    \"perks\":{\"stringValue\":\"Mentorship from the founding team, certificate of completion, and a reference letter for standout performance.\"},
    \"createdAt\":{\"timestampValue\":\"$(ts -${14})\"},
    \"updatedAt\":{\"timestampValue\":\"$now\"}}" && echo "  opportunity: $5"
}

echo "Creating opportunities..."
opp "$FOUNDER_TOK" seed-opp-1 seed-startup-1 "NexEd Solutions" "Flutter Developer Intern" "Software Development" \
  '[{"stringValue":"Flutter"},{"stringValue":"Dart"},{"stringValue":"Firebase"}]' true '$150/mo' "Part-time" "3 months" "Remote" 14 2 12 89
opp "$FOUNDER_TOK" seed-opp-2 seed-startup-1 "NexEd Solutions" "UI/UX Design Intern" "UI/UX Design" \
  '[{"stringValue":"Figma"},{"stringValue":"User Research"},{"stringValue":"Prototyping"}]' false '' "Flexible" "2 months" "Remote" 7 5 8 54
opp "$FOUNDER_TOK" seed-opp-3 seed-startup-1 "NexEd Solutions" "Marketing Intern" "Marketing" \
  '[{"stringValue":"Social Media"},{"stringValue":"Copywriting"}]' true '$80/mo' "Part-time" "2 months" "Hybrid" 20 3 19 102
opp "$AGRO_TOK" seed-opp-4 seed-startup-2 "AgroLink Rwanda" "Market Research Analyst" "Research & Analysis" \
  '[{"stringValue":"Market Research"},{"stringValue":"Excel"},{"stringValue":"Data Analysis"}]' true '$100/mo' "Part-time" "2 months" "Kigali" 10 4 5 31
opp "$AGRO_TOK" seed-opp-5 seed-startup-2 "AgroLink Rwanda" "Operations Assistant" "Operations" \
  '[{"stringValue":"Operations"},{"stringValue":"Communication"}]' false '' "Flexible" "3 months" "Hybrid" 2 8 3 27
opp "$MIND_TOK" seed-opp-6 seed-startup-3 "MindBridge Health" "Community Manager Intern" "Community Management" \
  '[{"stringValue":"Social Media"},{"stringValue":"Community Management"},{"stringValue":"Content Creation"}]' true '$120/mo' "Flexible" "3 months" "Remote" 18 1 21 143
opp "$FOUNDER_TOK" seed-opp-7 seed-startup-1 "NexEd Solutions" "Data Analyst Intern" "Data Science" \
  '[{"stringValue":"Python"},{"stringValue":"SQL"},{"stringValue":"Data Analysis"}]' true '$130/mo' "Part-time" "3 months" "Remote" 16 2 7 48
opp "$AGRO_TOK" seed-opp-8 seed-startup-2 "AgroLink Rwanda" "Business Development Associate" "Business Development" \
  '[{"stringValue":"Sales"},{"stringValue":"Negotiation"},{"stringValue":"CRM"}]' true '$110/mo' "Part-time" "4 months" "Kigali" 12 6 9 66
opp "$MIND_TOK" seed-opp-9 seed-startup-3 "MindBridge Health" "Content Creator" "Content Creation" \
  '[{"stringValue":"Copywriting"},{"stringValue":"Video Editing"},{"stringValue":"Storytelling"}]' false '' "Flexible" "2 months" "Remote" 9 4 14 92
opp "$MIND_TOK" seed-opp-10 seed-startup-3 "MindBridge Health" "Product Management Intern" "Product Management" \
  '[{"stringValue":"Product Strategy"},{"stringValue":"User Research"},{"stringValue":"Agile"}]' true '$140/mo' "Part-time" "4 months" "Hybrid" 21 3 11 77

app() { # token id oppId oppTitle startupId startupName applicantId name email status daysAgo extraJson
  write "$1" "applications/$2" "{
    \"opportunityId\":{\"stringValue\":\"$3\"},
    \"opportunityTitle\":{\"stringValue\":\"$4\"},
    \"startupId\":{\"stringValue\":\"$5\"},
    \"startupName\":{\"stringValue\":\"$6\"},
    \"applicantId\":{\"stringValue\":\"$7\"},
    \"applicantName\":{\"stringValue\":\"$8\"},
    \"applicantEmail\":{\"stringValue\":\"$9\"},
    \"coverLetter\":{\"stringValue\":\"I have followed $6 for a while and the mission genuinely resonates with me. Between my coursework and personal projects I have built exactly the skills this role asks for, and I can commit the hours consistently. I would love the chance to prove it.\"},
    \"status\":{\"stringValue\":\"${10}\"},
    \"skills\":{\"arrayValue\":{\"values\":[{\"stringValue\":\"Communication\"},{\"stringValue\":\"Teamwork\"}]}},
    \"isRead\":{\"booleanValue\":true},
    \"appliedAt\":{\"timestampValue\":\"$(ts -${11})\"},
    \"updatedAt\":{\"timestampValue\":\"$now\"}${12}}" && echo "  application: $8 -> $4 (${10})"
}

echo "Creating applications..."
app "$STUDENT_TOK" seed-app-1 seed-opp-3 "Marketing Intern" seed-startup-1 "NexEd Solutions" \
  "$STUDENT_UID" "Amara Diallo" student@alustudent.com shortlisted 4 \
  ",\"statusNote\":{\"stringValue\":\"Great profile! We would love to chat next week.\"}"
app "$STUDENT_TOK" seed-app-2 seed-opp-4 "Market Research Analyst" seed-startup-2 "AgroLink Rwanda" \
  "$STUDENT_UID" "Amara Diallo" student@alustudent.com interviewing 9 \
  ",\"statusNote\":{\"stringValue\":\"Interview scheduled - Google Meet link sent to your email.\"},\"interviewDate\":{\"timestampValue\":\"$(ts +3)\"}"
app "$STUDENT_TOK" seed-app-3 seed-opp-6 "Community Manager Intern" seed-startup-3 "MindBridge Health" \
  "$STUDENT_UID" "Amara Diallo" student@alustudent.com pending 1 ""
app "$S1_TOK" seed-app-4 seed-opp-1 "Flutter Developer Intern" seed-startup-1 "NexEd Solutions" \
  "$S1_UID" "Thabo Mokoena" t.mokoena@alustudent.com pending 1 ""
app "$S2_TOK" seed-app-5 seed-opp-1 "Flutter Developer Intern" seed-startup-1 "NexEd Solutions" \
  "$S2_UID" "Fatima Hassan" f.hassan@alustudent.com reviewing 3 ""
app "$S3_TOK" seed-app-6 seed-opp-2 "UI/UX Design Intern" seed-startup-1 "NexEd Solutions" \
  "$S3_UID" "Chidi Okonkwo" c.okonkwo@alustudent.com shortlisted 5 \
  ",\"statusNote\":{\"stringValue\":\"Impressive portfolio. Moving you forward.\"}"

notif() { # token id userId title body type refId isRead daysAgo
  write "$1" "notifications/$2" "{
    \"userId\":{\"stringValue\":\"$3\"},
    \"title\":{\"stringValue\":\"$4\"},
    \"body\":{\"stringValue\":\"$5\"},
    \"type\":{\"stringValue\":\"$6\"},
    \"referenceId\":{\"stringValue\":\"$7\"},
    \"isRead\":{\"booleanValue\":$8},
    \"createdAt\":{\"timestampValue\":\"$(ts -$9)\"}}"
}

echo "Creating notifications..."
notif "$STUDENT_TOK" seed-notif-1 "$STUDENT_UID" "You have been shortlisted" \
  "NexEd Solutions shortlisted you for Marketing Intern. Check your application for details." \
  applicationStatusUpdate seed-app-1 false 0
notif "$STUDENT_TOK" seed-notif-2 "$STUDENT_UID" "Interview scheduled" \
  "AgroLink Rwanda scheduled an interview with you for Market Research Analyst in 3 days." \
  interviewScheduled seed-app-2 false 0
notif "$STUDENT_TOK" seed-notif-3 "$STUDENT_UID" "New opportunity matches your skills" \
  "NexEd Solutions posted Flutter Developer Intern matching your Flutter and Firebase skills." \
  newOpportunity seed-opp-1 true 2
notif "$STUDENT_TOK" seed-notif-4 "$STUDENT_UID" "Application received" \
  "MindBridge Health received your application for Community Manager Intern." \
  applicationReceived seed-app-3 true 1
notif "$FOUNDER_TOK" seed-notif-5 "$FOUNDER_UID" "New applicant" \
  "Thabo Mokoena applied for Flutter Developer Intern." applicationReceived seed-app-4 false 1
notif "$FOUNDER_TOK" seed-notif-6 "$FOUNDER_UID" "New applicant" \
  "Fatima Hassan applied for Flutter Developer Intern." applicationReceived seed-app-5 true 3

echo
echo "Production seed complete. Demo accounts:"
echo "  STUDENT  student@alustudent.com / Student123"
echo "  STARTUP  founder@alustudent.com / Founder123"
echo "  ADMIN    admin@alueducation.com / Admin1234"
echo "Console: https://console.firebase.google.com/project/$PROJECT"
