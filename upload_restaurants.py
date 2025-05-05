import firebase_admin
from firebase_admin import credentials, firestore

# Load your Firebase service account key
cred = credentials.Certificate("serviceAccountKey.json")  # Make sure this file is in your project directory
firebase_admin.initialize_app(cred)

db = firestore.client()

default_restaurant_data = [
    {
        'id': 'bistro_22',
        'name': 'Bistro 22',
        'image': 'assets/bistro.jpg',
        'users': '100 U',
        'ratings': {
            'Taste': 0.8,
            'Service': 0.8,
            'Cleanliness': 0.9,
            'Affordability': 0.7,
            'Ambience': 0.6,
        },
        'color': '#5731EA',
    },
    {
        'id': 'cafe_mondo',
        'name': 'Café Mondo',
        'image': 'assets/cafe.jpg',
        'users': '160 U',
        'ratings': {
            'Taste': 0.8,
            'Service': 0.8,
            'Cleanliness': 0.7,
            'Affordability': 0.7,
            'Ambience': 0.6,
        },
        'color': '#5731EA',
    },
    {
        'id': 'the_chop_house',
        'name': 'The Chop House',
        'image': 'assets/chophouse.jpg',
        'users': '92 U',
        'ratings': {
            'Taste': 0.8,
            'Service': 0.9,
            'Cleanliness': 0.0,
            'Affordability': 0.0,
            'Ambience': 0.0,
        },
        'color': '#9E9E9E',  # grey
    },
    {
        'id': 'savory_spot',
        'name': 'Savory Spot',
        'image': 'assets/savory.jpg',
        'users': '92 U',
        'ratings': {
            'Taste': 0.8,
            'Service': 0.8,
            'Cleanliness': 0.8,
            'Affordability': 0.8,
            'Ambience': 0.8,
        },
        'color': '#9E9E9E',
    },
    {
        'id': 'ocean_grill',
        'name': 'Ocean Grill',
        'image': 'assets/ocean.jpg',
        'users': '150 U',
        'ratings': {
            'Taste': 0.9,
            'Service': 0.8,
            'Cleanliness': 0.9,
            'Affordability': 0.7,
            'Ambience': 0.7,
        },
        'color': '#9E9E9E',
    },
    {
        'id': 'urban_table',
        'name': 'Urban Table',
        'image': 'assets/urban.jpg',
        'users': '92 U',
        'ratings': {
            'Taste': 0.7,
            'Service': 0.7,
            'Cleanliness': 0.7,
            'Affordability': 0.6,
            'Ambience': 0.6,
        },
        'color': '#9E9E9E',
    },
]

# Upload each restaurant
for restaurant in default_restaurant_data:
    db.collection("restaurants").document(restaurant["id"]).set(restaurant)

print("✅ All restaurants successfully uploaded to Firestore.")
