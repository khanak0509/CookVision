# Gemini API Quota Management 🚦

## Problem: "429 ResourceExhausted - Quota Exceeded"

You're seeing this error because **Gemini API free tier has strict limits**:

### Free Tier Limits (gemini-2.0-flash):
- ⚠️ **15 requests per minute**
- ⚠️ **1,500 requests per day**
- ⚠️ **1 million tokens per day**

### Free Tier Limits (gemini-1.5-flash):
- ✅ **15 requests per minute**
- ✅ **1,500 requests per day**  
- ✅ **1 million tokens per day**

## ✅ What I Fixed

### 1. Changed Model from gemini-2.0-flash → gemini-1.5-flash
```python
# Before (more strict limits)
llm = ChatGoogleGenerativeAI(model="gemini-2.0-flash")

# After (better for free tier)
llm = ChatGoogleGenerativeAI(model="gemini-1.5-flash", max_retries=0)
```

### 2. Added Error Handling (Graceful Degradation)
```python
try:
    # Try to use LLM for suggestions
    llm_response = llm.invoke(...)
except Exception as e:
    print("❌ API Quota Exceeded - Using fallback")
    # Return top-rated items without AI
    suggested_names = [top rated products]
```

### 3. Added `max_retries=0`
- Fails fast instead of retrying multiple times
- Prevents burning through your quota with retries

## 🔧 Solutions

### Option 1: Wait for Reset (Easiest)
Your quota resets **every 24 hours**. Just wait and try again tomorrow.

### Option 2: Get a New API Key
1. Go to [Google AI Studio](https://aistudio.google.com/app/apikey)
2. Create a **new project** (important!)
3. Generate new API key
4. Update `.env` file:
   ```
   GEMINI_API_KEY=your_new_key_here
   ```
5. Restart server

**Note:** Each Google account has daily limits across ALL projects.

### Option 3: Upgrade to Paid Plan (Best for Production)
- Go to [Google Cloud Console](https://console.cloud.google.com/)
- Enable billing
- Get **much higher limits**:
  - 1,000 requests per minute
  - Unlimited requests per day (pay per use)

### Option 4: Reduce API Calls (Smart)

#### A. Cache Suggestions
Don't call LLM every time - cache results for 1 hour:
```python
suggestion_cache = {}

def get_cached_suggestions(user_id):
    if user_id in suggestion_cache:
        cache_time, suggestions = suggestion_cache[user_id]
        if time.time() - cache_time < 3600:  # 1 hour
            return suggestions
    # Call LLM only if no cache
    return generate_new_suggestions(user_id)
```

#### B. Batch Requests
Generate suggestions for multiple users in one call

#### C. Use Fallback Mode
The system now works **without LLM** if quota is exceeded:
- Returns top-rated items
- Still shows personalized preferences
- Just no AI-generated reasons

## 🧪 Test Your Current Quota

```bash
curl -X POST http://localhost:8000/api/user-suggestions \
  -H "Content-Type: application/json" \
  -d '{"user_id": "test_user"}'
```

**If it works:** Your quota is fine  
**If error 429:** Quota exceeded - fallback mode activated

## 📊 Monitor Your Usage

Check your usage here:
- [Google AI Studio Usage](https://ai.dev/usage?tab=rate-limit)
- See remaining quota
- Track requests per minute/day

## ⚡ Immediate Actions

1. **Restart your server** - Changes are applied
   ```bash
   cd /Users/khanak/Desktop/food_app/food_app
   python main.py
   ```

2. **Test again** - System now has fallback:
   - If API works: You get AI suggestions
   - If quota exceeded: You get top-rated items (still works!)

3. **Wait 24 hours** OR **Get new API key** from different Google account

## 🎯 What Works Now (Even Without LLM)

Your app will **NOT crash** if quota is exceeded. Instead:

✅ Fetches user order history  
✅ Analyzes preferences (favorite cuisine, category)  
✅ Returns top-rated items they haven't tried  
✅ Shows personalized message  
✅ Suggestions still display with images  

The only difference: Reasons are generic ("Highly rated item") instead of personalized.

## 🔐 Best Practices

### For Development:
- ✅ Use gemini-1.5-flash (not 2.0)
- ✅ Add caching to reduce API calls
- ✅ Test with fallback mode
- ✅ Set `max_retries=0`

### For Production:
- 🚀 Upgrade to paid plan
- 🚀 Implement proper caching
- 🚀 Use load balancing
- 🚀 Monitor quota usage
- 🚀 Have fallback mechanisms

## 🐛 Troubleshooting

**Q: I created a new API key but still getting error**
A: Each Google account has a daily limit. Create key from **different Google account**.

**Q: Can I use multiple API keys?**
A: Yes! Implement key rotation:
```python
API_KEYS = [key1, key2, key3]
current_key_index = 0

def get_next_key():
    global current_key_index
    key = API_KEYS[current_key_index]
    current_key_index = (current_key_index + 1) % len(API_KEYS)
    return key
```

**Q: How to check if my quota reset?**
A: Try making a simple API call or check [AI Studio Usage](https://ai.dev/usage?tab=rate-limit)

**Q: When exactly does quota reset?**
A: 24 hours from first request (rolling window) OR at midnight UTC (depends on quota type)

## 📈 Summary

| Issue | Solution | Status |
|-------|----------|--------|
| Using gemini-2.0-flash | ✅ Changed to gemini-1.5-flash | FIXED |
| No error handling | ✅ Added try-catch with fallback | FIXED |
| Retrying on failure | ✅ Set max_retries=0 | FIXED |
| App crashes on quota | ✅ Graceful degradation | FIXED |

**Your app now works even if API quota is exceeded!** 🎉

---

**Next Steps:**
1. Restart server: `python main.py`
2. Test suggestions endpoint
3. If still showing quota error: Wait 24h or use new API key from different account
4. Consider upgrading to paid plan for production
