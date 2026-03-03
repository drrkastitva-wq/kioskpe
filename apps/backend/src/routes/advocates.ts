import { Router, Request, Response } from "express";

const router = Router();

// Seeded advocates list (mirrors the auth.ts test user + extras for demo)
const advocates = [
  {
    id: "test-user-001",
    fullName: "Adv. Rajesh Kumar",
    email: "contact@rajeshkumar.in",
    phone: "9876543210",
    courtName: "Delhi High Court",
    practiceAreas: ["Criminal", "Civil", "Family"],
    city: "New Delhi",
    state: "Delhi",
    experience: 12,
    bio: "Experienced criminal and civil lawyer with 12 years of practice at Delhi High Court. Specialises in bail matters, property disputes, and matrimonial cases.",
    verificationStatus: "approved",
    rating: 4.8,
    casesHandled: 340,
  },
  {
    id: "adv-002",
    fullName: "Adv. Priya Menon",
    email: "priya.menon@legal.in",
    phone: "9811223344",
    courtName: "Supreme Court of India",
    practiceAreas: ["Constitutional", "Human Rights", "Civil"],
    city: "New Delhi",
    state: "Delhi",
    experience: 18,
    bio: "Senior advocate practising at the Supreme Court. Focus on constitutional matters, PILs, and human rights litigation.",
    verificationStatus: "approved",
    rating: 4.9,
    casesHandled: 520,
  },
  {
    id: "adv-003",
    fullName: "Adv. Suresh Iyer",
    email: "suresh.iyer@advocate.com",
    phone: "9922334455",
    courtName: "Bombay High Court",
    practiceAreas: ["Corporate", "Tax", "Civil"],
    city: "Mumbai",
    state: "Maharashtra",
    experience: 15,
    bio: "Corporate and tax lawyer with extensive experience at Bombay High Court and NCLT. Handles company law, insolvency, and commercial disputes.",
    verificationStatus: "approved",
    rating: 4.7,
    casesHandled: 410,
  },
  {
    id: "adv-004",
    fullName: "Adv. Kavita Singh",
    email: "kavita.singh@law.in",
    phone: "9733445566",
    courtName: "Allahabad High Court",
    practiceAreas: ["Family", "Property", "Civil"],
    city: "Lucknow",
    state: "Uttar Pradesh",
    experience: 9,
    bio: "Family and property law specialist. Handles divorce, child custody, inheritance disputes, and property registration cases.",
    verificationStatus: "approved",
    rating: 4.6,
    casesHandled: 220,
  },
  {
    id: "adv-005",
    fullName: "Adv. Arun Nair",
    email: "arun.nair@criminallaw.in",
    phone: "9844556677",
    courtName: "Kerala High Court",
    practiceAreas: ["Criminal", "Civil", "Labour"],
    city: "Kochi",
    state: "Kerala",
    experience: 14,
    bio: "Criminal defence advocate with strong track record at Kerala High Court. Also handles labour disputes and service matters.",
    verificationStatus: "approved",
    rating: 4.5,
    casesHandled: 290,
  },
  {
    id: "adv-006",
    fullName: "Adv. Meera Chatterjee",
    email: "meera.c@legaid.in",
    phone: "9655667788",
    courtName: "Calcutta High Court",
    practiceAreas: ["Consumer", "Cyber", "Criminal"],
    city: "Kolkata",
    state: "West Bengal",
    experience: 7,
    bio: "Young and dynamic advocate specialising in consumer protection, cyber crime, and women's rights cases at Calcutta High Court.",
    verificationStatus: "approved",
    rating: 4.4,
    casesHandled: 130,
  },
  {
    id: "adv-007",
    fullName: "Adv. Harpreet Gill",
    email: "harpreet.gill@pblaw.in",
    phone: "9566778899",
    courtName: "Punjab & Haryana High Court",
    practiceAreas: ["Criminal", "Family", "Property"],
    city: "Chandigarh",
    state: "Punjab",
    experience: 11,
    bio: "Experienced advocate at Punjab & Haryana High Court handling criminal trials, matrimonial disputes, and agricultural property matters.",
    verificationStatus: "approved",
    rating: 4.6,
    casesHandled: 270,
  },
];

// GET /api/advocates?q=&court=&specialization=
router.get("/", (req: Request, res: Response) => {
  const q = ((req.query.q as string) ?? "").toLowerCase();
  const court = ((req.query.court as string) ?? "").toLowerCase();
  const spec = ((req.query.specialization as string) ?? "").toLowerCase();

  let result = advocates;

  if (q) {
    result = result.filter(
      (a) =>
        a.fullName.toLowerCase().includes(q) ||
        a.city.toLowerCase().includes(q) ||
        a.practiceAreas.some((p) => p.toLowerCase().includes(q))
    );
  }
  if (court) {
    result = result.filter((a) => a.courtName.toLowerCase().includes(court));
  }
  if (spec) {
    result = result.filter((a) =>
      a.practiceAreas.some((p) => p.toLowerCase().includes(spec))
    );
  }

  return res.json({ advocates: result, total: result.length });
});

// GET /api/advocates/:id
router.get("/:id", (req: Request, res: Response) => {
  const advocate = advocates.find((a) => a.id === req.params.id);
  if (!advocate) return res.status(404).json({ message: "Advocate not found" });
  return res.json({ advocate });
});

export { router as advocatesRouter };
