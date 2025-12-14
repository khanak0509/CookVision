#!/usr/bin/env python3
"""
Test script for user suggestions API
"""

import requests
import json

# Test the endpoint
url = "http://localhost:8000/api/user-suggestions"

# Replace with actual Firebase user ID
test_user_id = "BLK1VlygEtO4fyGHkmmrQjeJMrw2"

payload = {
    "user_id": test_user_id
}

print("🧪 Testing User Suggestions Endpoint...")
print(f"📤 Sending request to: {url}")
print(f"📦 Payload: {json.dumps(payload, indent=2)}")
print("\n" + "="*60 + "\n")

try:
    response = requests.post(url, json=payload, timeout=30)
    
    print(f"✅ Status Code: {response.status_code}")
    print("\n📥 Response:")
    print(json.dumps(response.json(), indent=2))
    
    if response.status_code == 200:
        data = response.json()
        print("\n" + "="*60)
        print("📊 Summary:")
        print(f"  - AI Message: {data.get('ai_message', 'N/A')}")
        print(f"  - Total Suggestions: {len(data.get('suggested_meals', []))}")
        print(f"  - Order Count: {data.get('user_preferences', {}).get('order_count', 0)}")
        print("\n🍽️ Suggested Meals:")
        for i, meal in enumerate(data.get('suggested_meals', []), 1):
            print(f"  {i}. {meal.get('emoji', '🍽️')} {meal.get('name', 'N/A')}")
            print(f"     - Category: {meal.get('category', 'N/A')} | Cuisine: {meal.get('cuisine', 'N/A')}")
            print(f"     - Price: ₹{meal.get('price', 0)} | Rating: ⭐{meal.get('rating', 0)}")
            print(f"     - Reason: {meal.get('reason', 'N/A')}")
            print()
        
except requests.exceptions.ConnectionError:
    print("❌ Error: Could not connect to server")
    print("   Make sure the backend is running: python main.py")
except requests.exceptions.Timeout:
    print("❌ Error: Request timed out")
except Exception as e:
    print(f"❌ Error: {e}")

print("\n" + "="*60)
print("✅ Test Complete!")
