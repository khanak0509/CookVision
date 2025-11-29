# CookVision 🍽️

A smart food ordering app that combines AI-powered chat, real-time weather-based food suggestions, and food recognition capabilities.

## Features

### 🤖 AI Chat Assistant
- Natural language food search powered by Google Gemini
- Memory-enabled conversations that remember your preferences
- Get personalized food recommendations through chat

### 🌤️ Weather-Based Suggestions
- Real-time weather detection using your location
- Smart food suggestions based on current weather conditions
- Location tracking with city-level accuracy

### 📸 Food Scanner
- Capture or upload food images from your gallery
- Visual food recognition (analyze feature coming soon)
- Quick image preview and management

### 🍕 Menu Browser
- Browse popular meals with calorie information
- View nutritional stats (calories, protein, carbs)
- Add items to your order with one tap

## Tech Stack

### Frontend (Flutter)
- **Framework**: Flutter 3.8.1
- **UI**: Custom dark theme with gradient designs
- **Key Packages**:
  - `http` - API communication
  - `image_picker` - Camera/gallery access
  - `geolocator` & `geocoding` - Location services
  - `intl` - Date formatting

### Backend (Python/FastAPI)
- **Framework**: FastAPI
- **AI/ML**:
  - LangChain with Google Gemini 2.0 Flash
  - DeepAgents for agentic workflows
  - LangGraph for conversation memory
- **Database**: SQLite for chat history persistence
- **Tools**: Multiple search filters (price, category, dietary preferences)

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
