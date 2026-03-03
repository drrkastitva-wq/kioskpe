# Let’s Legal — Data Model V1 (Draft)

## Main Entities

### User
- id
- full_name
- email
- mobile
- role (advocate, clerk, admin, verified_lawyer)
- bar_council_id
- state_bar_council
- enrollment_year
- verification_status (pending, approved, rejected)
- created_at, updated_at

### LawFirm
- id
- name
- address
- city
- state
- contact_email
- contact_phone

### Case
- id
- firm_id
- case_number
- title
- case_type
- court_id
- police_station_id (optional)
- filing_date
- stage
- status
- next_hearing_date
- client_name
- client_contact
- assigned_advocate_id
- notes

### Hearing
- id
- case_id
- hearing_date
- court_hall
- purpose
- outcome_notes
- next_date

### TaskReminder
- id
- case_id
- assigned_user_id
- title
- due_date
- priority
- status
- reminder_channel

### AdvocateDiaryEntry
- id
- user_id
- entry_date
- title
- description
- linked_case_id (optional)

### Court
- id
- name
- level (district, high_court, supreme_court, tribunal)
- state
- district
- address
- latitude
- longitude
- contact_number
- website

### PoliceStation
- id
- name
- state
- district
- address
- latitude
- longitude
- contact_number

### CourtHoliday
- id
- court_id (nullable for national holidays)
- holiday_date
- title
- type

### BarAssociation
- id
- name
- state
- district
- address
- contact_number
- website

### DraftTemplate
- id
- title
- category
- jurisdiction
- content
- created_by
- is_public

## Notes
- Use strict role-based access control (RBAC).
- Store geolocation data for map integration.
- Maintain audit logs for sensitive actions.
