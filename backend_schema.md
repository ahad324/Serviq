# 🗂️ 6. BACKEND SCHEMA (FINAL)

Use EXACTLY this:

<pre class="overflow-visible! px-0!" data-start="2951" data-end="3128"><div class="relative w-full mt-4 mb-1"><div class=""><div class="relative"><div class="h-full min-h-0 min-w-0"><div class="h-full min-h-0 min-w-0"><div class="border border-token-border-light border-radius-3xl corner-superellipse/1.1 rounded-3xl"><div class="h-full w-full border-radius-3xl bg-token-bg-elevated-secondary corner-superellipse/1.1 overflow-clip rounded-3xl lxnfua_clipPathFallback"><div class="pointer-events-none absolute inset-x-4 top-12 bottom-4"><div class="pointer-events-none sticky z-40 shrink-0 z-1!"><div class="sticky bg-token-border-light"></div></div></div><div class="relative"><div class=""><div class="relative z-0 flex max-w-full"><div id="code-block-viewer" dir="ltr" class="q9tKkq_viewer cm-editor z-10 light:cm-light dark:cm-light flex h-full w-full flex-col items-stretch ͼs ͼ16"><div class="cm-scroller"><pre class="cm-content q9tKkq_readonly m-0"><code><span>{</span><br/><span>  "intent": {...},</span><br/><span>  "providers_ranked": [...],</span><br/><span>  "selected_provider": {...},</span><br/><span>  "pricing": {...},</span><br/><span>  "booking": {...},</span><br/><span>  "service_flow": {...},</span><br/><span>  "fallback": </span><span class="ͼy">null</span><br/><span>}</span></code></pre></div></div></div></div></div></div></div></div></div></div></div></div></pre>

like this
{
  "intent": {
    "service": "AC repair",
    "location": "G-13",
    "time": "tomorrow morning",
    "urgency": "high",
    "budget": "low",
    "confidence": 0.92
  },
  "providers_ranked": [
    {
      "id": "prov_001",
      "name": "CoolFix Experts",
      "rating": 4.6,
      "distance_km": 3.2,
      "availability": "10:00 AM",
      "reliability_score": 0.9,
      "price_estimate": 1800,
      "match_score": 0.87,
      "reason": "High reliability + AC specialization"
    },
    {
      "id": "prov_002",
      "name": "FastCool Services",
      "rating": 4.3,
      "distance_km": 2.1,
      "availability": "9:00 AM",
      "reliability_score": 0.7,
      "price_estimate": 1500,
      "match_score": 0.79,
      "reason": "Closer but lower reliability"
    }
  ],
  "selected_provider": {
    "id": "prov_001",
    "name": "CoolFix Experts",
    "final_score": 0.87,
    "decision_reason": "Better reliability and AC specialization despite slightly higher distance"
  },
  "pricing": {
    "base_fee": 1200,
    "distance_cost": 200,
    "urgency_charge": 300,
    "discount": -100,
    "final_price": 1600,
    "explanation": "Urgent request + travel distance included"
  },
  "booking": {
    "booking_id": "book_001",
    "status": "confirmed",
    "time_slot": "10:00 AM",
    "provider_id": "prov_001",
    "provider_assigned": "CoolFix Experts",
    "calendar_updated": true
  },
  "service_flow": {
    "status": "en_route",
    "en_route": "Provider will arrive in 30 mins",
    "completion": "Checklist completed",
    "feedback": null
  },
  "fallback": null
}
 also use this mock data for now store it somewhere cuz for now we'll not be calling the api but make this whole project fully flexible that when we integrate the api it all goes perfectly so keep this in mind
