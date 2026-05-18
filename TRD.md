# 🧠 Technical Requirements Document (TRD)

## 📌 Technical Metadata
* **Document Version**: 1.1.0
* **Date**: May 2026
* **Status**: Production-Ready
* **Target Platforms**: Android (Mobile APK) & Web (GitHub Pages Deployment)

---

## 🧩 High-Level System Architecture

Serviq is built upon a modern, distributed architecture separating conversational client interfaces from cognitive workflow processors and database repositories:

```text
┌─────────────────────────────────────────────────────────────────┐
│                     FLUTTER CLIENT APPLICATION                  │
├───────────────────┬───────────────────────┬─────────────────────┤
│   Presentation    │      State / Business │     Data Layer      │
│  (UI Components)  │   (Riverpod Providers)│(Repositories & API) │
│  - Splash/NLP Input│  - SessionNotifier    │ - ServiceRepository │
│  - Matching Screens│  - ServiceBooking     │ - AuthRepository    │
│  - Tracking Stepper│  - TrackingNotifier   │ - LocationService   │
└─────────┬─────────┴───────────▲───────────┴──────────┬──────────┘
          │                     │                      │
          │ POST /service-req   │ Persists Bookings    │ Auth / Session
          ▼                     │                      ▼
┌───────────────────────────────┴───┐        ┌────────────────────┐
│      n8n AI WORKFLOW ENGINE       │        │  SUPABASE BACKEND  │
├───────────────────────────────────┤        ├────────────────────┤
│  1. Intent & NLP parsing (Gemini) │        │ - Auth Session Mgmt│
│  2. Provider fetch (Supabase)     │        │ - Providers Table  │
│  3. Scoring & Filter (Gemini)     │        │ - Bookings Table   │
│  4. Match Decision (Gemini)       │        │ - Realtime Sync    │
│  5. Pricing/Booking calc (Gemini) │        └────────────────────┘
└───────────────────────────────────┘
```

---

## 🤖 Multi-Agent Processing Pipeline (n8n Webhook)

The backend workflow processes conversational queries using a chain of five specialized Google Gemini 1.5 Flash agents:

1. **Intent Extraction Agent**:
   * **Input**: Conversational text query.
   * **Cognitive Tasks**: Identifies the primary service domain (e.g., plumbing), maps it to a standard Google Place type (e.g., plumber), evaluates urgency status, and assigns confidence percentages.
2. **Matching Agent**:
   * **Input**: Filtered provider list (from Supabase master index) + user GPS coordinates.
   * **Cognitive Tasks**: Evaluates distance and historical ratings of up to 50 candidates, scoring them geographically.
3. **Decision Agent**:
   * **Input**: Scored candidate pools.
   * **Cognitive Tasks**: Ranks candidates, selects the optimal choice, and creates a tailored `reason_for_chosen` natural language explanation.
4. **Pricing Agent**:
   * **Input**: Matched provider base fee + user location + urgency multiplier.
   * **Cognitive Tasks**: Formulates dynamic line-item invoice calculations including Platform, Distance, and Surcharges.
5. **Booking Agent**:
   * **Input**: Selected technician calendar.
   * **Cognitive Tasks**: Confirms availability, constructs the unified JSON response, and packages the payload.

---

## 📊 Location-Based Provider Scoring Algorithm

The matching system scores candidates using a weighted multi-factor formula calculated by the **Matching and Decision Agents**:

$$\text{Candidate Score} = (W_d \times S_d) + (W_r \times S_r) + (W_{rel} \times S_{rel})$$

### Scoring Factors:
1. **Distance Score ($S_d$)**:
   * Calculated using the Great-Circle Haversine formula based on user coordinates $(Lat_u, Lng_u)$ and provider coordinates $(Lat_p, Lng_p)$.
   * High score awarded to close distances ($<3\text{ km}$); decays rapidly as distance exceeds $10\text{ km}$.
2. **Rating Score ($S_r$)**:
   * Calculated proportionally from the provider's star rating scale (0.0 to 5.0) and review counts (e.g., $S_r = \text{Rating} / 5.0$).
3. **Reliability Score ($S_{rel}$)**:
   * Contextual performance parameter evaluating historical attendance and prompt check-ins.

### Standard Weights:
* **Distance Weight ($W_d$)**: $40\%$
* **Rating Weight ($W_r$)**: $45\%$
* **Reliability Weight ($W_{rel}$)**: $15\%$

---

## 🗄️ Database Schemas (Supabase)

Confirmed bookings are stored in the Supabase public schema:

### `Bookings` Table
```sql
CREATE TABLE public."Bookings" (
    id uuid DEFAULT gen_random_uuid() NOT NULL PRIMARY KEY,
    user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
    status text DEFAULT 'confirmed'::text NOT NULL,
    service_type text NOT NULL,
    provider_name text NOT NULL,
    total_price numeric NOT NULL,
    address text,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);

-- Enable Row Level Security (RLS)
ALTER TABLE public."Bookings" ENABLE ROW LEVEL SECURITY;

-- Create Policy: Users can only view their own bookings
CREATE POLICY "Users can view their own bookings" 
ON public."Bookings" FOR SELECT 
TO authenticated 
USING (auth.uid() = user_id);

-- Create Policy: Users can insert their own bookings
CREATE POLICY "Users can insert their own bookings" 
ON public."Bookings" FOR INSERT 
TO authenticated 
WITH CHECK (auth.uid() = user_id);
```

---

## ⚙️ Riverpod State Management Design

The application enforces strict separation of UI and state using specialized Riverpod providers:

1. **[sessionNotifierProvider](./lib/features/auth/presentation/providers/session_provider.dart#L58)**:
   * **Type**: `NotifierProvider<SessionNotifier, UserModel?>`
   * **Role**: Tracks Supabase session events (signedIn, signedOut, tokenRefreshed) and auto-updates user metadata across the application.
2. **[serviceBookingProvider](./lib/features/input/presentation/providers/input_provider.dart#L7)**:
   * **Type**: `AsyncNotifierProvider<ServiceBookingNotifier, ServiceResponse?>`
   * **Role**: Handles asynchronous NLP requests, retrieves live user GPS locations, and updates matching lists.
3. **[selectedProviderProvider](./lib/features/input/presentation/providers/input_provider.dart#L20)**:
   * **Type**: `NotifierProvider<SelectedProviderNotifier, ServiceProvider?>`
   * **Role**: Stores the active technician chosen by the user during the booking checkout flow.
4. **[trackingProvider](./lib/features/tracking/presentation/providers/tracking_provider.dart#L5)**:
   * **Type**: `NotifierProvider<TrackingNotifier, TrackingState>`
   * **Role**: Drives the simulated 5-stage lifecycle stepper progress (Confirmed ➔ En Route ➔ Arrived ➔ Working ➔ Completed).

---

## 🎙️ Cross-Platform Speech Recognition Architecture

To support robust voice-to-text inputs across both native mobile installations and web builds without risking compilation crashes, Serviq utilizes a **conditional import abstraction architecture** via an abstract factory pattern:

### 1. Architectural Map
```text
                  ┌───────────────────────┐
                  │    AppSpeechHelper    │  ◄─── (Core Interface Layer)
                  │  (Abstract Singleton) │
                  └───────────▲───────────┘
                              │
          ┌───────────────────┼───────────────────┐
          │ (Mobile Build)    │ (Web Build)       │ (Unsupported / Stub)
          ▼                   ▼                   ▼
┌───────────────────┐ ┌───────────────────┐ ┌───────────────────┐
│MobileSpeechHelper │ │  WebSpeechHelper  │ │ StubSpeechHelper  │
│ (speech_to_text)  │ │(SpeechRecognition)│ │ (Baseline errors) │
└───────────────────┘ └───────────────────┘ └───────────────────┘
```

### 2. Implementation Specifications
* **Core Abstraction ([AppSpeechHelper](./lib/core/utils/speech_helper.dart))**: Declares the singleton contract factory:
  ```dart
  import 'speech_helper_stub.dart'
      if (dart.library.html) 'speech_helper_web.dart'
      if (dart.library.io) 'speech_helper_mobile.dart';
  ```
  This conditional import compile directive dynamically binds the target compilation code. If building for web, the Dart compiler injects the JS-interop wrapper; if mobile, it binds to native mobile plugins, bypassing missing reference errors.
* **Web Implementation ([WebSpeechHelper](./lib/core/utils/speech_helper_web.dart))**: Leverages browser-native HTML5 Web Speech APIs (`html.SpeechRecognition`) through direct JS-interop, mapping browser callbacks natively to prevent reliance on third-party mobile microphone extensions.
* **Mobile Implementation ([MobileSpeechHelper](./lib/core/utils/speech_helper_mobile.dart))**: Integrates the `speech_to_text` (v7.3.0) library, interfacing with native Android Speech Service and Apple Speech Frameworks.

---


## ⚠️ Network & Location Fail-Safe Policies

### 1. Mandatory Location Access (`LOCATION_REQUIRED`)
* **Technical Rule**: Client must reject query submission if live location cannot be resolved.
* **Mechanism**: Handled in [ServiceBookingNotifier.submitQuery](./lib/features/input/presentation/providers/input_provider.dart#L30-L52). Calls [LocationService](./lib/core/services/location_service.dart#L4-L34) to query Geolocator hardware. If permission is denied or services are disabled, returns a clean error caught by the UI to show permission requests.

### 2. Global Network Timeout Safeguards
* **Dio Config**: Centrally defined in [dioProvider](./lib/features/input/data/repositories/service_repository.dart#L62-L69) with 30-second limitations:
  * `connectTimeout`: 30 seconds
  * `receiveTimeout`: 30 seconds
  * `sendTimeout`: 30 seconds
* **Watchdog Timer**: Integrated inside the processing animation loop of [AIUnderstandingScreen](./lib/features/matching/presentation/screens/ai_understanding_screen.dart#L38-L69). If 60 seconds pass without an API response, the watchdog triggers a modal dialog prompting the user to safely return home, preventing perpetual client freezing.
