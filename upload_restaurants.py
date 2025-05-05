import firebase_admin
from firebase_admin import credentials, firestore

# 1) Point to your fresh service‑account key JSON
cred = credentials.Certificate("serviceAccountKey.json")
firebase_admin.initialize_app(cred)
db = firestore.client()

# 2) Restaurant seed data with lat/lng
restaurants = [
    {
        "id": "bistro_22",
        "name": "Bistro 22",
        "image": "assets/bistro.jpg",
        "users": "100 U",
        "ratings": {
            "Taste": 0.8,
            "Service": 0.8,
            "Cleanliness": 0.9,
            "Affordability": 0.7,
            "Ambience": 0.6,
        },
        "color": "#5731EA",
        "lat": 5.568683,
        "lng": -0.1688871,
    },
    {
        "id": "cafe_mondo",
        "name": "Café Mondo",
        "image": "assets/cafe.jpg",
        "users": "160 U",
        "ratings": {
            "Taste": 0.8,
            "Service": 0.8,
            "Cleanliness": 0.7,
            "Affordability": 0.7,
            "Ambience": 0.6,
        },
        "color": "#5731EA",
        "lat": 5.572330,
        "lng": -0.170160,
    },
    {
        "id": "living_room",
        "name": "Living Room",
        "image": "assets/livingroom.jpg",
        "users": "92 U",
        "ratings": {
            "Taste": 0.8,
            "Service": 0.9,
            "Cleanliness": 0.0,
            "Affordability": 0.0,
            "Ambience": 0.0,
        },
        "color": "#9E9E9E",
        "lat": 5.642560,
        "lng": -0.160380,
    },
    {
        "id": "kfc_osu",
        "name": "KFC (Osu)",
        "image": "assets/kfc.jpg",
        "users": "92 U",
        "ratings": {
            "Taste": 0.8,
            "Service": 0.8,
            "Cleanliness": 0.8,
            "Affordability": 0.8,
            "Ambience": 0.8,
        },
        "color": "#9E9E9E",
        "lat": 5.565279,
        "lng": -0.181057,
    },
    {
        "id": "treehouse_restaurant",
        "name": "Treehouse Restaurant",
        "image": "assets/treehouse.jpg",
        "users": "150 U",
        "ratings": {
            "Taste": 0.9,
            "Service": 0.8,
            "Cleanliness": 0.9,
            "Affordability": 0.7,
            "Ambience": 0.7,
        },
        "color": "#9E9E9E",
        "lat": 5.560762,
        "lng": -0.172015,
    },
    {
        "id": "papaye",
        "name": "Papaye (Oxford St)",
        "image": "assets/papaye.png",
        "users": "92 U",
        "ratings": {
            "Taste": 0.7,
            "Service": 0.7,
            "Cleanliness": 0.7,
            "Affordability": 0.6,
            "Ambience": 0.6,
        },
        "color": "#9E9E9E",
        "lat": 5.543090,
        "lng": -0.205070,
    },
]

# 3) Upload/overwrite each document by ID
for r in restaurants:
    db.collection("restaurants").document(r["id"]).set(r)

print("✅ Geo‑enabled restaurant data uploaded.")
