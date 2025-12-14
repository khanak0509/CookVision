# Migrate Products to Firebase 🔥

## Overview
The backend now fetches all food items from **Firebase Firestore** instead of `products.json`. This allows real-time updates and better scalability.

## 📊 Firebase Collection Structure

```
food_items/
  {documentId}/
    - name: string
    - description: string
    - category: string
    - cuisine: string
    - dietary: string
    - price: number
    - rating: number
    - image_url: string
    - calories: number
    - preparation_time: number
    - spice_level: string
    - ingredients: array (optional)
    - cooking_instructions: array (optional)
```

## 🚀 How to Upload Products to Firebase

### Option 1: Use Firebase Console (Manual)

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Navigate to **Firestore Database**
4. Create a new collection called `food_items`
5. Add documents manually with the fields above

### Option 2: Upload from products.json (Recommended)

Create a Python script to migrate your existing `products.json`:

```python
import json
import firebase_admin
from firebase_admin import credentials, firestore

# Initialize Firebase
cred = credentials.Certificate("path/to/your/firebase_key.json")
firebase_admin.initialize_app(cred)
db = firestore.client()

# Load products.json
with open('products.json', 'r') as f:
    products = json.load(f)

# Upload to Firestore
batch = db.batch()
for i, product in enumerate(products):
    doc_ref = db.collection('food_items').document()
    batch.set(doc_ref, product)
    
    # Commit in batches of 500 (Firestore limit)
    if (i + 1) % 500 == 0:
        batch.commit()
        batch = db.batch()
        print(f"✅ Uploaded {i + 1} products")

# Commit remaining
batch.commit()
print(f"🎉 Successfully uploaded {len(products)} products to Firebase!")
```

Save this as `migrate_products.py` and run:
```bash
python migrate_products.py
```

### Option 3: Upload via Flutter App

Add a one-time migration button in your Flutter admin panel:

```dart
Future<void> uploadProductsToFirebase() async {
  // Load products from assets/products.json
  String jsonString = await rootBundle.loadString('assets/products.json');
  List<dynamic> products = json.decode(jsonString);
  
  final firestore = FirebaseFirestore.instance;
  final batch = firestore.batch();
  
  for (var product in products) {
    final docRef = firestore.collection('food_items').doc();
    batch.set(docRef, product);
  }
  
  await batch.commit();
  print('✅ Uploaded ${products.length} products!');
}
```

## ✅ Verify Upload

After uploading, verify in Firestore Console:
1. Check `food_items` collection exists
2. Verify documents have all required fields
3. Test a query to fetch items

## 🔍 What Changed in Backend

### Before (products.json):
```python
with open('products.json', 'r') as f:
    all_products = json.load(f)
```

### After (Firebase):
```python
food_items_ref = db.collection('food_items')
food_items_docs = food_items_ref.stream()

all_products = []
for doc in food_items_docs:
    product_data = doc.to_dict()
    product_data['id'] = doc.id
    all_products.append(product_data)
```

## 📝 Updated Endpoints

All these endpoints now fetch from Firebase:

1. **`POST /api/user-suggestions`**
   - Fetches all food items from `food_items` collection
   - Filters out already ordered items
   - Returns personalized suggestions

2. **`search_products` tool**
   - Used by the AI agent
   - Searches `food_items` collection by name

3. **`_get_fallback_suggestions`**
   - Returns top-rated items from Firebase
   - Used when user has no order history

## 🎯 Benefits

✅ **Real-time updates** - Add/edit products without redeploying  
✅ **Scalability** - Handle thousands of products  
✅ **Consistency** - Same data source for app and backend  
✅ **Easy management** - Update via Firebase Console or admin panel  
✅ **Better performance** - Query only needed data  

## 🐛 Troubleshooting

### "Collection 'food_items' not found"
- Create the collection in Firebase Console
- Upload products using one of the methods above

### "No products returned"
- Check Firebase rules allow read access
- Verify collection name is exactly `food_items`
- Check documents have required fields

### "Permission denied"
- Update Firestore security rules:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /food_items/{document=**} {
      allow read: if true;  // Allow public read
      allow write: if request.auth != null;  // Only authenticated users can write
    }
  }
}
```

## 📱 Frontend Compatibility

Your Flutter app should already be using Firebase for food items. No changes needed if you're using:
```dart
FirebaseFirestore.instance.collection('food_items').get()
```

## 🔄 Rollback (If Needed)

If you need to rollback to `products.json`:

1. Revert changes in `main.py`:
```python
with open('products.json', 'r') as f:
    PRODUCTS_DATA = json.load(f)
```

2. Update `search_products` tool
3. Update suggestion endpoint

---

**Next Steps:**
1. ✅ Upload products to Firebase `food_items` collection
2. ✅ Test backend: `python main.py`
3. ✅ Verify suggestions endpoint works
4. ✅ Test in Flutter app

🎉 Enjoy real-time product management!
