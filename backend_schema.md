# 🗂️ 6. BACKEND SCHEMA (FINAL)


new query format
{
"query": "i need a plumber in green town around 3am",
    "test":false,
    "longitude":31.568490,
    "latitude":74.29166
}
we just needed some things mroe so please make accordingly to this one

this is our new response format
[{
    "success": true,
    "providers": [{
        "id": "ChIJh8qBUFAbGTkR7QThCwjhD1k",
        "name": "APC / Power Kingdom pvt Ltd.",
        "service_type": "service",
        "rating": 4.8,
        "reviews": 20,
        "phone": "0333 1550333",
        "address": "Mall Road, Panoramic hotel, 54 Mall Avenue, Garhi Shahu, Lahore, 54000, Pakistan",
        "location": {
            "lat": 31.561684399999997,
            "lng": 74.3217882
        },
        "maps_url": "https://maps.google.com/?cid=6417595418701530349&g_mp=Cilnb29nbGUubWFwcy5wbGFjZXMudjEuUGxhY2VzLlNlYXJjaE5lYXJieRACGAQgAA",
        "website": "http://www.powerkingdom.com.pk/",
        "reason_for_choosen": "Regular Customer of APC UPS from Power Kingdom.\nUsman Sb very nice and cooperative person.\nExcellent experience\nRecommend"
    }, {
        "id": "ChIJDzJH8nwDGTkR1XnqCWtEnu8",
        "name": "Arif plumbing services",
        "service_type": "plumber",
        "rating": 4.9,
        "reviews": 177,
        "phone": "0300 4312739",
        "address": "Tyfon Street, Aftab Park, Bund Road, Kot Kamboh Lahore, 54000, Pakistan",
        "location": {
            "lat": 31.535005599999998,
            "lng": 74.2761943
        },
        "maps_url": "https://maps.google.com/?cid=17266313247903611349&g_mp=Cilnb29nbGUubWFwcy5wbGFjZXMudjEuUGxhY2VzLlNlYXJjaE5lYXJieRACGAQgAA",
        "website": "https://arifplumbingservices.com/",
        "reason_for_choosen": "Plumber arrived in 30 minutes, fixed the pipe efficiently with quality parts, and cleaned up afterward—no mess left. Professional, affordable"
    }, {
        "id": "ChIJNVexWN0FGTkRu9re0WYEd_c",
        "name": "Delite Electronics",
        "service_type": "electrician",
        "rating": 4.4,
        "reviews": 37,
        "phone": "(042) 37429240",
        "address": "Qartaba Chowk, Abid Market, Queen's Road, Jinnah Town, Lahore, 54000, Pakistan",
        "location": {
            "lat": 31.549062499999998,
            "lng": 74.31593749999999
        },
        "maps_url": "https://maps.google.com/?cid=17831726089250986683&g_mp=Cilnb29nbGUubWFwcy5wbGFjZXMudjEuUGxhY2VzLlNlYXJjaE5lYXJieRACGAQgAA",
        "website": "http://www.delite.com.pk/",
        "reason_for_choosen": "They are a brand outlet of delite, but they offer a wide variety of products from other brands, too.\nYou can find cooking ranges, microwave ovens, oven hoods, LED screens, refrigerators, fridge, freezer, geysers, and many more electronics products of your choice under one roof.\nThey team is cooperative and guided us well and provided a discount as well."
    }],
    "intent": {
        "service": "electrical",
        "preferred_time": null,
        "urgency": "standard",
        "budget_max": null,
        "notes": "Location: Sanda, Lahore",
        "confidence": 0.98,
        "google_place_type": "electrician",
        "urgency_multiplier": 1
    }
}]
so make accordingly to this now
