import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:food_app/chat.dart';
import 'package:food_app/food_screen.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  File? _image;
  String weather = "Loading weather...";
  Position? _currentPosition;
  String _currentCity = "Loading...";
  Stream<Position>? positionStream;

  @override
  void initState() {
    super.initState();
    _startLiveLocation();
    
  
  }

  // Pick image from gallery
  Future pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile == null) return;

    setState(() {
      _image = File(pickedFile.path);
    });
  }

  // Fetch weather from API
void getWeather({required String city}) async {
  final url = Uri.parse('http://localhost:8000/weather/$city');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);

    if (data != null && data['description'] != null && data['temperature'] != null) {
      setState(() {
        weather = "${data['description']}, ${data['temperature']}°C";
      });
    } else {
      setState(() {
        weather = "Weather data missing in API";
      });
    }
  } else {
    setState(() {
      weather = "Failed to load weather (Code ${response.statusCode})";
    });
  }
}

  // Start live location tracking
  Future<void> _startLiveLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    if (permission == LocationPermission.deniedForever) return;

    positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 5,
      ),
    );

    positionStream!.listen((Position position) async {
      String city = await _getCityFromCoordinates(position.latitude, position.longitude);
      setState(() {
        _currentPosition = position;
        _currentCity = city;
      });
      if (city != "Unknown City" && city.isNotEmpty) {
        getWeather(city: city);
      }
    });
  }

  // Get city from coordinates
  Future<String> _getCityFromCoordinates(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng, localeIdentifier: "en_IN");
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        return place.locality ?? "Unknown City";
      }
      return "Unknown City";
    } catch (e) {
      return "Error: $e";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 86, 4, 210),
        title: const Text('Welcome to the Food App!'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              weather,
              style: const TextStyle(color: Colors.white, fontSize: 20),
            ),
            const SizedBox(height: 20),
            _currentPosition != null
                ? Text(
                    "Lat: ${_currentPosition!.latitude.toStringAsFixed(5)}, "
                    "Lng: ${_currentPosition!.longitude.toStringAsFixed(5)}\n"
                    "City: $_currentCity",
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                    textAlign: TextAlign.center,
                  )
                : const Text(
                    "Getting location...",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
            const SizedBox(height: 20),
            _image == null
                ? const Text(
                    "No Image Selected",
                    style: TextStyle(color: Colors.white),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.file(
                      _image!,
                      height: 250,
                      width: 250,
                      fit: BoxFit.cover,
                    ),
                  ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: pickImage,
              child: const Text("Pick Image"),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Chat()),
                    );
                  },
                  child: const Text('Chat'),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => FoodScreen()));
                  },
                  child: const Text('Another Action'),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
        child: BottomNavigationBar(
          backgroundColor: const Color.fromARGB(255, 7, 19, 29),
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white54,
          currentIndex: 0,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
            BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Chat"),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          ],
        ),
      ),
    );
  }
}
