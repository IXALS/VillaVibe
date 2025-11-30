# Host Dashboard & Onboarding Proposal

## Overview
This proposal outlines the architecture and user experience for the new "Host Mode" in VillaVibe. The goal is to create a seamless transition for users to become hosts, with a friendly, guided onboarding process similar to Airbnb, and a powerful yet simple dashboard for managing listings.

## 1. Architecture: Guest vs. Host Mode
Instead of mixing host features into the guest app, we recommend a **Mode Switching** architecture.
- **Global State**: A `isHostMode` provider in Riverpod.
- **Switching**: 
    - In the Profile tab, a "Switch to Hosting" button.
    - If the user is already a host (`isHost: true`), it flips the UI to the Host Dashboard.
    - If the user is **not** a host, it launches the **Host Onboarding Flow**.
- **Navigation**: The bottom navigation bar changes completely when in Host Mode (e.g., Home, Calendar, Listings, Inbox, Menu).

## 2. The "Become a Host" Onboarding (Airbnb Style)
For first-time hosts, the experience should be less like "filling out a form" and more like "telling a story about your home."

### Phase 1: The Intro
- **Welcome Screen**: "Turn your space into a VillaVibe."
- **Value Prop**: Simple graphics showing "Earn money," "Host with confidence."
- **Call to Action**: "Vibe Setup" (Start).

### Phase 2: The Steps (Progressive Disclosure)
Break the form into 3 distinct sections with a progress bar.

#### Step 1: The Basics
- **Property Type**: Grid of icons (House, Apartment, Villa, Cabin).
- **Privacy**: Entire place, Private room, Shared room.
- **Location**: Map integration (Google Maps) to pin the exact location.
- **Floor Plan**: Counter widgets for Guests, Bedrooms, Beds, Bathrooms.

#### Step 2: The Vibe (Details)
- **Amenities**: Selectable chips with icons (Wifi, Pool, Hot tub, BBQ, Parking).
- **Photos**: A drag-and-drop style photo uploader. *Crucial*: Allow users to reorder photos.
- **Title & Description**: AI-assisted text generation? (e.g., "Write a description for a modern villa in Bali").

#### Step 3: The Finish Line
- **Pricing**: Price per night slider. Show "Estimated earnings" based on similar listings.
- **Availability**: "Instant Book" vs "Request to Book".
- **Review**: A preview card showing how their listing will look to guests.
- **Publish**: Celebration animation (Confetti!) -> Redirect to Host Dashboard.

## 3. Host Dashboard Structure
Once onboarded, the user lands on the Host Dashboard.

### Tab 1: Today (Home)
*The Command Center*
- **Greeting**: "Good morning, [Name]."
- **Action Cards**: "Confirm request from Sarah," "Checkout tomorrow: John."
- **Status**: "You are all caught up!" (Empty state).
- **Quick Stats**: "Earnings in November: $1,200".

### Tab 2: Calendar
*Availability Management*
- **View**: Vertical scrollable month view.
- **Actions**: Tap a date range to:
    - Block/Unblock dates.
    - Set custom prices for holidays.

### Tab 3: Listings
*Property Management*
- List of user's properties.
- **Edit Mode**: Update photos, amenities, title.
- **Status**: Active / Snoozed / In Progress.

### Tab 4: Inbox
*Communication*
- Chat list with guests.
- Filters: "Unread," "Pending Requests," "Upcoming."

### Tab 5: Menu
*Account & Settings*
- **Switch to Guest Mode** (Primary action).
- Payout methods.
- Co-host management.

## 4. Technical Recommendations
- **State Management**: Use `flutter_riverpod` to manage the multi-step onboarding form state (`OnboardingState`).
- **Persistence**: Save drafts locally (Hive or SharedPreferences) so users can exit and resume onboarding later.
- **UI Components**:
    - `AnimatedSwitcher` for smooth step transitions.
    - `Hero` animations for previewing the listing.
    - `Slivers` for the dashboard scrolling effects.

## 5. Next Steps
1.  **Database Update**: Ensure `AppUser` in Firestore can store `isHost` and a reference to their `listings`.
2.  **Create Screens**:
    - `HostOnboardingScreen` (PageView based).
    - `HostMainScreen` (BottomNav based).
3.  **Logic**: Implement the "Switch Mode" logic in the main `App` widget or router.
