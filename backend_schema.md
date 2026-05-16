# 🗂️ 6. BACKEND SCHEMA (FINAL)

url: https://n8n-production-b9127.up.railway.app/webhook/service-request
new query format
{
    "query": "i need a plumber in green town around 3am",
    "test":false,(keep this true for now)
    "longitude":31.568490,
    "latitude":74.29166
}
we just needed some things more so please make accordingly to this one

this is our new response format
{
    "success": true,
    "count": 3,
    "providers": [{
        "id": "ChIJ4VYxkYX_GDkRE-A0i01urHs",
        "name": "Crown sanitary electric and hardware store Bahria Town Lahore",
        "service_type": "manufacturer",
        "rating": 4.8,
        "reviews": 109,
        "phone": "0306 4600689",
        "address": "239b commercial, Tulip Extension Tulip Block Sector C Bahria Town, Lahore, 53720, Pakistan",
        "location": {
            "lat": 31.368113499999996,
            "lng": 74.1869404
        },
        "maps_url": "https://maps.google.com/?cid=8911619041986404371&g_mp=Cilnb29nbGUubWFwcy5wbGFjZXMudjEuUGxhY2VzLlNlYXJjaE5lYXJieRACGAQgAA",
        "website": null,
        "reason_for_chosen": {
            "text": "Complete one stop shop for house hold accessories and maintenance. Good variety of electrical sanitary and hardware range. Also available home decor and lighting range modern sanitary and kitchen equipment available. Highly recommended",
            "languageCode": "en"
        }
    }, {
        "id": "ChIJudHcgsz_GDkRvoJWQF01XD4",
        "name": "Electrical Solutions",
        "service_type": "service",
        "rating": 4.9,
        "reviews": 115,
        "phone": "0314 7542749",
        "address": "Shop#7 Al fazal market AA Block, D Aa Block Sector D Bahria Town, Lahore, 53720, Pakistan",
        "location": {
            "lat": 31.376456800000003,
            "lng": 74.16997099999999
        },
        "maps_url": "https://maps.google.com/?cid=4493525202836554430&g_mp=Cilnb29nbGUubWFwcy5wbGFjZXMudjEuUGxhY2VzLlNlYXJjaE5lYXJieRACGAQgAA",
        "website": "https://eselectrician.com/",
        "reason_for_chosen": {
            "text": "One of the best electrician Service in Bahria Town, they came within 5 minutes and fixed My AC",
            "languageCode": "en"
        }
    }, {
        "id": "ChIJabOroIT_GDkRUhIFkz8EsoE",
        "name": "Home Secure Electrics",
        "service_type": "electrician",
        "rating": 5,
        "reviews": 148,
        "phone": "0315 7863835",
        "address": "Shop Number 4, AA-Block Aa Block Sector D Bahria Town, Lahore, 53720, Pakistan",
        "location": {
            "lat": 31.376400600000004,
            "lng": 74.17014240000002
        },
        "maps_url": "https://maps.google.com/?cid=9345536847843234386&g_mp=Cilnb29nbGUubWFwcy5wbGFjZXMudjEuUGxhY2VzLlNlYXJjaE5lYXJieRACGAQgAA",
        "website": "https://homesecureelectrics.com/",
        "reason_for_chosen": {
            "text": "Good service and good work best employee and frindly behaviour",
            "languageCode": "en"
        }
    }],
    "intent": {
        "service": "plumbing",
        "google_place_type": "plumber",
        "urgency": "normal",
        "urgency_multiplier": 1,
        "confidence": 0.9,
        "preferred_time": null,
        "notes": null
    }
}
so make accordingly to this now
