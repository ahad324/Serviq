# 🔄 Application Navigation & Data Flow Blueprint

## 📌 Document Metadata
* **Document Version**: 1.1.0
* **Date**: May 2026
* **Status**: Complete / Production-Ready

---

## 🗺️ High-Level Route Structure (GoRouter)

Serviq manages navigation through a centralized [GoRouter](file:///g:/Ahad/Mobile_Application_Dev/serviq/lib/core/router/app_router.dart) configurations that separates immersive, focused workflows from core hub features:

```text
/ (SplashScreen) ────► /auth (AuthScreen) 
                             │
                             ▼
┌──────────────────────────────────────────────────────────────┐
│                    SHELL ROUTE WITH BOTTOM NAV               │
│  /home                 /tracking       /booking-history      │
│  (NLP Input Screen) ──►(Live Tracker)◄─(History Logs)        │
└────────┬─────────────────────────────────────────────────────┘
         │ (NLP Query Triggered)
         ▼
/ai-understanding (Focused loading watchdog)
         │
         ▼
/providers (Matching list with match explanations)
         │
         ▼
/pricing-breakdown (Dynamic billing overview)
         │
         ▼
/booking-confirmation (Success summary) ──► Go back to /tracking
```

---

## 🛰️ Screen-by-Screen Navigation & Data Flow

### 1. Initial Launch: Splash Screen (`/`)
* **State / View**: [SplashScreen](file:///g:/Ahad/Mobile_Application_Dev/serviq/lib/features/splash/presentation/screens/splash_screen.dart) displays an animated logo and a perceived performance progress bar.
* **Transition Trigger**: On completed mock loading checks. Redirects to `/auth` if the session is null, or directly to `/home` if authenticated.

### 2. Access Control: Authentication Screen (`/auth`)
* **State / View**: [AuthScreen](file:///g:/Ahad/Mobile_Application_Dev/serviq/lib/features/auth/presentation/screens/auth_screen.dart) handles custom login/signup inputs.
* **Technical Action**: Interacts with [authRepositoryProvider](file:///g:/Ahad/Mobile_Application_Dev/serviq/lib/features/auth/data/repositories/auth_repository.dart) to check Supabase accounts. During signups, Geolocator fetches user GPS coordinates to save into DB profiles.
* **Transition Trigger**: On successful validation. Triggers [SessionNotifier](file:///g:/Ahad/Mobile_Application_Dev/serviq/lib/features/auth/presentation/providers/session_provider.dart#L5) updates and moves to `/home`.

### 3. Core Prompts Hub: NLP Input Screen (`/home` *Inside ShellRoute*)
* **State / View**: [InputScreen](file:///g:/Ahad/Mobile_Application_Dev/serviq/lib/features/input/presentation/screens/input_screen.dart) showcases a conversational text field and active bottom navigation tabs.
* **Technical Action**: Coordinates are resolved in the background. On CTA click, triggers [ServiceBookingNotifier.submitQuery](file:///g:/Ahad/Mobile_Application_Dev/serviq/lib/features/input/presentation/providers/input_provider.dart#L30) setting the Riverpod provider to `AsyncValue.loading()`.
* **Transition Trigger**: Calls `context.push('/ai-understanding')` immediately upon query submission.

### 4. Perceived Performance: AI Understanding Screen (`/ai-understanding`)
* **State / View**: [AIUnderstandingScreen](file:///g:/Ahad/Mobile_Application_Dev/serviq/lib/features/matching/presentation/screens/ai_understanding_screen.dart) takes up the entire screen view.
* **Technical Action**: Displays active agent actions. A background listener watches [serviceBookingProvider](file:///g:/Ahad/Mobile_Application_Dev/serviq/lib/features/input/presentation/providers/input_provider.dart#L7) state transitions.
* **Transition Trigger**: When the provider transitions from `loading` to `data` (meaning n8n has completed the processing), runs a 60fps progress bar completion animation and routes to `/providers`. If the API fails or a 60-second watchdog completes, prompts returning to `/home`.

### 5. Recommendation Index: Provider List Screen (`/providers`)
* **State / View**: [ProviderListScreen](file:///g:/Ahad/Mobile_Application_Dev/serviq/lib/features/matching/presentation/screens/provider_list_screen.dart) presents high-fidelity local expert options.
* **Technical Action**: Pulls matching parameters directly from `serviceBookingProvider.value.providers`. Renders star ratings, reviews, and the customized AI reasoning context.
* **Transition Trigger**: Choosing a professional calls [selectedProviderProvider.notifier.setProvider](file:///g:/Ahad/Mobile_Application_Dev/serviq/lib/features/input/presentation/providers/input_provider.dart#L15) and pushes to `/pricing-breakdown`.

### 6. Billing Review: Pricing Breakdown Screen (`/pricing-breakdown`)
* **State / View**: [PricingBreakdownScreen](file:///g:/Ahad/Mobile_Application_Dev/serviq/lib/features/booking/presentation/screens/pricing_breakdown_screen.dart) displays line-item billing sheets.
* **Technical Action**: Dynamically computes invoice metrics (Base + Urgency + Distance + Platform Service Fee) matching the selected provider.
* **Transition Trigger**: Clicking the checkout button inserts a new transaction log inside the Supabase `Bookings` table and goes to `/booking-confirmation`.

### 7. Success Banner: Booking Confirmation Screen (`/booking-confirmation`)
* **State / View**: [BookingConfirmationScreen](file:///g:/Ahad/Mobile_Application_Dev/serviq/lib/features/booking/presentation/screens/booking_confirmation_screen.dart) displays a transaction success panel.
* **Transition Trigger**: Pressing "Track Service" takes the user directly to `/tracking`, passing the newly persisted booking record to initiate tracking.

### 8. Real-time Progress: Tracking Screen (`/tracking` *Inside ShellRoute*)
* **State / View**: [TrackingScreen](file:///g:/Ahad/Mobile_Application_Dev/serviq/lib/features/tracking/presentation/screens/tracking_screen.dart) displays an interactive stepper list.
* **Technical Action**: Employs [trackingProvider](file:///g:/Ahad/Mobile_Application_Dev/serviq/lib/features/tracking/presentation/providers/tracking_provider.dart) to simulate a five-stage provider progress journey over a 30-second timeline.
* **Transition Trigger**: Stepper completion triggers a floating [FeedbackScreen](file:///g:/Ahad/Mobile_Application_Dev/serviq/lib/features/tracking/presentation/screens/feedback_screen.dart) overlay. Submitting ratings resolves the flow, redirecting users back to `/home`.
