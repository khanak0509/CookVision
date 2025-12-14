import 'package:flutter/material.dart';

class AnimationConstants {
  // Optimized Durations for low-end devices
  static const Duration veryFast = Duration(milliseconds: 100); // For micro-interactions
  static const Duration fast = Duration(milliseconds: 150);     // Button presses, taps
  static const Duration normal = Duration(milliseconds: 250);   // Standard transitions (reduced from 300ms)
  static const Duration slow = Duration(milliseconds: 400);     // Complex animations (reduced from 500ms)
  
  // Page Transition Duration (optimized)
  static const Duration pageTransition = Duration(milliseconds: 250); // Reduced from 300ms
  
  // Loading Duration
  static const Duration loading = Duration(milliseconds: 800); // Reduced from 1000ms
  
  // Optimized Curves for low-end devices (use native curves for better performance)
  static const Curve easeInOut = Curves.easeInOut;  // Hardware accelerated
  static const Curve easeOut = Curves.easeOut;      // Hardware accelerated
  static const Curve easeIn = Curves.easeIn;        // Hardware accelerated
  static const Curve linear = Curves.linear;        // Most performant
  
  // Avoid expensive curves on low-end devices
  // Use easeOut instead of easeOutCubic for better performance
  static const Curve defaultCurve = Curves.easeOut;
  
  // Stagger duration for list animations
  static const Duration staggerDelay = Duration(milliseconds: 50);
  
  // Debounce duration for preventing animation spam
  static const Duration debounce = Duration(milliseconds: 300);
}
