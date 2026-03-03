import { Pool } from "pg";

// ─── Connection Pool ──────────────────────────────────────────────────────────

export const pool = new Pool({
  host:     process.env.PG_HOST     ?? "localhost",
  port:     Number(process.env.PG_PORT ?? 5432),
  database: process.env.PG_DATABASE ?? "letslegal",
  user:     process.env.PG_USER     ?? "postgres",
  password: process.env.PG_PASSWORD ?? "",
});

// ─── Schema init ──────────────────────────────────────────────────────────────

export async function initPostgres(): Promise<void> {
  const client = await pool.connect();
  try {
    await client.query(`
      -- UUID extension
      CREATE EXTENSION IF NOT EXISTS "pgcrypto";

      -- ── Cases ────────────────────────────────────────────────────────────────
      CREATE TABLE IF NOT EXISTS cases (
        id               TEXT PRIMARY KEY DEFAULT gen_random_uuid()::text,
        case_number      TEXT NOT NULL UNIQUE,
        title            TEXT NOT NULL,
        case_type        TEXT NOT NULL DEFAULT 'Civil',
        client_name      TEXT NOT NULL,
        client_phone     TEXT,
        opposing_party   TEXT,
        court_name       TEXT NOT NULL,
        court_type       TEXT DEFAULT 'High Court',
        judge_or_bench   TEXT,
        filed_date       DATE,
        next_hearing_date DATE,
        status           TEXT NOT NULL DEFAULT 'open',
        advocate_id      TEXT NOT NULL,
        notes            TEXT,
        timeline         JSONB NOT NULL DEFAULT '[]',
        created_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
        updated_at       TIMESTAMPTZ NOT NULL DEFAULT NOW()
      );

      -- ── Reminders ─────────────────────────────────────────────────────────────
      CREATE TABLE IF NOT EXISTS reminders (
        id           TEXT PRIMARY KEY DEFAULT gen_random_uuid()::text,
        advocate_id  TEXT NOT NULL,
        case_id      TEXT,
        title        TEXT NOT NULL,
        due_date     DATE NOT NULL,
        priority     TEXT NOT NULL DEFAULT 'medium',
        is_completed BOOLEAN NOT NULL DEFAULT FALSE,
        created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW()
      );

      -- ── Diary entries ─────────────────────────────────────────────────────────
      CREATE TABLE IF NOT EXISTS diary_entries (
        id             TEXT PRIMARY KEY DEFAULT gen_random_uuid()::text,
        advocate_id    TEXT NOT NULL,
        date           DATE NOT NULL,
        title          TEXT NOT NULL,
        notes          TEXT NOT NULL,
        category       TEXT DEFAULT 'other',
        linked_case_id TEXT,
        created_at     TIMESTAMPTZ NOT NULL DEFAULT NOW()
      );

      -- ── Help requests ─────────────────────────────────────────────────────────
      CREATE TABLE IF NOT EXISTS help_requests (
        id           TEXT PRIMARY KEY DEFAULT gen_random_uuid()::text,
        client_id    TEXT NOT NULL,
        client_name  TEXT NOT NULL,
        phone        TEXT,
        issue_type   TEXT NOT NULL DEFAULT 'general',
        description  TEXT NOT NULL,
        status       TEXT NOT NULL DEFAULT 'pending',
        created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW()
      );

      -- ── Tracked cases (client → case mapping) ────────────────────────────────
      CREATE TABLE IF NOT EXISTS tracked_cases (
        id          TEXT PRIMARY KEY DEFAULT gen_random_uuid()::text,
        client_id   TEXT NOT NULL,
        case_number TEXT NOT NULL,
        created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
        UNIQUE(client_id, case_number)
      );
    `);

    // Seed demo cases if table is empty
    const { rows } = await client.query("SELECT COUNT(*) FROM cases");
    if (Number(rows[0].count) === 0) {
      await client.query(`
        INSERT INTO cases (id, case_number, title, case_type, client_name, client_phone,
          opposing_party, court_name, court_type, judge_or_bench, filed_date,
          next_hearing_date, status, advocate_id, notes, timeline)
        VALUES
        (
          'case-001', 'LL-2025-DEMO001', 'Rajan vs State of Delhi', 'Criminal',
          'Ramesh Rajan', '9811000001', 'State of Delhi', 'Delhi High Court', 'High Court',
          'Hon. Justice A.K. Sharma', '2025-11-10', '2026-03-15', 'in_progress',
          'advocate-demo', 'Case proceeding well. Bail secured.',
          '[{"date":"2025-11-10","event":"FIR filed and case registered","status":"done"},{"date":"2026-03-15","event":"Next hearing (scheduled)","status":"upcoming"}]'
        ),
        (
          'case-002', 'LL-2025-DEMO002', 'Sharma vs Gupta (Property Dispute)', 'Civil',
          'Amit Sharma', '9123456789', 'Rajiv Gupta', 'Delhi High Court', 'High Court',
          'Hon. Justice P.S. Nair', '2025-09-01', '2026-04-10', 'open',
          'advocate-demo', 'Property partition suit. Survey report pending.',
          '[{"date":"2025-09-01","event":"Suit filed","status":"done"},{"date":"2026-04-10","event":"Issues to be framed","status":"upcoming"}]'
        ),
        (
          'case-003', 'LL-2026-DEMO003', 'Meera Nair vs Arun Nair (Divorce)', 'Family',
          'Meera Nair', '9922000001', 'Arun Nair', 'Family Court, Delhi', 'Family Court',
          'Hon. Judge R. Khanna', '2026-01-05', '2026-04-25', 'open',
          'advocate-demo', 'Divorce petition filed.',
          '[{"date":"2026-01-05","event":"Petition filed","status":"done"},{"date":"2026-04-25","event":"First mediation hearing","status":"upcoming"}]'
        )
        ON CONFLICT (case_number) DO NOTHING;
      `);
      console.log("🌱  Demo cases seeded into PostgreSQL");
    }

    console.log("✅  PostgreSQL connected + schema ready");
  } finally {
    client.release();
  }
}
