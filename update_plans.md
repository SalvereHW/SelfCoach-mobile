You're an expert in full-stack health tech product design. I’m building a smart, gamified health app using this stack:

- Mobile App: **Flutter**
- Backend: **NestJS**
- Auth: **Supabase (Auth only)**
- Data: Synced from mobile → backend DB (NestJS manages all logic)

Currently built:

- Manual forms for logging: sleep, meals, physical activities (e.g. walking, running, yoga, etc.)
- Health Plan: generated from user conditions and food preferences
- Basic wellness session modules

> Note:
**Important!!!!**: Any backend updates that needed to be done to power the features should be in this backend directory:
/Users/abiodun/PROJECTS/Salvere/SelfCoach-backend

Look at all intergrations that i have done in the mobile app and backend to understand the flow of data and how it is being used.

I want to upgrade the app with the following intelligent, engaging, and highly usable features — generate a full system design to implement all of these:

---

## 0. **User Profile**

Based on the user data avalable on the backend Create user profile management on the app with the ability of user to update their profile information and other user related details.

## 🔁 1. **Auto-logging (Replacing manual forms)**

Replace or supplement manual logging via automated or AI-assisted flows:

- Sleep detection from: Apple HealthKit / Google Fit / Oura / Garmin / Fitbit / Samsung Health
- Activity detection using motion sensors + activity classification (walk/run/swim/cycle/etc.)
- Meal logging via:
  - Food image → meal name + estimate calories (e.g., TFLite or CalorieMama API)
  - Voice-to-text meal entry using Flutter + NLP → structured food entry
  - Contextual prompts based on meal times + history

> Recommend:

- Flutter plugins to access health data (iOS/Android)
- Backend services to process meal images, infer activity types, or sleep periods
- Sync/data strategy for fallback/manual correction
- NestJS controller/data model suggestions

---

## 📊 2. **Dynamic Health Plan Engine**

Enhance current health plan system using:

- Additional signals: activity level, sleep quality, nutrition logs, health goals
- Risk scoring (e.g., prediabetes, hypertension likelihood)
- Weekly adaptation of the plan based on behavior (e.g. user didn’t sleep well → reduce cardio, improve meal plan)

> Design:

- Backend health engine architecture
- HealthPlanEntity with adaptation logic
- Weekly evaluation job (e.g. NestJS scheduled tasks + dynamic plan engine)
- Flutter UI structure for showing evolving plan + feedback prompts

---

## 💆 3. **Wellness Sessions 2.0**

Rebuild wellness sessions into interactive guided tracks:

- Themes: sleep, stress, mindful eating, habit reset
- Format: audio, video, text, interactive check-ins, reflection prompts
- Personalized suggestions based on logs + health plan
- Progress tracking, streaks, badges

> Recommend:

- WellnessSessionEntity schema
- How to structure a 7-day guided track system
- Flutter UX structure for daily sessions, completion, and personalization
- NestJS endpoints to deliver session content + track user completion

---

## 🕹️ 4. **Gamification Engine**

Boost motivation and retention with:

- XP system (points per log, session, plan follow-through)
- Challenges (e.g., “log sleep 5 times this week”)
- Streaks, badges, level-ups
- Leaderboard (optional) + social accountability (opt-in)
- Rewards (in-app coins, coupons, etc.)

> Design:

- GamificationEntity, ChallengeEntity, XPEventEntity
- Flutter UI for XP meter, badge unlock, streak tracking
- Backend logic for XP calculation and badge unlock rules
- Suggestions for weekly/monthly events

---

## 📱 5. **UX Improvements & Smart Automation**

Create a seamless user experience:

- Smart onboarding (get HealthKit/Fit/Sensor permissions)
- Real-time nudges (e.g., “No meal logged for lunch — add it now?”)
- Local caching of logs with sync to backend
- Offline mode with sync when online

> Suggest:

- Flutter permission & caching plugins
- Best sync pattern for local logs → backend (consider timeouts, duplicates)
- UX for daily dashboard: today’s health, wellness session, plan highlights, streaks

---

## 🧠 6. **Tech Stack Integration Guide**

Recommend tools, services, and design patterns compatible with my stack:

- Flutter: plugins for health data, camera, voice input, local storage
- NestJS: health plan engine, gamification engine, CRON jobs, validation
- DB schema for: Logs, WellnessSessions, HealthPlans, XP/Challenges, Conditions
- Open-source AI or APIs for food recognition, NLP, sleep/activity inference

---

Respond with:

- Feature-by-feature architecture and flow
- Class & Entity definitions (NestJS + Flutter Models)
- Recommended APIs/plugins/libraries for Flutter
- System diagrams or flowcharts (text-based ok)
- UX flow wireframes (or outlines) for key screens
- Optional ideas for monetization or growth

Ensure your design is:

- Modular
- Scalable
- Personalization-ready
- Easy to extend with AI-based automation in the future
