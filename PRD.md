# 📄 Product Requirements Document (PRD)

## 📌 Project Overview
* **Product Name**: Serviq
* **Document Version**: 1.1.0
* **Date**: May 2026
* **Status**: Complete / Production-Ready

---

## 🎯 Product Vision & Goal

Serviq is a state-of-the-art, AI-native local services platform that redefines how users request, match, and book local home experts (such as electricians, plumbers, AC technicians, and sanitary/hardware professionals). 

By replacing complex multi-step search filters with an intuitive **Natural Language Processing (NLP)** interface, Serviq enables users to voice or type unstructured requests in their native language (Urdu or English) and automatically resolves their intent. 

The primary product goal is to establish a seamless, high-trust matching experience where customers are instantly connected to the single most optimal local service provider, backed by transparent, AI-synthesized reasoning and simulated real-time tracking.

---

## 👤 Target Audience & Personas

### 1. The Time-Pressed Homeowner (e.g., Bilal, 34)
* **Demographics**: Working professional, resides in an urban neighborhood (e.g., Bahria Town/Green Town, Lahore).
* **Pain Points**: Lacks the technical knowledge to diagnose home faults; does not have time to call multiple handymen to get quotes; has been overcharged by local technicians in the past.
* **Goal**: Wants to type a simple sentence like *"AC is leaking water please send someone now"* and get an honest, highly rated technician at a fair, pre-calculated price.

### 2. The Emergency Seeker (e.g., Ayesha, 28)
* **Demographics**: Busy mother, handles household management.
* **Pain Points**: Experiences a midnight plumbing crisis (e.g., bust pipe at 3:00 AM). Most local directory services are closed, and emergency rates are opaque.
* **Goal**: Needs instant confirmation of a 24/7 service provider willing to travel immediately, with clear visibility of any late-night/urgency surcharge.

---

## ✅ Core Functional Modules

### 1. Conversational Input & NLP Engine
* **Input Types**: Structured keyboard text inputs and voice microphone inputs.
* **Language Support**: Seamless bilingual parsing for English, Urdu, and Romanized Urdu ("Urdu-English code-switching").
* **Mandatory Geolocation**: The application must resolve the user's precise live GPS coordinates before transmitting the query to ensure geographic matching.

### 2. Multi-Agent AI Orchestrator
* **Intent Extraction**: The system must extract the primary service domain, map it to a standard Google Place type, evaluate urgency, and determine confidence.
* **Dynamic Matching**: Automatically cross-reference candidates based on multi-factor parameters (distance, ratings, reviews, historical reliability).
* **AI Match Explanation**: Surface the specific cognitive reasoning explaining why a professional was recommended or why other candidates were bypassed.

### 3. Transparent Pricing & Billing Breakdown
* **Pre-Calculated Billing**: Remove opaque "after-service" negotiating by presenting a comprehensive line-item bill before booking.
* **Billing Components**: Must clearly show Base Service Fee, Urgency surcharges, Distance costs, and Platform fees.

### 4. Interactive Booking & Simulated Lifecycle
* **Instant Booking**: Save booking records securely to the centralized Supabase database.
* **Real-time Lifecycle Stepper**: Walk the user through a highly engaging, automated 5-stage tracking lifecycle (Confirmed ➔ En Route ➔ Arrived ➔ Working ➔ Completed).
* **Psychology-driven Stepper**: Simulate the real-world progression with active status badges, smooth transitions, and distinct messaging at each step to maintain engagement.

### 5. High-Trust Feedback Loop
* **Technician Rating**: Enable users to rate their provider out of 5 stars.
* **Issue Reporting**: Allow logging disputes or issues to ensure long-term platform quality control.

---

## 📊 Feature Matrix & Requirements

| ID | Feature Module | Requirement Description | Priority | Complexity |
| :--- | :--- | :--- | :--- | :--- |
| **FR-01** | NLP Input | Parse conversational English/Urdu inputs via structured text or dynamic voice-to-text streams (Speech-to-Text) and capture live coordinate streams. | P0 | High |
| **FR-02** | AI Agent Sync | Sequence Intent, Matching, Decision, Pricing, and Booking agents in n8n. | P0 | High |
| **FR-03** | Matching UI | Display recommendation list with specific AI reasons for each match. | P0 | Medium |
| **FR-04** | Pricing Engine | Calculate dynamic pricing line-items based on provider base fees. | P0 | Medium |
| **FR-05** | Stepper Tracking | Simulate a 5-stage real-time lifecycle tracker for user peace of mind. | P0 | Medium |
| **FR-06** | Database Logging | Persist confirmed bookings under the active Supabase user profile. | P0 | Medium |
| **FR-07** | Feedback Sheet | Capture star ratings and text issues upon service completion. | P1 | Low |

---

## 🔒 Non-Functional Requirements (NFRs)

* **Performance (Perceived & Real)**:
  * Dynamic processing screens must use progress indicators that mimic agent processing steps to reduce user anxiety.
  * Webhook connections must have a robust 30-second timeout configuration to prevent indefinite client-side hanging.
* **Usability & Design**:
  * Adhere strictly to the **Cyprus (#004643)** and **Sand (#F0EDE5)** premium design tokens.
  * Use fluid micro-animations and shimmers to make screen loading feel instant and premium.
* **Security & Reliability**:
  * Securely handle custom sessions using Supabase authentication tokens.
  * Never expose raw database tables or API credentials directly in user-facing client bundles.

---

## 📈 Success Criteria & Metrics

* **Conversion Rate**: Percentage of input queries that result in a confirmed provider booking.
* **Linguistic Accuracy**: Percentage of natural language inputs correctly mapped to the intended service domain (target >90% success on bilingual test suites).
* **System Reliability**: Zero client-side application crashes when handling location denials, bad queries, or timeout states.
* **User Engagement**: Sustained retention on the simulated tracking stepper, tracked by successful feedback submissions.
