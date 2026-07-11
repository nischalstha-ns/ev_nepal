-- EV Nepal — Database Schema
-- Run this first in Supabase SQL Editor before seed.sql

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ── Users ──────────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS users (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name        TEXT NOT NULL,
  email       TEXT UNIQUE,
  phone       TEXT,
  tier        TEXT NOT NULL DEFAULT 'standard',  -- standard | gold | platinum
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ── Stations ───────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS stations (
  id               UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name             TEXT NOT NULL,
  address          TEXT NOT NULL,
  city             TEXT NOT NULL,
  latitude         FLOAT8,
  longitude        FLOAT8,
  image_url        TEXT,
  opening_time     TEXT DEFAULT '06:00',
  closing_time     TEXT DEFAULT '22:00',
  contact_number   TEXT,
  rating           FLOAT4 NOT NULL DEFAULT 4.5,
  is_approved      BOOLEAN NOT NULL DEFAULT FALSE,
  has_battery_swap BOOLEAN NOT NULL DEFAULT FALSE,
  created_at       TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ── Chargers ───────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS chargers (
  id             UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  station_id     UUID NOT NULL REFERENCES stations(id) ON DELETE CASCADE,
  name           TEXT NOT NULL,
  charger_type   TEXT NOT NULL,   -- AC | DC
  connector_type TEXT NOT NULL,   -- Type2 | CCS | CHAdeMO | GB/T
  power_kw       FLOAT4 NOT NULL,
  price_per_kwh  FLOAT4 NOT NULL,
  status         TEXT NOT NULL DEFAULT 'available',  -- available | occupied | reserved | maintenance | offline
  created_at     TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ── Bookings ───────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS bookings (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id         UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  station_id      UUID NOT NULL REFERENCES stations(id) ON DELETE CASCADE,
  charger_id      UUID NOT NULL REFERENCES chargers(id) ON DELETE CASCADE,
  target_percent  INT NOT NULL DEFAULT 80,
  charging_option TEXT NOT NULL DEFAULT 'target',  -- target | full | timed
  estimated_cost  FLOAT4 NOT NULL DEFAULT 0,
  status          TEXT NOT NULL DEFAULT 'confirmed',  -- confirmed | charging | completed | cancelled
  payment_status  TEXT NOT NULL DEFAULT 'paid',       -- paid | pending | failed
  qr_token        TEXT,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ── Queues ─────────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS queues (
  id         UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id    UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  station_id UUID NOT NULL REFERENCES stations(id) ON DELETE CASCADE,
  charger_id UUID NOT NULL REFERENCES chargers(id) ON DELETE CASCADE,
  position   INT NOT NULL DEFAULT 1,
  status     TEXT NOT NULL DEFAULT 'waiting',  -- waiting | called | served | cancelled
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ── Batteries ──────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS batteries (
  id             UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  station_id     UUID NOT NULL REFERENCES stations(id) ON DELETE CASCADE,
  battery_code   TEXT NOT NULL UNIQUE,
  battery_type   TEXT NOT NULL DEFAULT 'Li-Ion',
  capacity       FLOAT4 NOT NULL DEFAULT 72.0,  -- kWh
  health_percent INT NOT NULL DEFAULT 100,
  status         TEXT NOT NULL DEFAULT 'available',  -- available | reserved | swapped | maintenance
  created_at     TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ── Schema v2 additions (run these ALTER/CREATE statements after initial setup) ─

ALTER TABLE users ADD COLUMN IF NOT EXISTS role TEXT NOT NULL DEFAULT 'user';
-- 'user' | 'operator' | 'admin'

ALTER TABLE stations ADD COLUMN IF NOT EXISTS owner_id UUID REFERENCES users(id);
ALTER TABLE stations ADD COLUMN IF NOT EXISTS description TEXT;
ALTER TABLE stations ADD COLUMN IF NOT EXISTS amenities TEXT[] DEFAULT '{}';
ALTER TABLE stations ADD COLUMN IF NOT EXISTS rejection_reason TEXT;

ALTER TABLE bookings ADD COLUMN IF NOT EXISTS start_time TIMESTAMPTZ;
ALTER TABLE bookings ADD COLUMN IF NOT EXISTS end_time TIMESTAMPTZ;
ALTER TABLE bookings ADD COLUMN IF NOT EXISTS actual_kwh FLOAT4;

CREATE TABLE IF NOT EXISTS reviews (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id     UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  station_id  UUID NOT NULL REFERENCES stations(id) ON DELETE CASCADE,
  rating      INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
  comment     TEXT,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (user_id, station_id)
);

CREATE TABLE IF NOT EXISTS vehicles (
  id               UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id          UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  model_name       TEXT NOT NULL,
  plate_number     TEXT,
  connector_type   TEXT NOT NULL DEFAULT 'CCS2',
  battery_capacity FLOAT4 NOT NULL DEFAULT 40.5,
  is_primary       BOOLEAN NOT NULL DEFAULT FALSE,
  created_at       TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS membership_plans (
  id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name          TEXT NOT NULL UNIQUE,
  for_role      TEXT NOT NULL DEFAULT 'user',
  price_monthly FLOAT4 NOT NULL,
  price_yearly  FLOAT4 NOT NULL,
  benefits      JSONB NOT NULL DEFAULT '[]',
  is_active     BOOLEAN NOT NULL DEFAULT TRUE,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS user_memberships (
  id         UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id    UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  plan_id    UUID NOT NULL REFERENCES membership_plans(id),
  billing    TEXT NOT NULL DEFAULT 'monthly',
  status     TEXT NOT NULL DEFAULT 'active',
  start_date DATE NOT NULL DEFAULT CURRENT_DATE,
  end_date   DATE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS swap_transactions (
  id           UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id      UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  battery_id   UUID NOT NULL REFERENCES batteries(id),
  station_id   UUID NOT NULL REFERENCES stations(id),
  action       TEXT NOT NULL,
  qr_token     TEXT,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS notifications (
  id         UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id    UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  title      TEXT NOT NULL,
  body       TEXT NOT NULL,
  type       TEXT NOT NULL DEFAULT 'info',
  is_read    BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
