-- EV Nepal — Fix RLS policies for stations & chargers
-- Run this in the Supabase SQL Editor to allow public read access

-- ── Stations: allow anon users to read approved stations ───────────────────────
DROP POLICY IF EXISTS "Allow anonymous read stations" ON stations;
CREATE POLICY "Allow anonymous read stations" ON stations
  FOR SELECT
  TO anon, authenticated
  USING (true);

-- ── Chargers: allow anon users to read all chargers ───────────────────────────
DROP POLICY IF EXISTS "Allow anonymous read chargers" ON chargers;
CREATE POLICY "Allow anonymous read chargers" ON chargers
  FOR SELECT
  TO anon, authenticated
  USING (true);

-- ── Users: allow anon users to read user profiles ─────────────────────────────
DROP POLICY IF EXISTS "Allow anonymous read users" ON users;
CREATE POLICY "Allow anonymous read users" ON users
  FOR SELECT
  TO anon, authenticated
  USING (true);

-- ── Ensure realtime publication includes required tables ─────────────────────
ALTER PUBLICATION supabase_realtime ADD TABLE stations;
ALTER PUBLICATION supabase_realtime ADD TABLE chargers;
