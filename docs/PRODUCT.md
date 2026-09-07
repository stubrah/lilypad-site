# Lilypad PMS

## Product Vision

Lilypad is property-management software designed for recovery and sober-living housing.

The goal is to connect the entire lifecycle of a bed:

**Vacancy → Application → Approval → Bed Assignment → Payment → Physical Access → Occupancy → Discharge → Vacancy**

Lilypad should reduce the number of separate systems, spreadsheets, payment apps, websites, keys, and manual processes an operator needs to manage.

---

## Core Product Flow

**Property → Room → Bed → Resident → Occupancy → Door Access**

A resident's occupancy assignment should become the source of truth for both the PMS and physical access.

Example:

**Oak House → Room 3 → Bed B → John Smith**

Lilypad determines that John should have access to:

* Oak House front door
* Room 3 bedroom door
* Approved common areas

When his occupancy changes, his access changes automatically.

---

## Primary Differentiator

### Occupancy-Driven Access Control

Lilypad should integrate with BLE/NFC access-control systems.

Core behavior:

* Assign resident to a bed → grant appropriate access
* Move resident to another room → revoke old bedroom access and grant new bedroom access
* Discharge resident → revoke access
* Staff credentials → managed separately from resident occupancy
* Support phone credentials
* Support NFC card/fob fallback
* Maintain an audit history of credential and access changes

The operator should not have to manually manage keys every time a resident moves in, transfers rooms, or leaves.

---

## Property Structure

### Property / House

A physical recovery residence.

Examples:

* Oak House
* Maple House
* Lilypad House

### Room

A bedroom within a property.

Example:

* Room 1
* Room 2
* Room 3

### Bed

The individual rentable/assignable unit.

Example:

* Room 3 / Bed A
* Room 3 / Bed B

Possible bed states:

* Vacant
* Held
* Pending move-in
* Occupied
* Notice given
* Maintenance
* Blocked

### Resident

A person currently living in or applying to live in a property.

### Occupancy

Historical relationship between a resident and a bed.

Occupancy should be stored separately rather than simply placing a resident ID on a bed.

Example:

John Smith
Oak House / Room 2 / Bed A
August 1 → September 6

Transferred to:

Oak House / Room 4 / Bed B
September 6 → Present

This allows Lilypad to preserve move-in, transfer, discharge, billing, vacancy, and access history.

---

## Door and Access Model

### Door

A physical controlled opening.

Examples:

* Oak House front entrance
* Room 1
* Room 2
* Laundry room
* Office
* Medication room

Doors should be mapped to properties and rooms.

### Credential

A method used by a resident or staff member to authenticate.

Possible credential types:

* BLE mobile credential
* NFC mobile credential
* NFC card
* NFC fob

### Access Assignment

Lilypad determines which credentials can open which doors.

Example:

John Smith

Allowed:

* Oak House front entrance
* Room 3
* Laundry room

Denied:

* Other bedrooms
* Office
* Medication room

---

## Vacancy Automation

Vacancy should be driven by the actual occupancy database.

Example workflow:

1. Resident is discharged.
2. Credential is revoked.
3. Occupancy record is closed.
4. Bed becomes vacant.
5. Property vacancy count changes.
6. Public website updates automatically.
7. Bed becomes available to applicants/referral sources.
8. New applicant is approved.
9. Bed is held.
10. Agreements/payment requirements are completed.
11. Applicant becomes a resident.
12. Occupancy begins.
13. Mobile credential is provisioned.
14. Bed becomes occupied.

The goal is to eliminate duplicate data entry.

---

## MVP

The first usable version does **not** need every recovery-housing feature.

### Phase 1

Build:

* Properties
* Rooms
* Beds
* Residents
* Occupancy history
* Bed status
* Doors
* Door-to-room/property mapping
* Credentials
* Access assignments
* Basic dashboard

### Phase 2

Add:

* Applications
* Public vacancy page
* Vacancy synchronization
* Resident move-in workflow
* Resident discharge workflow
* Access-control API integration

### Phase 3

Add:

* Weekly/monthly resident charges
* Payments
* Autopay
* Balances
* Receipts
* Past-due reporting
* Agreements/documents
* E-signatures

### Later

Possible future features:

* Incident reports
* Drug-test records
* Pass requests
* Chores
* Maintenance
* Referral-source tracking
* Occupancy analytics
* Revenue reporting
* Marketplace of available recovery beds
* Multi-operator vacancy network

---

## Initial Dashboard Concept

Example:

Oak House — 14 / 16 occupied

Room 1

* John — Bed A — Paid — Key Active
* Mike — Bed B — $75 Due — Key Active

Room 2

* Alex — Bed A — Paid — Key Active
* VACANT — Bed B — Available

Summary:

* Open Beds: 2
* Applications: 3
* Past Due: $425
* Access Issues: 1

---

## AZ-104 Learning Goals

Lilypad should also function as a practical Azure administration lab.

We should deliberately use the project to practice:

### Identity and Governance

* Microsoft Entra ID
* Azure RBAC
* Managed identities
* Resource groups
* Tags
* Azure Policy
* Resource locks

### Storage

* Azure Storage
* Blob containers
* Access controls
* Redundancy
* Lifecycle management

### Compute

* Azure Functions
* App Service / Static Web Apps
* Deployment and configuration

### Networking

* VNets
* Subnets
* NSGs
* Private endpoints
* DNS
* Service connectivity

### Data

* Azure SQL
* Backup and recovery
* Network access
* Identity-based authentication

### Security

* Azure Key Vault
* Secrets
* API credentials
* Managed identities

### Monitoring

* Azure Monitor
* Log Analytics
* Application Insights
* Alerts

---

## Example Azure Access-Control Workflow

Resident assigned to bed
↓
Occupancy record updated in Azure SQL
↓
Application/function processes change
↓
Lilypad determines required doors
↓
Managed identity retrieves required secrets from Key Vault
↓
Access-control API is called
↓
Credential/access rights are updated
↓
Result is written to audit log
↓
Azure Monitor detects and alerts on failures

---

## Current Product Hypothesis

The strongest Lilypad selling point may be:

**Automated physical access tied directly to recovery-house occupancy.**

The product hypothesis to validate with operators is:

> If assigning a resident to a bed automatically gives that resident the correct house and bedroom access — and discharging them automatically removes it — recovery-house operators will consider that valuable enough to influence their PMS purchasing decision.

We should validate this with real operators before investing heavily in the hardware integration.

---

## First Milestone

Build one complete vertical slice:

**Create Property → Create Room → Create Bed → Create Resident → Assign Resident to Bed → Generate Required Door Access**

The first version does not need to communicate with a real lock.

We can simulate the access-control provider and prove that the Lilypad data model and automation work correctly.

Once that works, replace the simulated provider with a real access-control API integration.
