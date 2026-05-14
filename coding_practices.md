# 🧠 8. CODING BEST PRACTICES (STRICT – MUST FOLLOW)

## 🎯 OVERALL PRINCIPLES

* Write **clean, readable, maintainable code**
* Follow **separation of concerns**
* Avoid hacks / shortcuts even in hackathon
* Code should look like  **production-ready** , not prototype

---

## 🧱 STRUCTURE & ORGANIZATION

### ✅ Modular Architecture

* Each feature should be isolated (input, providers, booking, etc.)
* No large monolithic files
* Keep logic, UI, and data separate

---

### ✅ Scalable Folder Structure (IMPORTANT)

* Organize by  **feature** , not by type
* Keep consistent naming across entire project
* Avoid deep nesting

👉 Rule:

> Any new developer should understand structure in < 2 minutes

---

## 🎨 UI & THEME MANAGEMENT

### ✅ Centralized Design System (VERY IMPORTANT)

* Colors must be defined in **one central place**
* Typography must be centralized
* Spacing, border radius, shadows → reusable constants

👉 So:

> Changing theme = change in ONE file only

---

### ✅ Consistent UI Rules

* Same padding system everywhere
* Same font hierarchy everywhere
* Same button styles everywhere

👉 No random styling allowed ❌

---

## ⚙️ STATE MANAGEMENT

### ✅ Clean State Handling

* Use a single, consistent state management approach (Riverpod)
* No unnecessary global states
* Keep state minimal and predictable

---

### ✅ Separation of UI & Logic

* UI should NOT contain business logic
* Logic should be handled separately

---

## 🔗 API HANDLING

### ✅ Clean API Layer

* All API calls centralized
* No direct API calls inside UI components

---

### ✅ Error Handling

* Handle:
  * API failure
  * empty responses
  * loading states

👉 Never assume success ❌

---

## 🧩 REUSABILITY

### ✅ Reusable Components

* Buttons, cards, loaders → reusable
* Avoid duplicate UI code

---

### ✅ DRY Principle

* Don’t Repeat Yourself
* If code repeats → refactor

---

## 🎬 PERFORMANCE & SMOOTHNESS

### ✅ Optimized Rendering

* Avoid unnecessary rebuilds
* Keep UI lightweight

---

### ✅ Animations

* Use animations  **purposefully** , not excessively
* Keep transitions smooth and fast

---

## 🧪 EDGE CASE HANDLING

### MUST HANDLE:

* Empty provider list
* Low confidence input
* API failure
* Loading states
* Long text inputs

👉 App should NEVER crash ❌

---

## 🧹 CODE QUALITY

### ✅ Naming Conventions

* Clear, meaningful names
* No vague names like `data`, `temp`, `value`

---

### ✅ Readability

* Small functions
* Proper spacing
* Logical grouping

---

### ✅ Comments (Minimal but Useful)

* Only where logic is complex
* Avoid unnecessary comments

---

## 🔒 PROFESSIONALISM

### ✅ Production Mindset

* Even in hackathon → code like real product
* Think scalability, not shortcuts

---

### ✅ Consistency > Creativity

* Follow same patterns everywhere
* Avoid mixing styles

---

## ⚡ FINAL STRICT RULES

❌ No hardcoding in UI
❌ No mixed responsibilities
❌ No inconsistent styling
❌ No messy structure

✅ Everything modular
✅ Everything centralized
✅ Everything consistent

---

# 🏆 FINAL ONE-LINE MINDSET

👉 “Write code like this will be shipped to real users tomorrow”
