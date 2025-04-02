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
    return User(
      id: json['id'],
      email: json['email'],
      fullName: json['fullName'],
      photoUrl: json['photoUrl'],
      subscriptionType: _parseSubscriptionType(json['subscriptionType']),
      subscriptionExpiryDate: json['subscriptionExpiryDate'] != null 
          ? DateTime.parse(json['subscriptionExpiryDate']) 
          : null,
      savedFlights: json['savedFlights'] != null 
          ? List<String>.from(json['savedFlights']) 
          : [],
      recentSearches: json['recentSearches'] != null 
          ? List<String>.from(json['recentSearches']) 
          : [],
      preferences: json['preferences'] ?? {},
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : DateTime.now(),
    );
  }
  
  // Check if the user has a premium subscription
  bool get isPremium => 
      subscriptionType == SubscriptionType.premium || 
      subscriptionType == SubscriptionType.pro;
      
  // Check if the user has a pro subscription  
  bool get isPro => subscriptionType == SubscriptionType.pro;
  
  // Check if the subscription is active
  bool get hasActiveSubscription =>
      subscriptionType != SubscriptionType.free &&
      (subscriptionExpiryDate == null || 
       DateTime.now().isBefore(subscriptionExpiryDate!));
       
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
