# Flutter Mobile App (Dairy Cattle Management MVP Contract)

## 🎯 Purpose of the App

This mobile app is used **in the cowshed and in the field**.

The goal is:

- Fast cow lookup
- Fast milk logging (twice daily)
- Fast health & breeding recording
- Work fully offline
- Sync silently when internet is available

This is **not** a feature-rich app. It is a **daily farm tool**.

---

## 🧱 Core Architectural Principles

1. Offline-first (SQLite is the source of truth on device)
2. Repository pattern (UI never talks to API directly)
3. GetX for state, routing, and controllers
4. One responsibility per screen
5. Minimal typing, large inputs, fast actions
6. Models must match API DTOs exactly

---

## 🗺️ App Navigation (Bottom Nav Only)

1. Home
2. Cows
3. Milk Entry
4. Sales
5. Dashboard

No deep or complex navigation.

---

## 🏠 Home Screen (Today Screen)

Show only:

- Cows due for vaccination / deworming
- Cows due for pregnancy check
- Cows due for calving
- Cows missing milk log today
- Today’s total milk

All data is queried from SQLite.

---

## 🐄 Cows Module

### Cows List

- Search by tag
- Status indicators (pregnant, in milk, recently treated)

### Add Cow

- Simple form

### Cow Profile (Tabs)

Tabs:

1. Overview
2. Milk
3. Health
4. Breeding
5. Expenses

This screen replaces farm notebooks.

---

## 🥛 Milk Entry Module (High Priority UX)

- List of cows
- Enter morning/evening litres quickly
- Save without opening cow profile

Used during milking. Must be extremely fast.

---

## ❤️ Health Module

From cow profile:

- Log treatment
- Log vaccination
- Log deworming
- View history

---

## 🧬 Breeding Module

From cow profile:

- Log heat
- Log service
- Pregnancy check
- Calving record

---

## 💸 Expenses Module

From cow profile:

- Add expense
- View expense history
- Show total cost for cow

---

## 🥛 Milk Sales Module

- Add milk sale
- View sales history

---

## 📊 Dashboard Module

Show simple stats:

- Total cows
- Pregnant cows
- Cows in milk
- Today’s milk
- Monthly income
- Monthly expenses
- Profit

---

## 💾 Local Database (SQLite Schema Rule)

Every table must include:

- `local_id` (uuid)
- `server_id` (nullable)
- `is_synced` (0/1)

Tables:

- cows
- health_records
- breeding_records
- milk_logs (unique cow + date)
- expense_logs
- milk_sales

Schema must mirror the API.

---

## 🔄 Sync Engine Rules

1. UI writes to SQLite only
2. Records saved with `is_synced = 0`
3. Background sync sends unsynced records to API
4. On success: update `server_id`, set `is_synced = 1`
5. Periodically pull latest server data and UPSERT into SQLite

Sync runs:

- On app start
- After every save
- Periodically in background

---

## 🧠 Repository Pattern (Mandatory)

Controller → Repository → SQLite
→ API (via Sync Service)

Controllers never call API directly.

---

## 📁 Folder Structure

lib/
├─ core/
│ ├─ database/
│ ├─ network/
│ ├─ sync/
│ └─ utils/
│
├─ modules/
│ ├─ home/
│ ├─ cows/
│ ├─ cow_profile/
│ ├─ milk/
│ ├─ health/
│ ├─ breeding/
│ ├─ expenses/
│ ├─ sales/
│ └─ dashboard/
│
├─ routes/
└─ main.dart

Each module contains:

view/
controller/
repository/
models/

---

## 🎨 UI/UX Rules

- Large inputs for litres
- Use dropdowns instead of typing
- Date pickers everywhere
- Everything reachable within 2 taps
- No complex settings

---

## 📦 Required Packages

- get (state, routes, DI)
- sqflite (SQLite)
- path_provider (DB path)
- uuid (local IDs)
- dio (API client)
- connectivity_plus (internet detection)
- workmanager (background sync)
- intl (dates)
- flutter_form_builder + validators (forms)
- fl_chart (milk history)
- json_serializable + build_runner (models)
- logger (debugging)

---

## 🚫 What NOT to Build

Do NOT add:

- Roles/permissions
- Settings complexity
- Feed tracking
- Staff management
- Paddocks
- Fancy analytics

---

## ✅ Definition of MVP Done

The app is MVP-complete when you can:

1. Register cows
2. Log milk quickly
3. Log health events
4. Log breeding events
5. Log expenses
6. Log milk sales
7. See today’s alerts and dashboard
8. Work fully offline and sync later

Stop building when these work perfectly.

---

## Final Rules

If a feature does not help during milking, treatment, or breeding checks — do not build it.


Always commit any complete changes before moving to the next module. This document is your contract. Follow it closely.

While commiting. do not add co-author statement. use one line sentences for commit messages. For example: "Add cows table with basic fields".
