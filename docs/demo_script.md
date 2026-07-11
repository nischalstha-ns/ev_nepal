# EV Nepal — Hackathon Demo Script

Estimated demo time: **8–10 minutes**

---

## Setup (before starting)

- Run `supabase/demo_reset.sql` to restore clean demo data
- Launch the app on a device/emulator
- Have a second device or browser tab ready to show the Operator role simultaneously (optional but impressive)

---

## Flow 1 — EV User Books a Charger (3 min)

1. **Splash screen** → auto-navigates after 2 seconds
2. **Role Selection** → tap **EV User**
3. **Driver Dashboard** — show the greeting card, battery status (78%), and quick action buttons
4. Tap **Find Station** or switch to the **Stations** tab
5. **Stations list** — show search bar, tap **Kathmandu EV Hub**
6. **Station Detail** — show charger list with availability chips; tap **Book** on AC Charger 1
7. **Booking Screen** — set target to 80%, select "Charge to Target", tap **Confirm Booking**
8. **QR Screen** — show the generated QR code; explain this is what gets scanned at the charger
9. Tap **Back to Home**

**Key talking points:** Real-time availability, simulated payment (NPR 420), QR token generated client-side without a backend.

---

## Flow 2 — Operator Manages the Booking (2 min)

1. Go back to **Role Selection** (tap Sign Out in profile, or restart)
2. Tap **EV Station**
3. **Operator Overview** — show revenue KPIs and live charger status widget
4. Switch to **Bookings** tab — the booking just made by the user appears
5. Tap **Start Charging** — charger status updates to "Occupied" in real-time
6. Tap **Complete Charging** — status returns to "Available"

**Key talking points:** Supabase Realtime — both the user and operator see the status change live with no polling.

---

## Flow 3 — Queue Management (1 min)

1. From the user role: go to **Station Detail** → tap **Join Queue** on an occupied charger
2. **Queue Screen** — show position number and estimated wait time
3. Switch to Operator role → **Queue** tab
4. Select the charger from the dropdown → see the user's entry appear
5. Tap **Call Next** → status updates to "Called"

---

## Flow 4 — Battery Swap (1 min)

1. From the user role: tap **Battery Swap** on the home dashboard or Stations tab
2. **Battery Swap Screen** — shows Kathmandu EV Hub with 2 available batteries
3. Tap **Reserve** on BATT-KTM-001
4. Reservation dialog appears with a swap code and QR — show this

---

## Flow 5 — Admin Panel (2 min)

1. Role Selection → **Admin**
2. **Analytics tab** — show network KPIs (stations, chargers, active bookings, today's revenue)
3. Switch to **Network** tab — show animated station map
4. Switch to **Users** tab — show driver list with tier badges
5. Switch to **Station Approvals** — show approve/reject buttons for pending stations
6. Tap **Approve** on a pending station — snackbar confirms, station appears in user's list

---

## Key Features to Highlight

- **No backend server needed** — Flutter talks directly to Supabase via the anon key
- **Realtime updates** — charger status, bookings, and queue changes propagate instantly
- **Role-based UX** — completely different apps for user / operator / admin, same codebase
- **Responsive** — works on mobile (NavigationBar) and tablet/desktop (NavigationRail)
- **Offline-safe** — demo fallback data if Supabase is unreachable
