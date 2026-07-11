-- EV Nepal — Demo Seed Data
-- Run this after schema.sql
-- UUIDs match the hardcoded demo values in the Flutter app

-- ── Demo user ──────────────────────────────────────────────────────────────────
INSERT INTO users (id, name, email, phone, tier) VALUES
  ('11111111-1111-1111-1111-111111111111', 'Rajesh Sharma', 'rajesh.sharma@evnepal.com', '+977-9801234567', 'premium')
ON CONFLICT (id) DO NOTHING;

-- ── Demo stations ──────────────────────────────────────────────────────────────
INSERT INTO stations (id, name, address, city, latitude, longitude, rating, is_approved, has_battery_swap, opening_time, closing_time, contact_number) VALUES
  (
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
    'Kathmandu EV Hub',
    'Durbar Marg, New Road',
    'Kathmandu',
    27.7172,
    85.3240,
    4.8,
    TRUE,
    TRUE,
    '06:00',
    '22:00',
    '+977-01-4444444'
  ),
  (
    'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
    'Pokhara Lakeside Charge Point',
    'Lakeside Road, Baidam',
    'Pokhara',
    28.2096,
    83.9856,
    4.6,
    TRUE,
    FALSE,
    '07:00',
    '21:00',
    '+977-061-555555'
  )
ON CONFLICT (id) DO NOTHING;

-- ── Chargers for Kathmandu EV Hub ──────────────────────────────────────────────
INSERT INTO chargers (id, station_id, name, charger_type, connector_type, power_kw, price_per_kwh, status) VALUES
  (
    'cccccccc-cccc-cccc-cccc-cccccccccccc',
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
    'AC Charger 1',
    'AC',
    'Type2',
    7.4,
    15.0,
    'available'
  ),
  (
    'dddddddd-dddd-dddd-dddd-dddddddddddd',
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
    'DC Fast Charger 1',
    'DC',
    'CCS',
    50.0,
    25.0,
    'available'
  ),
  (
    'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee',
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
    'CHAdeMO 1',
    'DC',
    'CHAdeMO',
    44.0,
    22.0,
    'maintenance'
  )
ON CONFLICT (id) DO NOTHING;

-- ── Chargers for Pokhara station ───────────────────────────────────────────────
INSERT INTO chargers (station_id, name, charger_type, connector_type, power_kw, price_per_kwh, status) VALUES
  (
    'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
    'AC Charger 1',
    'AC',
    'Type2',
    7.4,
    14.0,
    'available'
  );

-- ── Batteries for Kathmandu EV Hub ─────────────────────────────────────────────
INSERT INTO batteries (station_id, battery_code, battery_type, capacity, health_percent, status) VALUES
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'BATT-KTM-001', 'Li-Ion', 72.0, 95, 'available'),
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'BATT-KTM-002', 'Li-Ion', 72.0, 87, 'available')
ON CONFLICT (battery_code) DO NOTHING;

-- ── Membership plans ───────────────────────────────────────────────────────────
INSERT INTO membership_plans (name, for_role, price_monthly, price_yearly, benefits) VALUES
  ('Basic',    'user',     0,    0,    '["5% discount on charging","View station map","Standard support"]'),
  ('Premium',  'user',     299,  2999, '["15% discount","Priority booking","Battery swap included","Chat support"]'),
  ('Platinum', 'user',     599,  5999, '["25% discount","Unlimited priority","Free swaps","Dedicated support"]'),
  ('Starter',  'operator', 999,  9999, '["1 station","Basic analytics","Standard support"]'),
  ('Business', 'operator', 2499, 24999,'["5 stations","Advanced analytics","Priority support","Custom branding"]')
ON CONFLICT (name) DO NOTHING;

-- ── Demo vehicle ───────────────────────────────────────────────────────────────
INSERT INTO vehicles (user_id, model_name, plate_number, connector_type, battery_capacity, is_primary) VALUES
  ('11111111-1111-1111-1111-111111111111', 'Tata Nexon EV', 'BAA 1234 PA', 'CCS2', 40.5, TRUE)
ON CONFLICT DO NOTHING;

-- ── Sample bookings ────────────────────────────────────────────────────────────
INSERT INTO bookings (user_id, station_id, charger_id, target_percent, charging_option, estimated_cost, status, payment_status, qr_token) VALUES
  (
    '11111111-1111-1111-1111-111111111111',
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
    'cccccccc-cccc-cccc-cccc-cccccccccccc',
    80,
    'target',
    420.00,
    'completed',
    'paid',
    'EVC-CCCC-DEMO01'
  ),
  (
    '11111111-1111-1111-1111-111111111111',
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
    'dddddddd-dddd-dddd-dddd-dddddddddddd',
    100,
    'full',
    875.00,
    'confirmed',
    'paid',
    'EVC-DDDD-DEMO02'
  );
