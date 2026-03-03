import { Router, Request, Response } from "express";
import jwt from "jsonwebtoken";
import bcrypt from "bcryptjs";
import { UserModel } from "../db/mongo";

const router = Router();

function makeToken(userId: string, role: string): string {
  return jwt.sign(
    { userId, role },
    process.env.JWT_SECRET ?? "secret",
    { expiresIn: (process.env.JWT_EXPIRES_IN ?? "7d") as jwt.SignOptions["expiresIn"] }
  );
}

// ─── POST /api/auth/login ─────────────────────────────────────────────────────
router.post("/login", async (req: Request, res: Response) => {
  try {
    const { email, password } = req.body ?? {};
    if (!email || !password)
      return res.status(400).json({ message: "Email and password are required" });

    const user = await UserModel.findOne({ email: email.toLowerCase().trim() });
    if (!user || !(await user.comparePassword(password)))
      return res.status(401).json({ message: "Invalid email or password" });

    const token = makeToken(user._id.toString(), user.role);
    const pub = user.toObject();
    delete (pub as Record<string, unknown>).passwordHash;
    return res.json({ token, user: { ...pub, id: user._id.toString() } });
  } catch (e) {
    console.error("login error", e);
    return res.status(500).json({ message: "Server error" });
  }
});

// ─── POST /api/auth/register ───────────────────────────────────────────────────
router.post("/register", async (req: Request, res: Response) => {
  try {
    const {
      fullName, email, password, phone, role, barCouncilId,
      enrollmentNumber, courtName, practiceAreas, city, state,
    } = req.body ?? {};

    if (!email || !password || !fullName)
      return res.status(400).json({ message: "fullName, email and password are required" });

    if (await UserModel.findOne({ email: email.toLowerCase().trim() }))
      return res.status(409).json({ message: "Email already registered" });

    const passwordHash = await bcrypt.hash(password, 10);
    const user = await UserModel.create({
      fullName, email, passwordHash,
      phone: phone ?? "",
      role: role === "client" ? "client" : "advocate",
      barCouncilId: barCouncilId ?? "",
      enrollmentNumber: enrollmentNumber ?? "",
      courtName: courtName ?? "",
      practiceAreas: practiceAreas ?? [],
      city: city ?? "", state: state ?? "",
      verificationStatus: role === "client" ? "approved" : "pending",
    });

    const token = makeToken(user._id.toString(), user.role);
    const pub = user.toObject();
    delete (pub as Record<string, unknown>).passwordHash;
    return res.status(201).json({ token, user: { ...pub, id: user._id.toString() } });
  } catch (e) {
    console.error("register error", e);
    return res.status(500).json({ message: "Server error" });
  }
});

// ─── GET /api/auth/me ────────────────────────────────────────────────────────────────
router.get("/me", async (req: Request, res: Response) => {
  try {
    const authHeader = req.headers.authorization ?? "";
    const token = authHeader.startsWith("Bearer ") ? authHeader.slice(7) : authHeader;
    if (!token) return res.status(401).json({ message: "No token provided" });

    const payload = jwt.verify(token, process.env.JWT_SECRET ?? "secret") as { userId: string };
    const user = await UserModel.findById(payload.userId);
    if (!user) return res.status(401).json({ message: "User not found" });

    const pub = user.toObject();
    delete (pub as Record<string, unknown>).passwordHash;
    return res.json({ user: { ...pub, id: user._id.toString() } });
  } catch {
    return res.status(401).json({ message: "Invalid or expired token" });
  }
});

export { router as authRouter };
// Legacy no-op export
export function getUsers() { return []; }

// PLACEHOLDER_DELETE_REST──
