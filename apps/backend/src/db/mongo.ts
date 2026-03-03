import mongoose, { Schema, Document, Model } from "mongoose";
import bcrypt from "bcryptjs";

// ─── Connection ───────────────────────────────────────────────────────────────

let connected = false;

export async function connectMongo(): Promise<void> {
  if (connected) return;
  const uri = process.env.MONGO_URI;
  if (!uri) throw new Error("MONGO_URI is not set in .env");
  await mongoose.connect(uri);
  connected = true;
  console.log("✅  MongoDB connected (users)");
}

// ─── User Schema ──────────────────────────────────────────────────────────────

export interface IUser extends Document {
  _id: mongoose.Types.ObjectId;
  fullName: string;
  email: string;
  passwordHash: string;
  phone: string;
  role: "advocate" | "client";
  barCouncilId: string;
  enrollmentNumber: string;
  courtName: string;
  practiceAreas: string[];
  city: string;
  state: string;
  verificationStatus: "pending" | "approved" | "rejected";
  createdAt: Date;
  comparePassword(plain: string): Promise<boolean>;
}

const UserSchema = new Schema<IUser>(
  {
    fullName:           { type: String, required: true, trim: true },
    email:              { type: String, required: true, unique: true, lowercase: true, trim: true },
    passwordHash:       { type: String, required: true },
    phone:              { type: String, default: "" },
    role:               { type: String, enum: ["advocate", "client"], default: "advocate" },
    barCouncilId:       { type: String, default: "" },
    enrollmentNumber:   { type: String, default: "" },
    courtName:          { type: String, default: "" },
    practiceAreas:      { type: [String], default: [] },
    city:               { type: String, default: "" },
    state:              { type: String, default: "" },
    verificationStatus: { type: String, enum: ["pending", "approved", "rejected"], default: "pending" },
  },
  { timestamps: { createdAt: "createdAt", updatedAt: "updatedAt" } }
);

// Password helpers
UserSchema.methods.comparePassword = function (plain: string): Promise<boolean> {
  return bcrypt.compare(plain, this.passwordHash);
};

UserSchema.statics.hashPassword = (plain: string): Promise<string> => bcrypt.hash(plain, 10);

export const UserModel: Model<IUser> = mongoose.models.User ?? mongoose.model<IUser>("User", UserSchema);

// ─── Seed demo users (only if collection is empty) ───────────────────────────

export async function seedDemoUsers(): Promise<void> {
  const count = await UserModel.countDocuments();
  if (count > 0) return; // already seeded

  const advocateHash = await bcrypt.hash("Test@1234", 10);
  const clientHash   = await bcrypt.hash("Client@1234", 10);

  await UserModel.insertMany([
    {
      fullName: "Adv. Rajesh Kumar",
      email: "test@letslegal.in",
      passwordHash: advocateHash,
      phone: "9876543210",
      role: "advocate",
      barCouncilId: "BCI-DL-2018-12345",
      enrollmentNumber: "DL/BAR/2018/12345",
      courtName: "Delhi High Court",
      practiceAreas: ["Criminal", "Civil", "Family"],
      city: "New Delhi",
      state: "Delhi",
      verificationStatus: "approved",
    },
    {
      fullName: "Amit Sharma",
      email: "client@letslegal.in",
      passwordHash: clientHash,
      phone: "9123456789",
      role: "client",
      city: "New Delhi",
      state: "Delhi",
      verificationStatus: "approved",
    },
  ]);

  console.log("🌱  Demo users seeded into MongoDB");
}
