# Setup Checklist ✅

## Required Before Testing

- [ ] **Download Firebase Service Account Key**
  - Go to [Firebase Console](https://console.firebase.google.com/)
  - Project Settings → Service Accounts
  - Generate New Private Key
  - Save as: `/Users/khanak/Desktop/food_app/food_app/firebase_key.json`

- [ ] **Start Backend Server**
  ```bash
  cd /Users/khanak/Desktop/food_app/food_app
  python main.py
  ```
  - Should see: "Application startup complete"
  - Server on: http://localhost:8000

- [ ] **Test API Endpoint** (Optional)
  ```bash
  curl -X POST http://localhost:8000/api/user-suggestions \
    -H "Content-Type: application/json" \
    -d '{"user_id": "test_user_id"}'
  ```

## Testing Flow

1. [ ] **Place Test Orders**
   - Open app → Add items to cart
   - Click "Proceed to Checkout"
   - Complete order
   - Repeat 2-3 times with different items

2. [ ] **Open Suggestions Screen**
   - Navigate to Suggestions
   - Should see loading indicator
   - Then personalized suggestions appear

3. [ ] **Verify Features**
   - [ ] Each meal shows a "reason" (why it's recommended)
   - [ ] Meals are NOT ones you already ordered
   - [ ] "Add to Cart" button works
   - [ ] Can open meal details modal
   - [ ] Rating, calories, prep time displayed

4. [ ] **Check Firebase**
   - [ ] Orders saved in `users/{userId}/orders/`
   - [ ] Cart items saved when clicking "Add to Cart"

## Files Modified

✅ **Backend:**
- `main.py` - Added POST `/api/user-suggestions` endpoint

✅ **Frontend:**
- `lib/suggestions_screen.dart` - Connected to backend API

✅ **Documentation:**
- `USER_SUGGESTIONS_SETUP.md` - Complete setup guide

## Quick Test Command

Once backend is running, test with:
```bash
# Replace YOUR_USER_ID with actual Firebase user ID
curl -X POST http://localhost:8000/api/user-suggestions \
  -H "Content-Type: application/json" \
  -d '{"user_id": "YOUR_USER_ID"}'
```

## Expected Response Structure

```json
{
  "weather": {...},
  "ai_message": "Based on your X orders...",
  "user_preferences": {
    "favorite_category": "Main Course",
    "favorite_cuisine": "Indian",
    ...
  },
  "suggested_meals": [
    {
      "name": "Meal Name",
      "reason": "You loved X, you'll love this!",
      ...
    }
  ]
}
```

## Common Issues

**"Import firebase_admin could not be resolved"**
- Already installed! Just need to add `firebase_key.json`

**Backend won't start**
- Check if port 8000 is already in use
- Verify all Python packages installed

**No suggestions showing**
- Check backend terminal for errors
- Verify user has placed orders
- Test API with curl

**"Unable to load suggestions"**
- Is backend running?
- Is `firebase_key.json` present?
- Check Flutter console for error details

---

## Ready to Test? 🚀

1. Add `firebase_key.json`
2. Run `python main.py`
3. Open Flutter app
4. Place some orders
5. Check Suggestions screen
6. See personalized recommendations! 🎉
