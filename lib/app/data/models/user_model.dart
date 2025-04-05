import 'dart:convert';

import 'package:flutter/material.dart';

enum SubscriptionType { free, premium, pro }

class User {
  final String id;
  final String email;
  final String? fullName;
  final String? photoUrl;
  final SubscriptionType subscriptionType;
  final DateTime? subscriptionExpiryDate;
  final List<String> savedFlights;
  final List<String> recentSearches;
  final Map<String, dynamic> preferences;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.email,
    this.fullName,
    this.photoUrl,
    this.subscriptionType = SubscriptionType.free,
    this.subscriptionExpiryDate,
    this.savedFlights = const [],
    this.recentSearches = const [],
    this.preferences = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  User copyWith({
    String? id,
    String? email,
    String? fullName,
    String? photoUrl,
    SubscriptionType? subscriptionType,
    DateTime? subscriptionExpiryDate,
    List<String>? savedFlights,
    List<String>? recentSearches,
    Map<String, dynamic>? preferences,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      photoUrl: photoUrl ?? this.photoUrl,
      subscriptionType: subscriptionType ?? this.subscriptionType,
      subscriptionExpiryDate: subscriptionExpiryDate ?? this.subscriptionExpiryDate,
      savedFlights: savedFlights ?? this.savedFlights,
      recentSearches: recentSearches ?? this.recentSearches,
      preferences: preferences ?? this.preferences,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'fullName': fullName,
      'photoUrl': photoUrl,
      'subscriptionType': subscriptionType.toString().split('.').last,
      'subscriptionExpiryDate': subscriptionExpiryDate?.toIso8601String(),
      'savedFlights': savedFlights,
      'recentSearches': recentSearches,
      'preferences': preferences,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    // Handle different naming schemes (camelCase vs snake_case)
    return User(
      id: json['id'],
      email: json['email'] ?? json['email_address'] ?? '',
      fullName: json['fullName'] ?? json['full_name'],
      photoUrl: json['photoUrl'] ?? json['photo_url'],
      subscriptionType: _parseSubscriptionType(json['subscriptionType'] ?? json['subscription_type']),
      subscriptionExpiryDate: json['subscriptionExpiryDate'] != null
          ? DateTime.parse(json['subscriptionExpiryDate'])
          : json['subscription_expiry_date'] != null
              ? DateTime.parse(json['subscription_expiry_date'])
              : null,
      savedFlights: _parseSavedFlights(json),
      recentSearches: _parseRecentSearches(json),
      preferences: json['preferences'] ?? json['user_preferences'] ?? {},
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : json['updated_at'] != null
              ? DateTime.parse(json['updated_at'])
              : DateTime.now(),
    );
  }

  // Helper method to safely parse saved flights from various formats
  static List<String> _parseSavedFlights(Map<String, dynamic> json) {
    try {
      if (json['savedFlights'] != null) {
        return List<String>.from(json['savedFlights']);
      } else if (json['saved_flights'] != null) {
        // Handle array of flight numbers
        if (json['saved_flights'] is List) {
          return List<String>.from(json['saved_flights']);
        }
        // Handle nested relation data
        else if (json['saved_flights'] is Map && json['saved_flights']['data'] != null) {
          final flightData = json['saved_flights']['data'] as List;
          return flightData.map((flight) => flight['flight_number'].toString()).toList();
        }
      }
      return [];
    } catch (e) {
      print('Error parsing saved flights: $e');
      return [];
    }
  }

  // Helper method to safely parse recent searches from various formats
  static List<String> _parseRecentSearches(Map<String, dynamic> json) {
    try {
      if (json['recentSearches'] != null) {
        return List<String>.from(json['recentSearches']);
      } else if (json['recent_searches'] != null) {
        if (json['recent_searches'] is List) {
          return List<String>.from(json['recent_searches']);
        } else if (json['recent_searches'] is String) {
          // Handle case where it might be a JSON string
          try {
            final parsed = jsonDecode(json['recent_searches']);
            if (parsed is List) {
              return List<String>.from(parsed);
            }
          } catch (_) {
            // If not valid JSON, return empty list
          }
        }
      }
      return [];
    } catch (e) {
      print('Error parsing recent searches: $e');
      return [];
    }
  }

  // Check if the user has a premium subscription
  bool get isPremium => subscriptionType == SubscriptionType.premium || subscriptionType == SubscriptionType.pro;

  // Check if the user has a pro subscription
  bool get isPro => subscriptionType == SubscriptionType.pro;

  // Check if the subscription is active
  bool get hasActiveSubscription =>
      subscriptionType != SubscriptionType.free &&
      (subscriptionExpiryDate == null || DateTime.now().isBefore(subscriptionExpiryDate!));

  // Helper method to parse subscription type from string
  static SubscriptionType _parseSubscriptionType(String? type) {
    switch (type) {
      case 'premium':
        return SubscriptionType.premium;
      case 'pro':
        return SubscriptionType.pro;
      default:
        return SubscriptionType.free;
    }
  }

  // Get appropriate icon for subscription type
  IconData get subscriptionIcon {
    switch (subscriptionType) {
      case SubscriptionType.premium:
        return Icons.star;
      case SubscriptionType.pro:
        return Icons.workspace_premium;
      default:
        return Icons.person;
    }
  }

  // Create a new user from Supabase auth data
  factory User.fromSupabaseAuth(Map<String, dynamic> data) {
    final now = DateTime.now();
    return User(
      id: data['id'],
      email: data['email'],
      fullName: data['user_metadata']?['full_name'],
      photoUrl: null,
      subscriptionType: SubscriptionType.free,
      savedFlights: [],
      recentSearches: [],
      preferences: {},
      createdAt: now,
      updatedAt: now,
    );
  }
}
