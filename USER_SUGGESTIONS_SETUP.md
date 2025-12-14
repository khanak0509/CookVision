# User-Based Food Suggestions System 🍽️

## Overview
Your food app now has personalized food suggestions based on user order history! The system analyzes what users have ordered before and uses AI to recommend new dishes they'll love.

## System Architecture

### 🎯 Flow Diagram
```
User Places Orders (Cart → Orders) 
    ↓
User Opens Suggestions Screen
    ↓
Flutter App sends User ID to Backend
    ↓
Backend fetches User's Order History from Firebase
    ↓
Backend sends Orders + All Products to LLM (Gemini 2.0)
    ↓
LLM generates personalized suggestions with reasons
    ↓
Backend returns suggestions with images & details
    ↓
Flutter displays suggestions (User can add to cart)
```

## 🚀 Setup Instructions

### 1. Firebase Service Account Key

**REQUIRED:** You need to add your Firebase service account credentials.

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Click ⚙️ (Settings) → **Project Settings**
4. Navigate to **Service Accounts** tab
5. Click **Generate New Private Key**
6. Save the downloaded JSON file as:
   ```
   /Users/khanak/Desktop/food_app/food_app/firebase_key.json
   ```

### 2. Start the Backend Server

```bash
cd /Users/khanak/Desktop/food_app/food_app
python main.py
```

The server will run on: `http://localhost:8000`

### 3. Test the Endpoint

Once the server is running, you can test the API:

```bash
curl -X POST http://localhost:8000/api/user-suggestions \
  -H "Content-Type: application/json" \
  -d '{"user_id": "YOUR_FIREBASE_USER_ID"}'
```

## 📱 Frontend Changes

### Updated Files:
- **`lib/suggestions_screen.dart`**
  - Now calls `POST /api/user-suggestions` with user_id
  - Displays personalized suggestions with AI-generated reasons
  - "Add to Cart" button fully functional
  - Shows: reason, rating, prep time, calories, price

### Features:
✅ Fetches user order history from Firebase  
✅ Analyzes preferences (favorite cuisine, category, dietary)  
✅ LLM generates personalized suggestions  
✅ Shows "reason" why each meal is recommended  
✅ Add meals directly to cart  
✅ Beautiful UI with gradient cards  

## 🔧 Backend Implementation

### New Endpoint: `POST /api/user-suggestions`

**Request Body:**
```json
{
  "user_id": "firebase_user_id_here"
}
```

**Response:**
```json
{
  "weather": {
    "city": "Delhi",
    "temperature": 25,
    "description": "Clear"
  },
  "ai_message": "Based on your 12 previous orders, we found 6 new dishes you might love!",
  "user_preferences": {
    "favorite_category": "Main Course",
    "favorite_cuisine": "Indian",
    "dietary_preference": "Vegetarian",
    "order_count": 12
  },
  "suggested_meals": [
    {
      "id": "123",
      "name": "Paneer Tikka Masala",
      "description": "Creamy tomato curry with grilled paneer",
      "reason": "You loved Butter Chicken - this has similar flavors but vegetarian!",
      "price": 299.0,
      "rating": 4.7,
      "image_url": "https://...",
      "emoji": "🍛",
      "calories": 450,
      "prep_time": 30,
      "category": "Main Course",
      "cuisine": "Indian",
      "dietary": "Vegetarian",
      "spice_level": "Medium"
    }
  ]
}
```

### Backend Logic:
1. **Fetch Orders:** Gets last 20 orders from `users/{userId}/orders`
2. **Analyze Preferences:** Counts most common categories, cuisines, dietary choices
3. **Filter Products:** Removes already-ordered items
4. **LLM Prompt:** 
   - Input: User's order history + Available products
   - Task: Suggest 6-8 new items with personalized reasons
5. **Return Results:** Full product details + AI-generated reasons

## 🧪 Testing Guide

### Test Scenario:
1. **Place Orders:**
   - Add items to cart
   - Click "Proceed to Checkout"
   - Complete order (moves cart → orders collection)

2. **Open Suggestions:**
   - Navigate to Suggestions Screen
   - Backend analyzes your orders
   - See personalized recommendations

3. **Verify:**
   - Each suggestion shows a "reason" based on your orders
   - Click "Add to Cart" to add meals
   - Check Firebase for cart items

### Expected Behavior:
- First-time users: Get popular/top-rated items
- Users with orders: Get personalized suggestions based on history
- Suggestions avoid already-ordered items
- Reasons reference user's previous orders

## 📊 Firebase Collections

### Orders Collection:
```
users/
  {userId}/
    orders/
      {orderId}/
        - orderId: string
        - items: array of products
        - totalAmount: number
        - deliveryCharge: 40
        - tax: 5% of total
        - grandTotal: calculated
        - orderDate: timestamp
        - status: "pending"
        - paymentStatus: "pending"
```

### Cart Collection:
```
users/
  {userId}/
    cart_items/
      {productId}/
        - product details
        - quantity
        - addedAt: timestamp
```

## 🎨 UI Features

### Suggestion Cards Display:
- 🎯 **Meal Name** (bold, white)
- 💡 **AI Reason** (gray, 2 lines) - "You loved X, try this!"
- ⏱️ **Prep Time** - colored chip
- 🔥 **Calories** - orange chip
- ⭐ **Rating** - amber chip
- 🛒 **Add to Cart** button (accent color)

### Bottom Sheet Details:
- Large emoji icon
- Full meal description
- Stats: Time, Calories, Rating
- "Start Cooking" button
- "Add to Cart" button

## 🐛 Troubleshooting

### Issue: "Import 'firebase_admin' could not be resolved"
**Solution:** Package already installed. Just add `firebase_key.json`

### Issue: Suggestions showing empty
**Check:**
1. Backend running? (`python main.py`)
2. Firebase credentials added? (`firebase_key.json`)
3. User has placed orders?
4. Network connection to localhost?

### Issue: "Unable to load suggestions"
**Debug:**
1. Check backend terminal for errors
2. Verify user_id is correct
3. Check Firebase orders collection has data
4. Test API with curl command

## 🔐 Security Notes

- ⚠️ **DO NOT** commit `firebase_key.json` to Git
- Already in `.gitignore`
- Keep credentials secure
- Use environment variables in production

## 📝 Next Steps

### Enhancements You Can Add:
1. **Cache suggestions** - Reduce API calls
2. **Dietary filters** - Let users filter by veg/non-veg
3. **Favorite system** - Track favorite meals
4. **Share suggestions** - Social features
5. **Weekly meal plans** - Generate meal plans from suggestions

## 🎉 Success Indicators

You'll know it's working when:
✅ Backend starts without errors  
✅ Frontend loads suggestions (no loading forever)  
✅ Each suggestion has a personalized "reason"  
✅ Add to Cart works  
✅ Suggestions change based on order history  

---

## Need Help?

If you encounter issues:
1. Check backend terminal for error messages
2. Verify `firebase_key.json` is in the correct location
3. Test the API endpoint directly with curl
4. Check Flutter console for error logs

**Happy Cooking! 👨‍🍳**
