import { Request, Response, NextFunction } from "express";
import jwt from "jsonwebtoken";

// ─── JWT-based middleware (stateless — no shared user array needed) ────────────

/** No-op legacy exports kept so index.ts doesn't need a refactor */
export function registerUsers(_users: unknown[]): void { /* no-op */ }
export function getUsers(): unknown[] { return []; }

function extractToken(req: Request): string | null {
  const h = req.headers.authorization ?? "";
  if (h.startsWith("Bearer ")) return h.slice(7);
  return h || null;
}

export function verifyJwt(token: string): { userId: string; role: string } | null {
  try {
    return jwt.verify(token, process.env.JWT_SECRET ?? "secret") as { userId: string; role: string };
  } catch {
    return null;
  }
}

export interface AuthenticatedRequest extends Request {
  userId?: string;
  userRole?: string;
}

export function requireAuth(req: AuthenticatedRequest, res: Response, next: NextFunction) {
  const token = extractToken(req);
  if (!token) return res.status(401).json({ message: "Authentication required" });
  const payload = verifyJwt(token);
  if (!payload) return res.status(401).json({ message: "Invalid or expired token" });
  req.userId = payload.userId;
  req.userRole = payload.role;
  return next();
}

export function requireAdvocate(req: AuthenticatedRequest, res: Response, next: NextFunction) {
  requireAuth(req, res, () => {
    if (req.userRole !== "advocate") {
      return res.status(403).json({ message: "Access restricted to advocates" });
    }
    return next();
  });
}

export function optionalAuth(req: AuthenticatedRequest, _res: Response, next: NextFunction) {
  const token = extractToken(req);
  if (token) {
    const payload = verifyJwt(token);
    if (payload) { req.userId = payload.userId; req.userRole = payload.role; }
  }
  return next();
}
