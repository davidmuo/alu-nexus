#!/usr/bin/env bash
# Seed the Firebase Emulator Suite with demo-ready data for ALU Nexus.
# Run while emulators are up:  bash tool/seed_emulator.sh
# Creates: admin + startup-founder accounts, one approved startup,
# and three open opportunities so the student feed is populated.

set -e
PROJECT="alunexus-b85a1"
AUTH="http://localhost:9099/identitytoolkit.googleapis.com/v1"
FS="http://localhost:8080/v1/projects/$PROJECT/databases/(default)/documents"
# The literal token "owner" bypasses security rules on the emulator only.
HDR=(-H "Authorization: Bearer owner" -H "Content-Type: application/json")

signup() { # email password -> uid
  curl -s -X POST "$AUTH/accounts:signUp?key=fake" \
    -H "Content-Type: application/json" \
    -d "{\"email\":\"$1\",\"password\":\"$2\",\"returnSecureToken\":true}" \
    | grep -o '"localId": *"[^"]*"' | sed 's/.*: *"//;s/"//'
}

now=$(date -u +%Y-%m-%dT%H:%M:%SZ)
deadline=$(date -u -d "+14 days" +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || date -u -v+14d +%Y-%m-%dT%H:%M:%SZ)

echo "Creating accounts..."
ADMIN_UID=$(signup "admin@alueducation.com" "Admin1234")
FOUNDER_UID=$(signup "founder@alustudent.com" "Founder123")
echo "  admin:   admin@alueducation.com / Admin1234    ($ADMIN_UID)"
echo "  founder: founder@alustudent.com / Founder123   ($FOUNDER_UID)"

echo "Creating user profiles..."
curl -s -X PATCH "$FS/users/$ADMIN_UID" "${HDR[@]}" -d "{\"fields\":{
  \"email\":{\"stringValue\":\"admin@alueducation.com\"},
  \"displayName\":{\"stringValue\":\"ALU Admin\"},
  \"role\":{\"stringValue\":\"admin\"},
  \"isOnboardingComplete\":{\"booleanValue\":true},
  \"createdAt\":{\"timestampValue\":\"$now\"}}}" > /dev/null

curl -s -X PATCH "$FS/users/$FOUNDER_UID" "${HDR[@]}" -d "{\"fields\":{
  \"email\":{\"stringValue\":\"founder@alustudent.com\"},
  \"displayName\":{\"stringValue\":\"Kwame Osei\"},
  \"role\":{\"stringValue\":\"startup\"},
  \"isOnboardingComplete\":{\"booleanValue\":true},
  \"createdAt\":{\"timestampValue\":\"$now\"}}}" > /dev/null

echo "Creating approved startup..."
curl -s -X PATCH "$FS/startups/seed-startup-1" "${HDR[@]}" -d "{\"fields\":{
  \"ownerId\":{\"stringValue\":\"$FOUNDER_UID\"},
  \"name\":{\"stringValue\":\"NexEd Solutions\"},
  \"tagline\":{\"stringValue\":\"Reimagining access to quality education across Africa\"},
  \"description\":{\"stringValue\":\"Edtech startup building adaptive learning tools for students in Sub-Saharan Africa.\"},
  \"industry\":{\"stringValue\":\"Education\"},
  \"verificationStatus\":{\"stringValue\":\"approved\"},
  \"stage\":{\"stringValue\":\"growth\"},
  \"isActive\":{\"booleanValue\":true},
  \"opportunitiesCount\":{\"integerValue\":\"3\"},
  \"followersCount\":{\"integerValue\":\"47\"},
  \"focusAreas\":{\"arrayValue\":{\"values\":[{\"stringValue\":\"Software Development\"},{\"stringValue\":\"UI/UX Design\"},{\"stringValue\":\"Marketing\"}]}},
  \"createdAt\":{\"timestampValue\":\"$now\"},
  \"updatedAt\":{\"timestampValue\":\"$now\"}}}" > /dev/null

seed_opp() { # id title type skills_json paid comp commitment duration
  curl -s -X PATCH "$FS/opportunities/$1" "${HDR[@]}" -d "{\"fields\":{
    \"startupId\":{\"stringValue\":\"seed-startup-1\"},
    \"startupName\":{\"stringValue\":\"NexEd Solutions\"},
    \"startupVerified\":{\"booleanValue\":true},
    \"title\":{\"stringValue\":\"$2\"},
    \"description\":{\"stringValue\":\"Join our team and gain real experience working on a product used by thousands of students.\"},
    \"type\":{\"stringValue\":\"$3\"},
    \"skills\":{\"arrayValue\":{\"values\":$4}},
    \"commitment\":{\"stringValue\":\"$7\"},
    \"duration\":{\"stringValue\":\"$8\"},
    \"isPaid\":{\"booleanValue\":$5},
    \"compensation\":{\"stringValue\":\"$6\"},
    \"location\":{\"stringValue\":\"Remote\"},
    \"isActive\":{\"booleanValue\":true},
    \"applicationCount\":{\"integerValue\":\"0\"},
    \"viewCount\":{\"integerValue\":\"0\"},
    \"maxApplicants\":{\"integerValue\":\"10\"},
    \"deadline\":{\"timestampValue\":\"$deadline\"},
    \"responsibilities\":{\"arrayValue\":{\"values\":[{\"stringValue\":\"Contribute to weekly sprints\"},{\"stringValue\":\"Ship production features\"}]}},
    \"requirements\":{\"arrayValue\":{\"values\":[{\"stringValue\":\"Relevant coursework or projects\"},{\"stringValue\":\"15 hours per week availability\"}]}},
    \"createdAt\":{\"timestampValue\":\"$now\"},
    \"updatedAt\":{\"timestampValue\":\"$now\"}}}" > /dev/null
  echo "  opportunity: $2"
}

echo "Creating opportunities..."
seed_opp "seed-opp-1" "Flutter Developer Intern" "Software Development" \
  '[{"stringValue":"Flutter"},{"stringValue":"Dart"},{"stringValue":"Firebase"}]' \
  true '\$150/month stipend' "Part-time" "3 months"
seed_opp "seed-opp-2" "UI/UX Design Intern" "UI/UX Design" \
  '[{"stringValue":"Figma"},{"stringValue":"User Research"}]' \
  false '' "Flexible" "2 months"
seed_opp "seed-opp-3" "Marketing Intern" "Marketing" \
  '[{"stringValue":"Social Media"},{"stringValue":"Copywriting"}]' \
  true '\$80/month stipend' "Part-time" "2 months"

echo "Done. Register a student account in the app and the feed will be populated."
echo "Emulator UI: http://localhost:4000"
