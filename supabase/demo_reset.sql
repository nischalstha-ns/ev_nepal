-- EV Nepal — Demo Reset
-- Run this before a live demo to restore all data to its initial state
-- WARNING: This will delete ALL data in these tables and re-insert demo data

-- Truncate in dependency order (children first)
TRUNCATE TABLE queues      RESTART IDENTITY CASCADE;
TRUNCATE TABLE batteries   RESTART IDENTITY CASCADE;
TRUNCATE TABLE bookings    RESTART IDENTITY CASCADE;
TRUNCATE TABLE chargers    RESTART IDENTITY CASCADE;
TRUNCATE TABLE stations    RESTART IDENTITY CASCADE;
TRUNCATE TABLE users       RESTART IDENTITY CASCADE;

-- Re-insert demo data (same as seed.sql)

INSERT INTO users (id, name, email, phone, tier) VALUES
  ('11111111-1111-1111-1111-111111111111', 'Rajesh Sharma', 'rajesh.sharma@evnepal.com', '+977-9801234567', 'premium');

INSERT INTO stations (id, name, address, city, latitude, longitude, rating, is_approved, has_battery_swap, opening_time, closing_time, contact_number) VALUES
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Kathmandu EV Hub', 'Durbar Marg, New Road', 'Kathmandu', 27.7172, 85.3240, 4.8, TRUE, TRUE, '06:00', '22:00', '+977-01-4444444'),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'Pokhara Lakeside Charge Point', 'Lakeside Road, Baidam', 'Pokhara', 28.2096, 83.9856, 4.6, TRUE, FALSE, '07:00', '21:00', '+977-061-555555');

INSERT INTO chargers (id, station_id, name, charger_type, connector_type, power_kw, price_per_kwh, status) VALUES
  ('cccccccc-cccc-cccc-cccc-cccccccccccc', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'AC Charger 1',      'AC', 'Type2',    7.4,  15.0, 'available'),
  ('dddddddd-dddd-dddd-dddd-dddddddddddd', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'DC Fast Charger 1', 'DC', 'CCS',     50.0,  25.0, 'available'),
  ('eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'CHAdeMO 1',         'DC', 'CHAdeMO', 44.0,  22.0, 'maintenance');

INSERT INTO chargers (station_id, name, charger_type, connector_type, power_kw, price_per_kwh, status) VALUES
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'AC Charger 1', 'AC', 'Type2', 7.4, 14.0, 'available');

INSERT INTO batteries (station_id, battery_code, battery_type, capacity, health_percent, status) VALUES
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'BATT-KTM-001', 'Li-Ion', 72.0, 95, 'available'),
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'BATT-KTM-002', 'Li-Ion', 72.0, 87, 'available');

INSERT INTO bookings (user_id, station_id, charger_id, target_percent, charging_option, estimated_cost, status, payment_status, qr_token) VALUES
  ('11111111-1111-1111-1111-111111111111', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'cccccccc-cccc-cccc-cccc-cccccccccccc', 80,  'target', 420.00, 'completed', 'paid', 'EVC-CCCC-DEMO01'),
  ('11111111-1111-1111-1111-111111111111', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'dddddddd-dddd-dddd-dddd-dddddddddddd', 100, 'full',   875.00, 'confirmed', 'paid', 'EVC-DDDD-DEMO02');
