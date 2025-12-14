#!/usr/bin/env python3
"""
Migration script to upload products from products.json to Firebase Firestore
"""

import json
import firebase_admin
from firebase_admin import credentials, firestore
import os

def migrate_products_to_firebase():
    """Upload all products from products.json to Firebase food_items collection"""
    
    print("🔥 Starting Firebase Migration...")
    
    # Initialize Firebase Admin SDK
    try:
        if not firebase_admin._apps:
            cred_path = "/Users/khanak/Desktop/food_app/food_app/cookvision-9bb7f-firebase-adminsdk-fbsvc-23d96ad1fd.json"
            
            if not os.path.exists(cred_path):
                print("❌ Firebase credentials not found!")
                print(f"   Looking for: {cred_path}")
                return
            
            cred = credentials.Certificate(cred_path)
            firebase_admin.initialize_app(cred)
            print("✅ Firebase initialized")
    except Exception as e:
        print(f"❌ Error initializing Firebase: {e}")
        return
    
    db = firestore.client()
    
    # Load products.json
    products_file = 'products.json'
    if not os.path.exists(products_file):
        print(f"❌ {products_file} not found!")
        print("   Make sure you're running this script from the correct directory")
        return
    
    try:
        with open(products_file, 'r', encoding='utf-8') as f:
            products = json.load(f)
        print(f"✅ Loaded {len(products)} products from {products_file}")
    except Exception as e:
        print(f"❌ Error reading {products_file}: {e}")
        return
    
    # Check if collection already has data
    existing_docs = db.collection('food_items').limit(1).stream()
    has_data = False
    for _ in existing_docs:
        has_data = True
        break
    
    if has_data:
        response = input("\n⚠️  'food_items' collection already has data. Continue? This will add more items. (y/n): ")
        if response.lower() != 'y':
            print("❌ Migration cancelled")
            return
    
    # Upload to Firestore in batches
    print("\n📤 Uploading products to Firebase...")
    batch = db.batch()
    batch_count = 0
    uploaded_count = 0
    
    for i, product in enumerate(products):
        # Create a new document reference
        doc_ref = db.collection('food_items').document()
        
        # Add to batch
        batch.set(doc_ref, product)
        batch_count += 1
        
        # Commit in batches of 500 (Firestore limit)
        if batch_count >= 500:
            batch.commit()
            uploaded_count += batch_count
            print(f"   ✅ Uploaded {uploaded_count}/{len(products)} products...")
            batch = db.batch()
            batch_count = 0
    
    # Commit remaining items
    if batch_count > 0:
        batch.commit()
        uploaded_count += batch_count
    
    print(f"\n🎉 Successfully uploaded {uploaded_count} products to Firebase!")
    print(f"   Collection: food_items")
    print(f"   Total documents: {uploaded_count}")
    
    # Verify upload
    print("\n🔍 Verifying upload...")
    total_docs = len(list(db.collection('food_items').stream()))
    print(f"   ✅ Verified {total_docs} documents in 'food_items' collection")
    
    print("\n✨ Migration complete! Your backend will now fetch products from Firebase.")

if __name__ == "__main__":
    print("=" * 60)
    print("  Firebase Products Migration Script")
    print("=" * 60)
    print()
    migrate_products_to_firebase()
