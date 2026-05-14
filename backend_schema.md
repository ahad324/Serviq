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

so let me tell u how our api works
i send this body

{
"query": "i need a plumber in wapda town around 8pm"
} 
here 
https://n8n-production-b9127.up.railway.app/webhook/service-request
and this is the response
{
    "success": true,
    "booking_id": "BK-1778757212545-AGJ3ZC",
    "service": "plumbing",
    "provider": {
        "id": "PRV001",
        "name": "Ali Repairs",
        "rating": 4.8,
        "distance_km": 2.1,
        "basefees": 500
    },
    "scheduling": {
        "requested": "2026-05-14T20:00:00.000Z",
        "had_conflict": false,
        "alternative_offered": null
    },
    "pricing": {
        "grand_total": 585,
        "currency": "PKR",
        "breakdown": [{
            "label": "Base service fee",
            "amount": 500
        }, {
            "label": "Distance cost",
            "amount": 42
        }, {
            "label": "Urgency (×1)",
            "amount": 0
        }, {
            "label": "Discount",
            "amount": 0
        }, {
            "label": "Platform fee (8%)",
            "amount": 43
        }]
    },
    "lifecycle": {
        "confirmed": {
            "stage": "confirmed",
            "at": "2026-05-14T11:13:33.762Z",
            "message": "Booking confirmed. Provider notified."
        },
        "en_route": {
            "stage": "en_route",
            "eta": "2026-05-14T11:43:33.762Z",
            "message": "Ali Repairs is on the way."
        },
        "arrival": {
            "stage": "arrival",
            "eta": "2026-05-14T11:58:33.762Z",
            "message": "Provider will arrive in ~45 min."
        },
        "in_progress": {
            "stage": "in_progress",
            "eta": "2026-05-14T12:13:33.762Z",
            "message": "Service in progress."
        },
        "completion": {
            "stage": "completion",
            "eta": "2026-05-14T13:13:33.762Z",
            "message": "Service completed."
        },
        "feedback": {
            "stage": "feedback",
            "eta": "2026-05-14T13:18:33.762Z",
            "message": "Please rate your experience."
        }
    },
    "decision_reasoning": {
        "selected_because": "Ali Repairs has the highest score (0.9275), the highest rating (4.8), and is the closest provider at 2.1 km, making them the most reliable choice for a same-day 20:00 appointment.",
        "rejections": [{
            "provider_id": "PRV003",
            "reason": "Lower rating (4.6) and higher distance (3.8 km) compared to PRV001, with a higher base fee of 550."
        }, {
            "provider_id": "PRV002",
            "reason": "Lowest rating (4.2) and greatest distance (5.5 km) among the candidates, despite the lower base fee."
        }]
    },
    "meta": {
        "confidence": 0.95,
        "processed_at": "2026-05-14T11:13:33.765Z"
    }
}
so be accordingly to this and for now rely on this mock data but make it alll so flexible that in future ill just need to add the api url in my en that's it so be accordingly perfect.