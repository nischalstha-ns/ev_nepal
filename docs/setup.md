# EV Nepal — Setup Guide

## Prerequisites

- Flutter SDK 3.12+
- A Supabase account (free tier is fine)
- Android emulator or physical device (or web browser for desktop testing)

---

## 1. Create a Supabase Project

1. Go to [supabase.com](https://supabase.com) and create a new project.
2. Once created, go to **Project Settings → API**.
3. Copy:
   - **Project URL** (e.g. `https://xyzxyz.supabase.co`)
   - **anon / public key** (the long `eyJ...` string under "Project API keys")

---

## 2. Add Credentials to the App

Open `lib/config/supabase_config.dart` and paste your values:

```dart
class SupabaseConfig {
  static const supabaseUrl = 'https://YOUR_PROJECT.supabase.co';
  static const supabaseAnonKey = 'eyJ...YOUR_ANON_KEY...';
}
```

**Never use the `service_role` key in the app** — anon key only.

---

## 3. Set Up the Database

In the Supabase dashboard, go to **SQL Editor** and run these files in order:

1. Run `supabase/schema.sql` — creates all 6 tables
2. Run `supabase/seed.sql` — inserts demo data
3. Run `supabase/realtime.sql` — enables live updates

Each file can be copy-pasted directly into the SQL Editor and run.

---

## 4. Run the App

```bash
cd ev_nepal
flutter pub get
flutter run
```

The app launches to a splash screen, then the Role Selection screen. Choose:
- **EV User** — browse stations, book chargers, join queue, battery swap
- **EV Station** — manage chargers, view/handle bookings, manage queue
- **Admin** — approve stations, view analytics, manage users

---

## 5. Demo Reset (Before Judging)

If you want to clear all test data and restore the initial demo state, run
`supabase/demo_reset.sql` in the SQL Editor. This truncates all tables and
re-inserts the original seed data.

---

## Troubleshooting

| Issue | Fix |
|-------|-----|
| App crashes on startup | Check `supabase_config.dart` — URL and key must not be empty |
| Stations list is empty | Make sure `seed.sql` was run and `is_approved = true` in the stations table |
| Realtime not updating | Run `realtime.sql` to enable the Realtime publication |
| `flutter pub get` fails | Ensure Flutter SDK is ≥ 3.12.1 (`flutter --version`) |
