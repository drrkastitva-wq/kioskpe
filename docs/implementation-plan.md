# Let’s Legal — Implementation Plan

## Product Name
**Let’s Legal**

## Recommended Build Approach
- Start with mobile-first MVP using Flutter
- Multi-tenant model for law firms
- Add public lawyer registration with controlled verification access

## Suggested Tech Stack
- Frontend: Flutter (Dart)
- Backend: Node.js (Express + TypeScript)
- Database: PostgreSQL
- ORM: Prisma
- Auth: Email/Phone OTP + role-based access
- Notifications: Email/SMS/WhatsApp (phase-wise)
- Maps: Google Maps or Mapbox for court/police location

## MVP Sprint Sequence
1. Auth, roles, and profile verification fields
2. Case + hearing + reminders + diary
3. Court/police/bar association directories
4. Court holiday calendar
5. Template/document repository
6. Admin panel for lawyer verification

## Risks to Address Early
- Verification workflow quality for Bar Council IDs
- Data quality for India-wide court/police directory
- Sensitive client data protection and access logs
- Reminders reliability and delivery tracking

## First Build Milestone (2 weeks)
- Working login
- Create/edit case
- Add hearings + reminders
- Basic advocate diary
- Dashboard with next 7 days agenda
