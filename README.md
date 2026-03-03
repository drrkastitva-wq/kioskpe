# Let’s Legal

A legal operations platform for advocates in India.

## Vision
Build a daily-use platform for law firms and independent advocates to manage cases, reminders, court workflows, legal references, and practice operations in one secure system.

## Core User Types
- Advocate / Law Firm Member
- Clerk / Assistant (role-based access)
- Verified Lawyer (public registration with Bar Council ID verification)
- Admin

## Problem Areas Covered
- Case lifecycle management
- Case reminders and diary management
- New case enrollment and client intake
- Bare Acts and legal reference library
- India courts and police station directory with location + contact
- Court calendar and holidays
- Bar association directory
- Drafted applications/templates for daily legal drafting

## Suggested MVP Modules (Phase 1)
1. Authentication + role-based access
2. Advocate profile with Bar Council ID verification workflow
3. Case management (create, update, track status)
4. Tasks, reminders, and advocate diary
5. Courts + police station directory (search/filter + map link)
6. Court calendar + holiday calendar
7. Basic document template repository

## Daily-Use Features Advocates Need (Recommended Additions)
- Cause list and hearing schedule tracker
- Limitation/deadline calculator (filing deadlines, appeal limitation)
- Client meeting log and call notes
- Fee tracker + outstanding payment reminders
- Time tracking per case/activity
- Evidence/checklist tracker per matter type
- Court filing checklist by case type
- One-click generate routine drafts from templates
- Secure document vault with tagging and quick retrieval
- Conflict check for new client/case intake
- Team task assignment and clerk follow-ups
- Next-date auto reminder with SMS/Email/WhatsApp integration (later phase)
- Judgment/note bookmarking for quick legal research recall

## Verification Approach for Public Registrations
- Registration requires:
  - Full name
  - Mobile + email OTP verification
  - Bar Council enrollment number
  - State Bar Council
  - Enrollment year
- Admin/automated verification queue before full access to restricted modules.

## Immediate Next Steps
- Finalize module priority and user roles
- Define database schema
- Build MVP Flutter app scaffold and authentication
- Integrate map/location APIs for court/police directory

## Project Folder Plan
- `docs/` product planning and architecture docs
- `apps/mobile/` Flutter app
- `apps/backend/` Node.js API (Express + TypeScript)
- `packages/` shared types/components (later)
