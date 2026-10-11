# Task Management Flutter App

A modern, offline-first Flutter mobile application built for agile software engineering teams to manage tasks, monitor Service Level Agreements (SLAs), track team workloads, and prevent deadline breaches through priority-weighted early warning windows.

Developed as a collaborative project by **Group 1** for the **Mobile Application Development** module.

---

## Table of Contents
- [About the Application](#about-the-application)
- [Key Features](#key-features)
- [SLA Calculation Engine](#sla-calculation-engine)
- [Architecture & Tech Stack](#architecture--tech-stack)
- [Project Directory Structure](#project-directory-structure)
- [Prerequisites](#prerequisites)
- [Setup & Installation](#setup--installation)
- [How to Run](#how-to-run)
- [Seed Data & Demo Reset](#seed-data--demo-reset)
- [Team Roles & Contributions](#team-roles--contributions)

---

## About the Application

**Task Management App** is designed to solve a common problem in software projects: missed deadlines and unmonitored task degradation. Unlike standard to-do applications, this app continuously assesses task deadlines against an intelligent **Priority-Weighted SLA Engine**, categorizing work items into four clear states: **On Track**, **At Risk**, **Overdue**, and **Completed**.

The app operates completely on-device without remote backend requirements, ensuring instant responsiveness, full offline capabilities, and persistent local storage across sessions.

---

## Key Features

### 1. Executive Dashboard (`HomeScreen`)
- **Visual Health Ring:** Custom canvas-rendered circular SLA health ring showing real-time compliance rate percentage and distribution.
- **Urgent Attention Triage:** Surfaces overdue and at-risk tasks at the top of the viewport for immediate action.
- **Upcoming Deadlines:** Quick view of approaching deliverables with assigned team members.
- **Direct Navigation:** Jump straight to project insights, full task list, or member profiles.

### 2. Task Management (`TaskListScreen`, `TaskDetailsScreen`, `TaskFormScreen`)
- **Full Task Lifecycle:** Create, edit, complete, and delete tasks.
- **Multi-Filter Support:** Search tasks by title and filter by SLA Status (`On Track`, `At Risk`, `Overdue`, `Completed`) and Priority (`High`, `Medium`, `Low`).
- **Validated Input Form:** Validation for title, category, assignee, notes, and strict date checks (preventing past due dates for new items).
- **Activity History:** Tracks the last action taken on each task (e.g., status changes, reassignments).

### 3. Team Management (`TeamMembersScreen`)
- **Real-Time Roster Search:** Search members by name, role, or email.
- **Dynamic Initials Avatars:** Automatically extracts uppercase initials (e.g., *"Sarah Jenkins"* $\rightarrow$ *"SJ"*) paired with customizable avatar color themes.
- **Live Workload Badges:** Displays assigned task counts and urgent warning indicators directly on each card.
- **Validated Bottom Sheet Form:** Add and edit member profiles with RFC-compliant email regex validation.
- **Safe Deletion Safety Check:** Referential integrity check preventing accidental deletion of team members who have active assigned tasks.

### 4. SLA Analytics & Insights (`StatisticsScreen`)
- **Summary Metric Cards:** Total Tasks, SLA Compliance %, and Overdue count.
- **Custom Pure Flutter Bar Chart:** Vertical bar chart built with `AnimatedContainer` and proportional height scaling comparing status counts.
- **Priority & Team Workload Breakdown:** Horizontal progress indicators illustrating task distribution across priority levels and team members.
- **SLA Rules Reference Card:** Dark-themed reference guide outlining deadline thresholds.

### 5. Profile & Session Switcher (`ProfileScreen` & `SignInScreen`)
- **Active User Session:** Switch active team members on the fly to see personalized SLA metrics.
- **Personal Metrics Grid:** Dedicated count tiles for On Track, At Risk, Overdue, and Completed tasks assigned to the active user.
- **One-Tap Demo Reset:** Restore the app to its standard 8-task seed state anytime during live demonstrations.

### 6. Design System & Theme Engine
- **Material 3 Foundation:** Clean, cohesive typography, card elevations, and rounded layouts.
- **Dynamic Light/Dark Mode:** Full support for system, light, and dark modes with contrast-tuned semantic tokens (WCAG AA compliant).
- **Semantic SLA Colors:**
  - 🟢 **On Track:** Emerald (`#10B981`)
  - 🟡 **At Risk:** Amber (`#F59E0B`)
  - 🔴 **Overdue:** Rose (`#EF4444`)
  - ⚪ **Completed:** Slate (`#64748B`)

---

## SLA Calculation Engine

At the core of the app is `SlaCalculator`, which evaluates four sequential rules to determine task urgency:

```
                                  [ Evaluate Task ]
                                          │
                                          ▼
                            Is task.status == completed?
                                   ├── YES ──> [ SlaStatus.completed ]
                                   │
                                   └── NO
                                       │
                                       ▼
                              Is now > task.dueDate?
                                   ├── YES ──> [ SlaStatus.overdue ]
                                   │
                                   └── NO
                                       │
                                       ▼
                   Calculate remaining hours = (dueDate - now) in hours
                                       │
       ┌───────────────────────────────┼───────────────────────────────┐
       ▼                               ▼                               ▼
[ High Priority ]             [ Medium Priority ]             [ Low Priority ]
remaining <= 72h?             remaining <= 48h?               remaining <= 24h?
 ├── YES -> [ At Risk ]        ├── YES -> [ At Risk ]          ├── YES -> [ At Risk ]
 └── NO  -> [ On Track ]       └── NO  -> [ On Track ]         └── NO  -> [ On Track ]
```

### SLA Compliance Rate Formula
$$\text{Compliance Rate} = \left( \frac{\text{Total Tasks} - \text{Overdue Tasks}}{\text{Total Tasks}} \right) \times 100$$

---

## Architecture & Tech Stack

- **Framework:** Flutter (Mobile target: Android & iOS)
- **Language:** Dart 3.x
- **State Management:** Native Flutter `StatefulWidget` and `setState()` (zero third-party state libraries)
- **Persistence:** `shared_preferences` with `dart:convert` JSON serialization
- **Key Dependencies:**
  - `shared_preferences: ^2.2.2` — Key-value local disk storage
  - `uuid: ^4.5.1` — Unique ID generation for new tasks and members
  - `intl: ^0.20.2` — Date and time formatting
  - `cupertino_icons: ^1.0.8` — Icon set support

---

## Project Directory Structure

```
lib/
├── app/
│   ├── app_shell.dart              # Persistent 4-tab shell with IndexedStack & PopScope
│   ├── task_screens.dart           # Route helpers and cross-tab sync bridges
│   └── theme.dart                  # Material 3 light/dark themes and SLA color tokens
├── models/
│   ├── task.dart                   # Task domain model (Member 2 schema)
│   ├── task_enums.dart             # TaskPriority, TaskStatus, SlaStatus enums
│   ├── task_model.dart             # Shared Task domain model (Member 3 schema)
│   └── team_member.dart            # TeamMember model with computed initials getter
├── screens/
│   ├── home_screen.dart            # Dashboard, HealthPanel, urgent attention list
│   ├── profile_screen.dart         # Active profile, personal SLA metrics & data reset
│   ├── sign_in_screen.dart         # Profile selection authentication gate
│   ├── statistics_screen.dart      # Full SLA bar chart, workload & priority metrics
│   ├── task_details_screen.dart    # Detailed task view with status transition actions
│   ├── task_form_screen.dart       # Validated task creation and edit form
│   ├── task_list_screen.dart       # Task roster with search, SLA & priority filters
│   └── team_members_screen.dart    # Team roster, bottom sheet form & safe deletion
├── services/
│   ├── local_storage_service.dart  # SharedPreferences CRUD & 8-task seed generator
│   ├── sample_data.dart            # Standard sample task templates
│   ├── sample_data_bridge.dart     # Auto-assigns sample tasks across team members
│   ├── sample_team_members.dart    # In-memory teammate fallback list
│   ├── sla_calculator.dart         # Priority-weighted SLA calculation engine
│   └── task_storage_service.dart   # Task CRUD adapter wrapping LocalStorageService
├── utils/
│   ├── due_labels.dart             # Human-readable relative date formatting
│   ├── sla_calculator.dart         # Bridge adapter for SlaCalculator
│   └── validators.dart             # Common input validation utilities
└── widgets/
    ├── health_panel.dart           # Custom canvas-painted circular SLA health ring
    ├── member_avatar.dart          # Circular avatar with initials and member color
    ├── priority_label.dart         # Priority badge chip
    ├── sla_chip.dart               # SLA status pill badge
    ├── sla_status_badge.dart       # SLA status chip with background styling
    ├── task_card.dart              # Standard task list card
    ├── theme_toggle_button.dart    # One-tap Light/Dark theme toggle button
    └── urgency_task_card.dart      # Highlighted attention card for dashboard
```

---

## Prerequisites

Before running the application, ensure you have the following installed on your machine:
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (`v3.13.2` or higher)
- [Dart SDK](https://dart.dev/get-dart) (`v3.1.0` or higher)
- Android Studio / VS Code with Flutter and Dart extensions
- An active Android Emulator, iOS Simulator, or connected physical mobile device

Verify your environment by running:
```bash
flutter doctor
```

---

## Setup & Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/Kiguru-Alu/Formative_Assignment_Group1.git
   cd Formative_Assignment_Group1
   ```

2. **Install project dependencies:**
   ```bash
   flutter pub get
   ```

3. **Verify code quality:**
   ```bash
   flutter analyze
   ```

---

## How to Run

1. **List available devices:**
   ```bash
   flutter devices
   ```

2. **Launch the app:**
   ```bash
   flutter run
   ```

   *To target a specific device or emulator:*
   ```bash
   flutter run -d <device-id>
   ```

3. **In-app Navigation Flow:**
   - On initial launch, you will see the **Sign In Screen**. Select any team member profile (e.g., *Marcus Chen* or *Sarah Jenkins*) and tap **Continue as...**.
   - You will enter the **App Shell**, featuring 4 persistent tabs:
     - **Home:** Review SLA health compliance, urgent attention items, and upcoming deadlines.
     - **Tasks:** Filter tasks, search by title, tap to view details, or tap `+` to create tasks.
     - **Team:** Search team members, tap `+` to add a new member, or use the card menu to edit or change the active user.
     - **Profile:** Inspect personal metrics, switch active profiles, view full SLA statistics, or reset demo data.

---

## Seed Data & Demo Reset

When launched for the first time, `LocalStorageService` auto-seeds **5 team members** and **8 realistic tasks** with dynamic relative dates guaranteeing:
- **2 On Track Tasks**
- **2 At Risk Tasks**
- **2 Overdue Tasks**
- **2 Completed Tasks**

If you add, edit, or delete items during a demonstration, you can instantly restore this exact baseline state:
1. Navigate to the **Profile** tab.
2. Scroll to the bottom and tap **Reset Demo Data**.
3. Confirm the dialog to re-populate the standard 8 demo tasks.

---

## Team Roles & Contributions

This application was engineered by **Group 1**, with responsibilities divided across three core roles:

| Role | Developer | Key Responsibilities & Deliverables |
| :--- | :--- | :--- |
| **Member 1** | Dashboard & Shell Lead | • Executive Dashboard (`HomeScreen`)<br>• Custom Canvas Health Ring (`HealthPanel`)<br>• App Shell (`AppShell` with `IndexedStack`)<br>• Theme Controller (`AppTheme` light/dark modes)<br>• Sign-In Profile Gate (`SignInScreen`) |
| **Member 2** | Task Management Lead | • Task List Screen (`TaskListScreen` with filters)<br>• Task Details Screen (`TaskDetailsScreen`)<br>• Task Form Screen (`TaskFormScreen` with validators)<br>• Task Widgets (`TaskCard`, `SlaChip`)<br>• Task Storage Bridge (`TaskStorageService`) |
| **Member 3** | Data, SLA & Supporting Features | • Core Data Enums (`TaskPriority`, `TaskStatus`, `SlaStatus`)<br>• Domain Models (`Task`, `TeamMember` with computed initials)<br>• SLA Calculation Engine (`SlaCalculator` with 4 rules)<br>• Local Storage Service (`LocalStorageService` with seed generator)<br>• Team Members Screen (`TeamMembersScreen` with search & safe deletion)<br>• Statistics Screen (`StatisticsScreen` with custom vertical bar chart)<br>• Profile Screen (`ProfileScreen` with session switcher & reset) |

---

## License

This project is submitted as an academic assignment for ALU Mobile Application Development. All rights reserved by Group 1.
