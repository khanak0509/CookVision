# 🚀 Quick Reference: Chat History Functions

## Main Functions in chat.dart

### 1. `_loadChatHistory()` - Load Previous Chats
```dart
// Called in initState() when screen opens
// Fetches last 20 chats from Firestore for current user
// Updates _messages list and UI

When: Screen opens
What: Gets user's chat history
Where: Firestore: users/{userId}/chats
```

### 2. `sendMessage()` - Send & Save Message
```dart
// Called when user hits send button
// 1. Shows user message in UI
// 2. Calls backend API
// 3. Shows bot response in UI
// 4. Saves to Firestore

When: User sends message
What: API call + Save to Firebase
Where: Backend API + Firestore
```

### 3. `_saveChatToFirestore()` - Save Conversation
```dart
// Called after getting bot response
// Saves user message + bot response + products
// Uses .add() to create new document

When: After bot responds
What: Saves entire conversation
Where: Firestore: users/{userId}/chats/{auto-id}
```

---

## Data Flow Diagram

```
User Opens Chat
       ↓
  initState()
       ↓
_loadChatHistory()
       ↓
   Firestore
    (read)
       ↓
 Show messages
       ↓
User sends message
       ↓
  sendMessage()
       ↓
 Backend API
       ↓
 Get response
       ↓
_saveChatToFirestore()
       ↓
   Firestore
    (write)
       ↓
   Complete!
```

---

## Firestore Queries Used

### Read (Load History)
```dart
FirebaseFirestore.instance
  .collection('users')
  .doc(userId)
  .collection('chats')
  .orderBy('timestamp', descending: false)
  .limit(20)
  .get()
```

### Write (Save Chat)
```dart
FirebaseFirestore.instance
  .collection('users')
  .doc(userId)
  .collection('chats')
  .add({
    'user_message': "...",
    'bot_response': "...",
    'products': [...],
    'timestamp': FieldValue.serverTimestamp(),
  })
```

---

## Testing Checklist

- [ ] User can see loading spinner when opening chat
- [ ] Previous messages show when chat loads
- [ ] New messages save to Firestore
- [ ] Firestore Console shows saved chats
- [ ] Each user sees only their own chats
- [ ] Timestamps are correct
- [ ] Products array saves properly
- [ ] Empty state shows when no history

---

## Debugging Commands

```dart
// Check if user is logged in
print('User ID: $userId');

// Check chat count
print('Messages: ${_messages.length}');

// Check Firestore save
print('✅ Chat saved to Firestore');

// Check loaded chats
print('✅ Loaded ${snapshot.docs.length} chats');
```

---

## Common Variables

```dart
userId          // Current user's Firebase Auth UID
_messages       // List of all messages in UI
_isLoading      // Is bot responding?
_isLoadingHistory // Is history loading?
_sessionId      // Backend API session ID
_controller     // Text input controller
```

---

## File Structure

```
lib/
├── chat.dart            ← Main chat screen (EDITED)
├── models/
│   └── message.dart     ← (Optional) Message model
└── services/
    └── chat_service.dart ← (Optional) Separate service
```

Your implementation is all in `chat.dart` - simple and clean!

---

## Quick Commands

### View Firestore Data
```
Firebase Console → Firestore Database → users → {uid} → chats
```

### Test Locally
```bash
# Start backend
cd /Users/khanak/Desktop/food_app/food_app
python main.py

# Run Flutter
flutter run
```

### Check Logs
```dart
// In terminal, look for:
✅ Loaded 5 previous chats
✅ Chat saved to Firestore
📡 API Response: ...
🤖 Bot response: ...
```

---

That's it! Your chat history is working! 🎉
