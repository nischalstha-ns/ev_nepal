# EV Nepal - Electric Vehicle Charging Platform

> **Find. Book. Charge. Swap.**

A comprehensive Flutter-based electric vehicle charging management platform built for Nepal's growing EV ecosystem. The app serves three user roles — EV Drivers, Station Operators, and Platform Administrators — providing end-to-end charging station discovery, booking, queue management, battery swap services, and real-time monitoring.

---

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Architecture](#architecture)
- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [Database Schema](#database-schema)
- [Getting Started](#getting-started)
- [Role-Based Workflows](#role-based-workflows)
- [Screenshots & UI](#screenshots--ui)
- [Roadmap](#roadmap)
- [Contributing](#contributing)

---

## Overview

EV Nepal addresses the core challenges facing electric vehicle adoption in Nepal:

- **Station Discovery** — Locate approved charging stations across Nepal with real-time availability
- **Smart Booking** — Reserve chargers with QR-code based check-in
- **Queue Management** — Join virtual queues when stations are busy, with estimated wait times
- **Battery Swap** — Reserve pre-charged batteries at swap-enabled stations
- **AI Route Planning** — Intelligent trip planner that recommends charging stops based on distance, terrain, and station availability across 20+ Nepali cities
- **Operator Tools** — Complete station management suite with live monitoring, revenue analytics, and CCTV surveillance
- **Admin Dashboard** — Platform-wide analytics, station approval workflow, user management, and membership plan configuration

---

## Features

### EV Driver (User)

| Feature | Description |
|---------|-------------|
| Driver Dashboard | Vehicle status, nearby stations, quick actions |
| Station Discovery | Browse and search approved stations with filters |
| Interactive Map | OpenStreetMap-based map with station markers and GPS location |
| Station Details | Charger types, power ratings, pricing, reviews, amenities |
| Booking System | Select charger, set charging target (%, full, timed), get QR code |
| Queue System | Join virtual queue, see position and estimated wait time |
| Battery Swap | Browse swap-enabled stations, reserve batteries with QR token |
| AI Route Planner | City-to-city route planning with charging stop recommendations |
| QR Check-in | Present QR code at station to start charging session |
| Reviews & Ratings | Rate and review stations (one review per user per station) |
| Membership Plans | Subscribe to monthly/yearly plans for discounted charging |
| Notifications | Real-time notifications for booking status changes |
| Profile Management | Edit profile, manage vehicles, view charging history |
| Charging History | Complete history of past bookings and sessions |

### Station Operator

| Feature | Description |
|---------|-------------|
| Operator Dashboard | Overview metrics, active sessions, revenue summary |
| Station Registration | Register new station with location, hours, amenities |
| Live Station Monitor | Real-time charger status and availability |
| Charger Fleet Management | Add/remove chargers, update status (available/occupied/maintenance/offline) |
| Smart Queue Management | View queue, call next customer, manage flow |
| Session Management | Start/complete charging sessions, view active sessions |
| QR Scanner | Scan customer QR codes to validate bookings |
| Revenue Analytics | Revenue trends, payment method breakdown, transaction history (with fl_chart) |
| CCTV Surveillance | Integrated camera monitoring view |
| Operator Settings | Station configuration and preferences |

### Platform Administrator

| Feature | Description |
|---------|-------------|
| Analytics Dashboard | Platform-wide KPIs: stations, chargers, bookings, revenue, users |
| Network Monitoring | Geographic overview of all stations across Nepal |
| Station Approval | Approve or reject operator station applications with reasons |
| User Management | View all users, manage status (active/suspended) |
| Membership Plans | Create and manage subscription plans for users and operators |

---

## Architecture

```
┌─────────────────────────────────────────────────────┐
│                    Flutter App                        │
│  ┌───────────┐  ┌──────────┐  ┌──────────────────┐  │
│  │  Screens  │  │  Models  │  │     Widgets      │  │
│  │ (3 roles) │  │ (8 types)│  │  (reusable UI)   │  │
│  └─────┬─────┘  └────┬─────┘  └────────┬─────────┘  │
│        │              │                 │            │
│  ┌─────┴──────────────┴─────────────────┴─────┐     │
│  │              Services Layer                 │     │
│  │  ┌────────────┐ ┌───────────┐ ┌──────────┐ │     │
│  │  │ ApiService │ │AuthService│ │Realtime  │ │     │
│  │  │  (CRUD)    │ │(Auth+Demo)│ │Service   │ │     │
│  │  └──────┬─────┘ └─────┬─────┘ └────┬─────┘ │     │
│  └─────────┼──────────────┼────────────┼───────┘     │
└────────────┼──────────────┼────────────┼─────────────┘
             │              │            │
    ┌────────┴──────────────┴────────────┴────────┐
    │              Supabase Backend                │
    │  ┌──────────┐  ┌──────────┐  ┌───────────┐  │
    │  │ Database │  │   Auth   │  │ Realtime  │  │
    │  │(Postgres)│  │  (JWT)   │  │(WebSocket)│  │
    │  └──────────┘  └──────────┘  └───────────┘  │
    └─────────────────────────────────────────────┘
```

### Design Patterns

- **Service Layer Pattern** — All Supabase interactions abstracted into `ApiService`, `AuthService`, `RealtimeService`
- **Shell Navigation** — Each role has a shell (`UserShell`, `OperatorShell`, `AdminShell`) with `IndexedStack` for tab persistence
- **Responsive Layout** — `LayoutBuilder` with `NavigationRail` for desktop (>=600px) and `NavigationBar` for mobile
- **Realtime Streams** — Supabase Realtime subscriptions for live charger status, bookings, queues, and notifications
- **Material Design 3** — Full M3 color scheme with custom "Lumina Ecology" green-primary design system

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Flutter 3.7+ (Dart) |
| Backend | Supabase (PostgreSQL, Auth, Realtime) |
| Maps | flutter_map + OpenStreetMap tiles |
| Location | geolocator |
| Charts | fl_chart |
| QR Generation | qr_flutter |
| QR Scanning | mobile_scanner |
| HTTP | http package |
| State Management | StatefulWidget + setState (lightweight, no external state library) |
| Image Caching | cached_network_image |
| Image Picking | image_picker |
| Date/Time | intl |
| URL Handling | url_launcher |
| Design System | Material 3 with custom ColorScheme |

---

## Project Structure

```
ev_nepal/
├── lib/
│   ├── main.dart                    # App entry point, route definitions
│   ├── config/
│   │   └── supabase_config.dart     # Supabase URL and anon key
│   ├── models/
│   │   ├── station_model.dart       # Station with charger aggregation
│   │   ├── charger_model.dart       # Charger details (type, power, price)
│   │   ├── booking_model.dart       # Booking with QR token
│   │   ├── battery_model.dart       # Battery swap inventory
│   │   ├── vehicle_model.dart       # User vehicle profiles
│   │   ├── review_model.dart        # Station reviews
│   │   ├── membership_plan_model.dart
│   │   └── notification_model.dart
│   ├── screens/
│   │   ├── splash_screen.dart       # App launch screen
│   │   ├── role_selection_screen.dart # User/Operator/Admin role picker
│   │   ├── auth/
│   │   │   ├── login_screen.dart
│   │   │   └── register_screen.dart
│   │   ├── user/                    # 15+ screens for EV drivers
│   │   │   ├── user_shell.dart      # Bottom nav container
│   │   │   ├── driver_dashboard.dart
│   │   │   ├── stations_tab.dart
│   │   │   ├── map_screen.dart
│   │   │   ├── ai_planner_screen.dart
│   │   │   ├── station_detail_screen.dart
│   │   │   ├── booking_screen.dart
│   │   │   ├── qr_screen.dart
│   │   │   ├── queue_screen.dart
│   │   │   ├── battery_swap_screen.dart
│   │   │   ├── membership_screen.dart
│   │   │   ├── submit_review_screen.dart
│   │   │   ├── notifications_screen.dart
│   │   │   ├── user_history_tab.dart
│   │   │   └── user_profile_screen.dart
│   │   ├── operator/               # 12+ screens for station operators
│   │   │   ├── operator_shell.dart
│   │   │   ├── operator_dashboard.dart
│   │   │   ├── live_station_monitor.dart
│   │   │   ├── smart_queue_screen.dart
│   │   │   ├── session_management_screen.dart
│   │   │   ├── manage_chargers_screen.dart
│   │   │   ├── booking_management_screen.dart
│   │   │   ├── qr_scanner_screen.dart
│   │   │   ├── operator_revenue_tab.dart
│   │   │   ├── operator_revenue_analytics.dart
│   │   │   ├── cctv_surveillance_screen.dart
│   │   │   ├── register_station_screen.dart
│   │   │   └── operator_settings_tab.dart
│   │   └── admin/                  # 5 screens for platform admins
│   │       ├── admin_shell.dart
│   │       ├── admin_analytics_tab.dart
│   │       ├── admin_network_tab.dart
│   │       ├── admin_users_tab.dart
│   │       ├── membership_plans_tab.dart
│   │       └── station_approval_screen.dart
│   ├── services/
│   │   ├── api_service.dart         # All Supabase CRUD operations
│   │   ├── auth_service.dart        # Authentication + demo mode
│   │   ├── supabase_service.dart    # Supabase initialization
│   │   ├── realtime_service.dart    # Realtime stream subscriptions
│   │   └── notification_service.dart
│   ├── theme/
│   │   └── app_theme.dart           # Material 3 theme + color system
│   ├── utils/
│   │   ├── nepal_cities.dart        # 20+ Nepal cities with coordinates
│   │   └── responsive.dart          # Responsive layout utilities
│   └── widgets/                     # Reusable UI components
│       ├── app_logo.dart
│       ├── branded_app_bar.dart
│       ├── charger_status_chip.dart
│       ├── charging_progress_bar.dart
│       ├── dashboard_card.dart
│       ├── glass_card.dart
│       ├── primary_button.dart
│       ├── shimmer_card.dart
│       └── station_card.dart
├── supabase/
│   ├── schema.sql                   # Full database schema (11 tables)
│   ├── seed.sql                     # Demo data for presentations
│   ├── realtime.sql                 # Enable Realtime publication
│   └── demo_reset.sql               # Reset to clean demo state
├── assets/
│   └── images/logo.png
├── docs/
│   ├── setup.md                     # Detailed setup instructions
│   ├── roadmap.md                   # Post-hackathon development plan
│   └── demo_script.md               # Demo presentation guide
├── pubspec.yaml
└── analysis_options.yaml
```

---

## Database Schema

The app uses **11 PostgreSQL tables** managed through Supabase:

```
┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│    users     │     │   stations   │     │   chargers   │
├──────────────┤     ├──────────────┤     ├──────────────┤
│ id (PK)      │◄────│ owner_id(FK) │     │ id (PK)      │
│ name         │     │ id (PK)      │◄────│ station_id   │
│ email        │     │ name         │     │ name         │
│ phone        │     │ address/city │     │ charger_type │
│ role         │     │ lat/lng      │     │ connector    │
│ tier         │     │ is_approved  │     │ power_kw     │
│ status       │     │ has_battery  │     │ price_per_kwh│
└──────┬───────┘     │ amenities[]  │     │ status       │
       │             └──────────────┘     └──────────────┘
       │
       ├─── bookings (user_id, station_id, charger_id, qr_token, status)
       ├─── queues (user_id, station_id, charger_id, position, status)
       ├─── vehicles (user_id, model_name, connector_type, battery_capacity)
       ├─── reviews (user_id, station_id, rating, comment) [unique per pair]
       ├─── user_memberships (user_id, plan_id, billing, status)
       ├─── notifications (user_id, title, body, type, is_read)
       └─── swap_transactions (user_id, battery_id, station_id, action)

Additional tables:
  - batteries (station_id, battery_code, capacity, health_percent, status)
  - membership_plans (name, for_role, price_monthly, price_yearly, benefits)
```

### Charger Types Supported

| Type | Connector | Typical Power |
|------|-----------|---------------|
| AC | Type 2 | 7.4 kW |
| DC | CCS | 50 kW |
| DC | CHAdeMO | 44 kW |
| DC | GB/T | 60 kW |

### Status Flows

**Charger**: `available` → `reserved` → `occupied` → `available` (or `maintenance`/`offline`)

**Booking**: `confirmed` → `charging` → `completed` (or `cancelled`)

**Queue**: `waiting` → `called` → `served` (or `cancelled`)

**Battery**: `available` → `reserved` → `swapped` (or `maintenance`)

---

## Getting Started

### Prerequisites

- Flutter SDK >= 3.7.0
- Dart SDK >= 3.7.0
- A Supabase account (free tier works)
- Android/iOS emulator or physical device (also runs on Web, Windows, macOS, Linux)

### Installation

```bash
# 1. Clone the repository
git clone https://github.com/your-username/ev_nepal.git
cd ev_nepal

# 2. Install dependencies
flutter pub get

# 3. Configure Supabase credentials
# Edit lib/config/supabase_config.dart with your project URL and anon key

# 4. Set up the database (in Supabase SQL Editor, run in order):
#    - supabase/schema.sql
#    - supabase/seed.sql
#    - supabase/realtime.sql

# 5. Run the app
flutter run
```

### Demo Mode

The app includes a built-in demo mode with mock user IDs for quick testing without real authentication:

| Role | Demo UUID | Name |
|------|-----------|------|
| User | `11111111-1111-...` | Rajesh Sharma |
| Operator | `22222222-2222-...` | Station Operator |
| Admin | `33333333-3333-...` | Platform Admin |

Select a role from the Role Selection Screen to explore the full app as that persona.

### Demo Reset

To restore the database to its initial demo state before a presentation:

```sql
-- Run supabase/demo_reset.sql in the Supabase SQL Editor
```

---

## Role-Based Workflows

### Driver Workflow

```
Role Selection → Driver Dashboard → Browse Stations → Select Station
  → View Charger Details → Book Charger → Get QR Code → Present at Station
  → Charging Session Starts → Session Completes → View in History
```

### Operator Workflow

```
Role Selection → Register Station (if first time) → Operator Dashboard
  → Monitor Chargers → Scan QR Code → Start Session → Manage Queue
  → View Revenue Analytics → Configure Settings
```

### Admin Workflow

```
Role Selection → Admin Analytics → Review Station Applications
  → Approve/Reject Stations → Monitor Network → Manage Users
  → Configure Membership Plans
```

---

## Screenshots & UI

The app uses a custom **Lumina Ecology** design system built on Material 3:

- **Primary Color**: `#006B2C` (Deep Green — representing clean energy)
- **Surface Colors**: Light blue-tinted whites for depth
- **Typography**: System font with weighted hierarchy (w400–w800)
- **Cards**: Zero-elevation with subtle border strokes
- **Navigation**: Adaptive — bottom bar on mobile, rail on tablet/desktop
- **Transitions**: Custom fade + slide page transitions (260ms ease-out)
- **Components**: Glass cards, shimmer loading, charger status chips, progress bars

---

## Roadmap

### Phase 1 — Authentication & Multi-User
- Real Supabase Auth with phone OTP
- Row-Level Security (RLS) policies
- Per-user data isolation

### Phase 2 — Payments
- eSewa, Khalti, FonePay integration
- Real payment confirmation callbacks
- Transaction tracking and refunds

### Phase 3 — Charger Hardware Integration
- OCPP 1.6/2.0.1 protocol support
- Backend Central System (FastAPI/Node)
- Real charger start/stop commands and meter values

### Phase 4 — Enhanced UX
- Push notifications via FCM
- Google Maps / Mapbox integration
- Station photo uploads (Cloudinary)
- Real routing API for AI Planner

### Phase 5 — Operations & Analytics
- Multi-language support (Nepali + English)
- Predictive demand forecasting
- Carbon offset tracking
- Real energy consumption reporting

---

## Environment & Platform Support

| Platform | Status |
|----------|--------|
| Android | Supported |
| iOS | Supported |
| Web | Supported |
| Windows | Supported |
| macOS | Supported |
| Linux | Supported |

---

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## License

This project was built for Nepal's EV ecosystem development initiative.

---

## Acknowledgments

- Built with [Flutter](https://flutter.dev) and [Supabase](https://supabase.com)
- Map tiles from [OpenStreetMap](https://www.openstreetmap.org)
- Nepal city coordinate data for route planning
- Designed with Material Design 3 guidelines
