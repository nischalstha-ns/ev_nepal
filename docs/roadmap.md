# EV Nepal — Post-Hackathon Roadmap

## Phase 1 — Authentication & Multi-User (Sprint 1–2)

- **Real Supabase Auth** — replace demo UUID with `supabase.auth.signInWithOtp()` (phone OTP)
- **Per-user bookings** — replace hardcoded `_demoUserId` with `supabase.auth.currentUser!.id`
- **Multi-station operator** — replace hardcoded `_stationId` with the operator's assigned station(s) from a `station_operators` join table
- **Row-Level Security (RLS)** — add Supabase RLS policies so users can only read/write their own data

## Phase 2 — Payments (Sprint 3)

- **eSewa integration** — Nepal's leading mobile wallet; use the eSewa Flutter SDK
- **Khalti integration** — secondary wallet option
- **FonePay** — bank QR payment support
- Replace `payment_status: 'paid'` simulation with real payment confirmation callback
- Add `payments` table to track transaction IDs, gateway references, refunds

## Phase 3 — Real Charger Hardware (Sprint 4–6)

- **OCPP 1.6 / 2.0.1** — Open Charge Point Protocol for communicating with physical chargers
- Requires a backend server (FastAPI or Node) to act as OCPP Central System
- Charger status, start/stop commands, meter values — all via OCPP WebSocket
- Replace simulated `startCharging` / `completeCharging` with OCPP `RemoteStartTransaction` / `RemoteStopTransaction`

## Phase 4 — Enhanced UX (Sprint 5–7)

- **QR Scanner** — add `mobile_scanner` package so operators can scan user QR codes at the charger
- **Push notifications** — FCM via Supabase Edge Functions; notify users when charger is ready or queue position changes
- **Maps integration** — replace static coordinates with Google Maps / Mapbox for interactive station finder
- **Cloudinary image upload** — allow operators to upload station photos via `cloudinary_public` package
- **AI Planner** — connect the existing AI Planner screen to a real routing API (Google Directions + charging stop optimization)

## Phase 5 — Operations & Analytics (Sprint 8+)

- **Multi-language** — Nepali (Devanagari) + English via Flutter's `intl` package
- **Operator earnings dashboard** — real revenue tracking with settlement requests
- **Predictive demand** — ML model (Python/TF Lite on-device) for the demand forecast chart in AdminAnalyticsTab
- **Energy reporting** — actual kWh delivered per session from charger meter values
- **Carbon offset tracking** — display CO₂ saved vs. petrol equivalent

## Technical Debt

- Add unit tests for `ApiService` methods using `mocktail`
- Add widget tests for all 3 shell navigation flows
- Move hardcoded demo UUIDs to a `DemoConfig` class
- Add `flutter_dotenv` for environment-specific Supabase credentials (dev / staging / prod)
