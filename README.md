<div align="center">

# 🍽️ CookVision

### *Your AI-Powered Food Companion*

[![Flutter](https://img.shields.io/badge/Flutter-3.8.1-02569B?logo=flutter)](https://flutter.dev)
[![Python](https://img.shields.io/badge/Python-3.13-3776AB?logo=python)](https://python.org)
[![FastAPI](https://img.shields.io/badge/FastAPI-Latest-009688?logo=fastapi)](https://fastapi.tiangolo.com)
[![License](https://img.shields.io/badge/License-Educational-blue)](LICENSE)

*A smart food ordering app that combines AI-powered chat, real-time weather suggestions, and visual food recognition*

[Features](#-features) • [Tech Stack](#-tech-stack) • [Setup](#-setup) • [API Docs](#-api-endpoints) • [Screenshots](#-screenshots)

</div>

---

## ✨ Features

<table>
<tr>
<td width="50%">

### 🤖 **AI Chat Assistant**
Talk to your food concierge in natural language
- Powered by **Google Gemini 2.0 Flash**
- Remembers your preferences across sessions
- Smart product recommendations
- Multi-turn conversations with context

</td>
<td width="50%">

### 🌤️ **Weather Intelligence**
Food that matches the weather
- Real-time location detection
- Weather-based meal suggestions
- City-level accuracy
- Automatic recommendation updates

</td>
</tr>
<tr>
<td width="50%">

### 📸 **Food Scanner**
Visual food recognition at your fingertips
- Capture or upload from gallery
- Quick image preview
- AI-powered analysis *(coming soon)*
- Smart ingredient detection

</td>
<td width="50%">

### 🍕 **Smart Menu**
Browse with confidence
- Calorie & nutrition tracking
- Dietary filters (Veg/Non-Veg/Vegan)
- Price & rating insights
- One-tap ordering

</td>
</tr>
</table>

---

## 🛠️ Tech Stack

### **Frontend**
```
Flutter 3.8.1
├── UI Framework: Material Design 3
├── State Management: Provider
├── Theme: Custom dark gradients
└── Packages:
    ├── http (API communication)
    ├── image_picker (Camera/Gallery)
    ├── geolocator & geocoding (Location)
    └── intl (Date formatting)
```

### **Backend**
```
Python 3.13 + FastAPI
├── AI/ML:
│   ├── Google Gemini 2.0 Flash
│   ├── LangChain (AI orchestration)
│   ├── DeepAgents (Agentic workflows)
│   └── LangGraph (Memory management)
├── Database: SQLite (Chat persistence)
└── Tools:
    ├── Product search
    ├── Price filters
    ├── Dietary preferences
    └── Category sorting
```

## Setup

### Prerequisites
- Flutter SDK 3.8.1 or higher
- Python 3.13
- Google Gemini API key
- OpenWeather API key (optional)

### Backend Setup

1. **Clone and navigate to the project**
   ```bash
   cd food_app
   ```

2. **Install Python dependencies**
   ```bash
   pip install fastapi uvicorn langchain-google-genai langgraph-checkpoint-sqlite deepagents python-dotenv requests
   ```

3. **Create `.env` file**
   ```
   GOOGLE_API_KEY=your_gemini_api_key_here
   ```

4. **Prepare data files**
   - Ensure `products.json` exists in the project root
   - Sample structure:
     ```json
     [
       {
         "id": "1",
         "name": "Pizza",
         "price": 299,
         "cuisine": "Italian",
         "category": "Main Course",
         "dietary": "Vegetarian",
         "description": "Delicious cheese pizza",
         "rating": 4.5,
         "spice_level": "Medium",
         "tags": ["comfort food", "cheesy"]
       }
     ]
     ```

5. **Run the server**
   ```bash
   python3 -m uvicorn main:app --reload
   ```
   Server will start at `http://localhost:8000`

### Flutter Setup

1. **Install dependencies**
   ```bash
   flutter pub get
   ```

2. **Configure iOS Permissions** (in `ios/Runner/Info.plist`)
   ```xml
   <key>NSLocationWhenInUseUsageDescription</key>
   <string>We need your location to provide weather-based food suggestions</string>
   <key>NSCameraUsageDescription</key>
   <string>Take photos of your food</string>
   <key>NSPhotoLibraryUsageDescription</key>
   <string>Choose photos from your library</string>
   ```

3. **Configure Android Permissions** (in `android/app/src/main/AndroidManifest.xml`)
   ```xml
   <uses-permission android:name="android.permission.INTERNET"/>
   <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
   <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
   <uses-permission android:name="android.permission.CAMERA"/>
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

## API Endpoints

### Food Query
```
GET /food_query/{user_input}?session_id={session_id}
```
Search for food using natural language. Returns AI response with matching products.

### Weather
```
GET /weather/{city}
```
Get current weather for a city.

### Suggestions
```
GET /suggestions/{weather}
```
Get food suggestions based on weather conditions.

### Health Check
```
GET /health
```
Check if the server is running.

## Project Structure

```
food_app/
├── lib/
│   ├── main.dart           # App entry point
│   ├── MainScreen.dart     # Home screen with weather & scanner
│   ├── chat.dart           # AI chat interface
│   └── food_screen.dart    # Menu browser
├── assets/
│   └── image.png           # Placeholder images
├── main.py                 # FastAPI backend server
├── products.json           # Food database
├── checkpoints.sqlite      # Chat history database
└── pubspec.yaml            # Flutter dependencies
```

## Configuration

### Update Backend URL
If running on a physical device, update the API URL in Flutter files:
```dart
// Change from:
'http://localhost:8000/...'

// To your computer's IP:
'http://192.168.1.x:8000/...'
```

### Modify Theme Colors
Main color palette in `MainScreen.dart`, `chat.dart`, and `food_screen.dart`:
- Primary: `#667eea` → `#764ba2` (Purple gradient)
- Background: `#1a1a2e` → `#0f3460` (Dark gradient)
- Accent: `#2a2d3a` (Dark slate)

## Memory System

The chat uses SQLite-based persistence:
- Each conversation has a unique `session_id`
- Messages are stored in `checkpoints.sqlite`
- Context is maintained across app restarts
- Clear individual sessions via session management

## Contributing

Feel free to submit issues and enhancement requests!

## License

This project is for educational purposes.

## Contact

Created by [@khanak0509](https://github.com/khanak0509)

---

**Note**: Make sure both the Flutter app and Python backend are running simultaneously for full functionality.
