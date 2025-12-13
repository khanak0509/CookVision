# 🍽️ Suggestions Screen - Implementation Guide

## 📋 Overview
A beautiful weather-based food suggestions screen that matches CookVision's dark gradient UI theme.

## ✨ Features Implemented

### 1. **Weather-Based UI**
- Displays current city and weather conditions
- Beautiful gradient card with weather icon
- Refresh button to reload suggestions

### 2. **AI Suggestion Card**
- Prominent card showing AI-powered recommendations
- Brain icon with gradient background
- Contextual message based on weather

### 3. **Recommended Meals Grid**
- Beautiful meal cards with:
  - Emoji/image placeholder
  - Meal name and description
  - Preparation time, calories, rating chips
  - Add to cart button
  - Tap to view details

### 4. **Meal Details Bottom Sheet**
- Large emoji display
- Category badge
- Full description
- Stats (time, calories, rating)
- Action buttons (Start Cooking, Add to Cart)

### 5. **Smooth Animations**
- Fade-in animation when data loads
- Loading state with spinner
- Smooth transitions

## 🎨 UI Design Elements

### Color Scheme (Matches Your Style)
- **Background Gradient**: `#1a1a2e` → `#16213e` → `#0f3460`
- **Card Background**: `#2a2d3a`
- **Primary Gradient**: `#667eea` → `#764ba2`
- **Text**: White with varying opacity

### Components Used
- Gradient containers
- Rounded corners (12-20px)
- Subtle shadows
- Icon chips for stats
- Modal bottom sheets

## 🔌 Backend Integration TODO

### 1. API Endpoint Needed
```dart
GET http://localhost:8000/suggestions/{weather}

Response:
{
  "suggestions": "AI-generated text...",
  "meals": [
    {
      "id": "meal_123",
      "name": "Spicy Ramen Bowl",
      "description": "Hot noodle soup...",
      "prep_time": "25 min",
      "calories": "450",
      "rating": 4.8,
      "category": "Soup",
      "image_url": "https://...",
      "ingredients": [...],
      "steps": [...]
    }
  ]
}
```

### 2. Functions to Connect

#### Line 53: `_loadSuggestions()`
```dart
// Replace mock data with:
final url = Uri.parse('http://localhost:8000/suggestions/${widget.weather}');
final response = await http.get(url);

if (response.statusCode == 200) {
  final data = jsonDecode(response.body);
  setState(() {
    _aiSuggestion = data['suggestions'] ?? '';
    _recommendedMeals = List<Map<String, dynamic>>.from(data['meals'] ?? []);
    _isLoading = false;
  });
}
```

#### Line 122: `_addToCart()`
```dart
// Uncomment and use:
Future<void> _addToCart(Map<String, dynamic> meal) async {
  final userId = authservice.value.currentUser?.uid;
  if (userId == null) return;
  
  await FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('cart_items')
      .doc(meal['id'])
      .set(meal);
}

// Then update line 468:
onTap: () {
  _addToCart(meal);
  _showAddedToCartSnackbar(meal['name']);
}
```

### 3. Navigate to Cooking Mode

#### Line 483: Meal details tap
```dart
onTap: () {
  Navigator.pop(context);
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => CookingMode(
        mealId: meal['id'],
        mealName: meal['name'],
      ),
    ),
  );
}
```

### 4. Image Loading
Replace emoji placeholders with network images:
```dart
// Change from:
child: Text(meal['image'] ?? '🍽️', ...)

// To:
child: Image.network(
  meal['image_url'],
  fit: BoxFit.cover,
  errorBuilder: (context, error, stackTrace) {
    return const Icon(Icons.restaurant, size: 40, color: Colors.white);
  },
)
```

## 📱 How to Navigate

### From MainScreen
The weather card is now tappable and navigates to suggestions screen:

```dart
// MainScreen.dart - Line 202
GestureDetector(
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SuggestionsScreen(
          weather: weather,
          city: _currentCity,
        ),
      ),
    );
  },
  child: Container(...) // Weather card
)
```

## 🎯 Usage Flow

1. **User opens app** → MainScreen shows weather card
2. **User taps weather card** → Navigates to SuggestionsScreen
3. **Screen loads** → Shows loading spinner
4. **Data arrives** → Fade-in animation displays:
   - AI suggestion card
   - Grid of recommended meals
5. **User taps meal card** → Bottom sheet with full details
6. **User taps "Start Cooking"** → Navigate to CookingMode
7. **User taps cart icon** → Add meal to Firebase cart

## 🔧 Mock Data

Currently using mock data in `_loadSuggestions()`:
- 4 sample meals with different categories
- Realistic prep times, calories, ratings
- Emoji placeholders for images
- 2-second delay to simulate API call

**Remove this when connecting to real backend!**

## 📝 Comments Guide

All areas requiring backend connection are marked with:
- `// TODO: Replace with actual API call`
- `// TODO: Implement add to cart`
- `// TODO: Navigate to cooking mode`
- `// TODO: Add function to save meal to cart`

## 🚀 Next Steps

1. ✅ Create backend endpoint for weather-based suggestions
2. ✅ Connect `_loadSuggestions()` to real API
3. ✅ Upload meal images to Firebase Storage
4. ✅ Implement add to cart functionality
5. ✅ Connect to existing CookingMode screen
6. ✅ Add Firebase Analytics events
7. ✅ Test with different weather conditions

## 🎨 Customization Options

### Adjust Animation Speed
```dart
// Line 43
duration: const Duration(milliseconds: 800), // Change this
```

### Change Gradient Colors
```dart
// Line 257 - Weather card gradient
gradient: const LinearGradient(
  colors: [Color(0xFF667eea), Color(0xFF764ba2)], // Modify colors
),
```

### Modify Loading Delay
```dart
// Line 66 (mock data)
await Future.delayed(const Duration(seconds: 2)); // Adjust delay
```

---

**Created**: December 2025  
**File**: `lib/suggestions_screen.dart`  
**Status**: Ready for backend integration ✨
