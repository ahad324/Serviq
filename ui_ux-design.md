# 🎨 UI/UX Design System Guidelines

## 📌 Document Metadata
* **Document Version**: 1.1.0
* **Date**: May 2026
* **Design Philosophy**: Minimal, Premium, Organic & High-Trust
* **Primary Objective**: Maximum perceived performance & visual delight

---

## 🎨 Centralized Color Palette (Design Tokens)

The application adheres strictly to a signature color palette. Colors must not be hardcoded in UI files and must only be referenced from [AppColors](file:///g:/Ahad/Mobile_Application_Dev/serviq/lib/core/theme/app_colors.dart):

```text
█ Cyprus Primary       #004643  ➔ Primary Brand Action Color
█ Sand Background      #F0EDE5  ➔ Soft, Organic Neutral Background
█ Cyprus Light         #006B67  ➔ Hover and Button Gradient Endpoints
█ Cyprus Dark          #002E2C  ➔ High Contrast Text and Shadows
█ Accent Mustard       #F9BC60  ➔ Gold Ratings, Alerts, and Badges
█ Surface White        #FFFFFF  ➔ Cards, Sheets, and Text Fields
█ Surface Dark         #E5E2D8  ➔ Secondary Dividers and Borders
█ Secondary Brand      #ABD1C6  ➔ Muted Teal Highlights
```

---

## 🔤 Typographic Hierarchy

To ensure a modern and clean aesthetic, Serviq implements a dual-font typographic scale:

1. **Headings, Buttons, and Branding**: **Plus Jakarta Sans**
   * Selected for its bold geometric shapes and premium high-tech look.
   * Applied in [AppLogo](file:///g:/Ahad/Mobile_Application_Dev/serviq/lib/core/widgets/premium_widgets.dart#L130), [PremiumButton](file:///g:/Ahad/Mobile_Application_Dev/serviq/lib/core/widgets/premium_widgets.dart#L52), and screen titles.
2. **Body, Form Fields, and Details**: **Inter**
   * Highly readable, standard neutral grotesque font optimized for high-density reading.
   * Applied in lists, address fields, and price rows.

---

## 🧱 Premium Shared Components

The design language enforces absolute consistency by reusing central premium components:

### 1. [PremiumCard](file:///g:/Ahad/Mobile_Application_Dev/serviq/lib/core/widgets/premium_widgets.dart#L6-L50)
* **Design Specifications**:
  * Circular border radius of `24.0`.
  * Double-layered shadow system: a soft primary-tinted glow (`AppColors.primary.withValues(alpha: 0.04)`) with a blur radius of 24, overlaid on a micro-black ambient shadow.

### 2. [PremiumButton](file:///g:/Ahad/Mobile_Application_Dev/serviq/lib/core/widgets/premium_widgets.dart#L52-L128)
* **Design Specifications**:
  * Rigid height of `58.0` with `20.0` border radius.
  * Linear gradient blending Primary Cyprus to Cyprus Light.
  * Responsive, built-in dynamic loader overlaying actions during network states.

### 3. [PremiumTextField](file:///g:/Ahad/Mobile_Application_Dev/serviq/lib/core/widgets/premium_widgets.dart#L196-L300)
* **Design Specifications**:
  * Double-layered label and hint structure.
  * `20.0` border radius with fine `0.06` opacity black borders that transition into a thick `2.0` primary border when focused.

### 4. [StatusBadge](file:///g:/Ahad/Mobile_Application_Dev/serviq/lib/core/widgets/premium_widgets.dart#L331-L389)
* **Design Specifications**:
  * Pulsating status indicator dot backed by a repeating fade in/out animation.
  * Bold, uppercase tracked lettering for maximum scannability.

### 5. [GlassContainer](file:///g:/Ahad/Mobile_Application_Dev/serviq/lib/core/widgets/premium_widgets.dart#L302-L329)
* **Design Specifications**:
  * Backdrop filter blur of `10.0` with variable white opacity overlay.
  * Used for elegant floating headers and premium overlays.

---

## 📱 Detailed Screen Workflows

### 1. Splash Screen (`/`)
* **Design**: Animated center logo scaled via elastic curves, backed by radial sand/mustard glowing lights.
* **UX Strategy**: A smooth progress bar tracks simulated system checks (Supabase connection, AI module initialization, location validation) to prepare user context.

### 2. Authentication Screen (`/auth`)
* **Design**: Modular login/signup switcher with elegant custom text fields.
* **UX Strategy**: During sign up, presents an interactive location validation banner that requests permissions, rendering a green success checkmark upon verification.

### 3. NLP Input Screen (`/home`)
* **Design**: Clean minimal prompt space with a conversational input box, Urdu/English placeholders, microphone shortcuts, and bottom navigation access.
* **UX Strategy**: Captures coordinates silently. Direct CTA click moves to AI analysis immediately.

### 4. AI Understanding Screen (`/ai-understanding`)
* **Design**: A rotating progress circle and glowing star icon backed by a beautiful linear status indicator.
* **UX Strategy**: Employs **Perceived Performance Optimizations**. Shows active logs of individual agents running (e.g. "Matching Agent scanning 50+ providers...") keeping users engaged rather than showing a generic spinner.

### 5. Provider List Screen (`/providers`)
* **Design**: Individual premium cards containing expert details, star averages, map buttons, and action buttons.
* **UX Strategy**: The recommended provider features an AI Reasoning block explaining the decision context directly under their card.

### 6. Pricing Breakdown Screen (`/pricing-breakdown`)
* **Design**: Comprehensive bill overview featuring provider metadata.
* **UX Strategy**: Clean, aligned line-item rows separating base, distance, urgency, and platform fees, culminating in a bold primary Cyprus grand total.

### 7. Booking Confirmation Screen (`/booking-confirmation`)
* **Design**: Success screen with deep green vector animations, booking IDs, and swift navigation.
* **UX Strategy**: Reassures the user, preparing them for real-time tracking.

### 8. Tracking Screen (`/tracking`)
* **Design**: Map/Provider header linked to a vertical `StatusStepper` displaying progression.
* **UX Strategy**: Simulates provider journey over 30 seconds (Confirmed ➔ En Route ➔ Arrived ➔ Working ➔ Completed), automatically launching a feedback modal upon completion.

---

## ✨ UX Psychology & Motion Rules

* **Progressive Disclosure**: Only present details when the user demands them. Match decisions display a concise card summary; full rejection logs or address breakdowns remain in secondary layers.
* **Micro-interactions**: Every click must result in tactile feedback (smooth color state changes, sliding transitions, elastic scales, or fading status overlays).
* **Perceived Load Reduction**: Skeleton shimmers and step-by-step loading progress states must be used instead of static spinners.
