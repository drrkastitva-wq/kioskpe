import cors from "cors";
import dotenv from "dotenv";
import express from "express";
import { authRouter } from "./routes/auth";
import { casesRouter } from "./routes/cases";
import { diaryRouter } from "./routes/diary";
import { remindersRouter } from "./routes/reminders";
import { advocatesRouter } from "./routes/advocates";
import { caseTrackerRouter } from "./routes/caseTracker";
import { calendarRouter } from "./routes/calendar";
import { connectMongo, seedDemoUsers } from "./db/mongo";
import { initPostgres } from "./db/postgres";

dotenv.config();

const app = express();
const port = Number(process.env.PORT ?? 4000);

app.use(cors());
app.use(express.json());

// ─── Health ────────────────────────────────────────────────────────────────────
app.get("/health", (_req, res) => {
  res.json({ status: "ok", service: "lets-legal-backend", timestamp: new Date().toISOString() });
});

// ─── Routes ───────────────────────────────────────────────────────────────────
app.use("/api/auth",     authRouter);
app.use("/api/cases",    casesRouter);
app.use("/api/reminders", remindersRouter);
app.use("/api/diary",    diaryRouter);
app.use("/api/advocates", advocatesRouter);
app.use("/api/track",    caseTrackerRouter);
app.use("/api/client",   caseTrackerRouter);   // → /api/client/help-requests
app.use("/api/calendar", calendarRouter);      // → /api/calendar/holidays, /courts

// ─── API index ────────────────────────────────────────────────────────────────
app.get("/api", (_req, res) => {
  res.json({
    name: "Let's Legal API",
    version: "2.0.0",
    databases: { auth: "MongoDB Atlas", appData: "PostgreSQL (local)" },
    endpoints: {
      auth:         ["/api/auth/login", "/api/auth/register", "/api/auth/me"],
      cases:        ["/api/cases", "/api/cases/:id", "/api/cases/:id/timeline"],
      reminders:    ["/api/reminders"],
      diary:        ["/api/diary"],
      advocates:    ["/api/advocates?q=&court=&specialization="],
      track:        ["/api/track/:caseId"],
      helpRequests: ["/api/client/help-requests"],
      calendar:     ["/api/calendar/holidays?year=&month=&court=", "/api/calendar/courts"],
    },
  });
});

// ─── Boot: connect DBs then start HTTP server ─────────────────────────────────
async function boot() {
  try {
    // MongoDB Atlas — user credentials (required)
    await connectMongo();
    await seedDemoUsers();
  } catch (err) {
    console.error("❌  MongoDB connection failed:", err);
    process.exit(1);
  }

  try {
    // PostgreSQL local — cases, reminders, diary (optional until installed)
    await initPostgres();
  } catch (err) {
    console.warn("⚠️   PostgreSQL not reachable — cases/reminders/diary endpoints will fail.");
    console.warn("     Install PostgreSQL and ensure it is running on port 5432.");
    console.warn("     Then set PG_USER / PG_PASSWORD in .env and restart.\n");
  }

  app.listen(port, () => {
    console.log(`\n🏛  Let's Legal backend running on http://localhost:${port}`);
    console.log(`📋  API info: http://localhost:${port}/api`);
    console.log(`🍃  Auth DB : MongoDB Atlas (connected)`);
    console.log(`🐘  App DB  : PostgreSQL localhost:${process.env.PG_PORT ?? 5432}\n`);
  });
}

boot();
