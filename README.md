# 🏡 VillaVibe

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Firebase](https://img.shields.io/badge/firebase-%23039BE5.svg?style=for-the-badge&logo=firebase)
![Google Maps](https://img.shields.io/badge/Google_Maps-4285F4?style=for-the-badge&logo=google-maps&logoColor=white)

**VillaVibe** is a comprehensive vacation rental application built with **Flutter**, designed to provide a seamless experience for both Guests and Hosts. It features a unified platform where users can easily switch roles, book stunning villas, manage listings, and communicate in real-time.

---

## Table of Contents
- [App Showcase](#-app-showcase)
- [Key Features](#-key-features)
- [Architecture](#-architecture)
- [Tech Stack](#-tech-stack)
- [Project Structure](#-project-structure)
- [Getting Started](#-getting-started)
- [Roadmap](#-roadmap)

---

## Key Features

The application supports a **Dual-Role Architecture**, allowing a single account to switch between Guest and Host modes seamlessy.

### Guest Features
| Feature | Description |
| :--- | :--- |
| **Dashboard** | Personalized recommendations, search functionality, and trip history tracking. |
| **Advanced Search** | Filter villas by location, price, and amenities. Includes an interactive **Map View**. |
| **Bookings** | Real-time availability checks and secure payments via Midtrans. |
| **Favorites** | Save dream villas to a wishlist for future booking. |
| **Communication** | In-app chat system to inquire with hosts directly. |

### Host Features
| Feature | Description |
| :--- | :--- |
| **Host Dashboard** | View performance stats, manage booking requests, and property overview. |
| **Property Management** | Create (CRUD) and edit villa listings with photos, details, and location. |
| **Calendar** | Manage availability, accept or decline incoming booking requests. |

---

## Architecture

VillaVibe follows a **Feature-First Architecture** combined with **Riverpod** for state management. This ensures separation of concerns, scalability, and testability.

**Data Flow:**
`UI Layer (Widgets)`  `Logic Layer (Providers/Notifiers)`  `Data Layer (Repositories)`  `External Services (Firebase/APIs)`

---

## Tech Stack

| Category | Technology | Purpose |
| :--- | :--- | :--- |
| **Framework** | Flutter (Dart) | Cross-platform mobile development. |
| **State Management** | Riverpod | Reactive state management & dependency injection. |
| **Navigation** | GoRouter | Declarative routing and deep linking. |
| **Backend** | Firebase | Auth, Cloud Firestore, Storage. |
| **Maps** | Google Maps Flutter | Interactive maps & location services. |
| **Payments** | Midtrans | Secure payment gateway integration. |
| **UI Utilities** | flutter_animate, wolt_modal_sheet | Smooth animations & modern modal sheets. |

---

## Project Structure

The project is organized by features to maintain modularity:

```bash
lib/
├── core/            # Shared utilities, constants, themes
├── features/        # Feature-specific code (The heart of the app)
│   ├── auth/        # Login, Signup, User Logic
│   ├── bookings/    # Booking history & logic
│   ├── favorites/   # Wishlist functionality
│   ├── guest/       # Guest dashboard & profile
│   ├── home/        # Main landing screen
│   ├── host/        # Host dashboard & management
│   ├── messages/    # Chat system
│   ├── properties/  # Villa listings & CRUD
│   └── search/      # Search logic & filters
├── main.dart        # Entry point
└── firebase_options.dart