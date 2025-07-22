import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/user.dart';
import 'api_client.dart';

class UserApiService {
  final ApiClient _apiClient;
  
  UserApiService({BuildContext? context}) : _apiClient = ApiClient(context: context);

  bool get isAuthenticated => _apiClient.isAuthenticated;

  // Map frontend enums to backend values
  String _mapHealthCondition(HealthCondition condition) {
    switch (condition) {
      case HealthCondition.adhd:
        return 'adhd';
      case HealthCondition.anxiety:
        return 'anxiety';
      case HealthCondition.depression:
        return 'depression';
      case HealthCondition.diabetes:
        return 'diabetes';
      case HealthCondition.hypertension:
        return 'hypertension';
      case HealthCondition.sleepDisorders:
        return 'sleep_disorders';
      case HealthCondition.heartDisease:
        return 'heart_disease';
      case HealthCondition.obesity:
        return 'obesity';
      case HealthCondition.none:
        return 'none';
    }
  }

  HealthCondition _mapBackendHealthCondition(String condition) {
    switch (condition.toLowerCase()) {
      case 'adhd':
        return HealthCondition.adhd;
      case 'anxiety':
        return HealthCondition.anxiety;
      case 'depression':
        return HealthCondition.depression;
      case 'diabetes':
        return HealthCondition.diabetes;
      case 'hypertension':
        return HealthCondition.hypertension;
      case 'sleep_disorders':
        return HealthCondition.sleepDisorders;
      case 'heart_disease':
        return HealthCondition.heartDisease;
      case 'obesity':
        return HealthCondition.obesity;
      case 'none':
      default:
        return HealthCondition.none;
    }
  }

  String _mapCulturalDiet(CulturalDiet diet) {
    switch (diet) {
      case CulturalDiet.mediterranean:
        return 'mediterranean';
      case CulturalDiet.asian:
        return 'asian';
      case CulturalDiet.african:
        return 'african';
      case CulturalDiet.latinAmerican:
        return 'latin_american';
      case CulturalDiet.middleEastern:
        return 'middle_eastern';
      case CulturalDiet.vegetarian:
        return 'vegetarian';
      case CulturalDiet.vegan:
        return 'vegan';
      case CulturalDiet.keto:
        return 'keto';
      case CulturalDiet.paleo:
        return 'paleo';
      case CulturalDiet.halal:
        return 'halal';
      case CulturalDiet.kosher:
        return 'kosher';
      case CulturalDiet.none:
        return 'none';
    }
  }

  CulturalDiet _mapBackendCulturalDiet(String diet) {
    switch (diet.toLowerCase()) {
      case 'mediterranean':
        return CulturalDiet.mediterranean;
      case 'asian':
        return CulturalDiet.asian;
      case 'african':
        return CulturalDiet.african;
      case 'latin_american':
        return CulturalDiet.latinAmerican;
      case 'middle_eastern':
        return CulturalDiet.middleEastern;
      case 'vegetarian':
        return CulturalDiet.vegetarian;
      case 'vegan':
        return CulturalDiet.vegan;
      case 'keto':
        return CulturalDiet.keto;
      case 'paleo':
        return CulturalDiet.paleo;
      case 'halal':
        return CulturalDiet.halal;
      case 'kosher':
        return CulturalDiet.kosher;
      case 'none':
      default:
        return CulturalDiet.none;
    }
  }

  // Gender is now a string in the UserProfile model

  // Convert user profile to backend DTO
  Map<String, dynamic> _userProfileToDto(UserProfile profile) {
    final dto = <String, dynamic>{
      'name': profile.name,
      'email': profile.email,
    };

    if (profile.age != null) {
      dto['age'] = profile.age;
    }

    if (profile.gender != null) {
      dto['gender'] = profile.gender;
    }

    if (profile.height != null) {
      dto['height'] = profile.height;
    }

    if (profile.weight != null) {
      dto['weight'] = profile.weight;
    }

    if (profile.healthConditions.isNotEmpty) {
      dto['healthConditions'] = profile.healthConditions
          .map((condition) => _mapHealthCondition(condition))
          .toList();
    }

    if (profile.culturalDietPreferences.isNotEmpty) {
      dto['culturalDietPreferences'] = profile.culturalDietPreferences
          .map((diet) => _mapCulturalDiet(diet))
          .toList();
    }

    if (profile.allergies.isNotEmpty) {
      dto['allergies'] = profile.allergies;
    }

    dto['activityLevel'] = profile.activityLevel.name;

    if (profile.preferences.isNotEmpty) {
      dto['preferences'] = profile.preferences;
    }

    return dto;
  }

  // Convert backend response to user profile
  UserProfile _dtoToUserProfile(Map<String, dynamic> data) {
    List<HealthCondition> healthConditions = [];
    if (data['healthConditions'] is List) {
      healthConditions = (data['healthConditions'] as List)
          .map((condition) => _mapBackendHealthCondition(condition as String))
          .toList();
    }

    List<CulturalDiet> culturalDietPreferences = [];
    if (data['culturalDietPreferences'] is List) {
      culturalDietPreferences = (data['culturalDietPreferences'] as List)
          .map((diet) => _mapBackendCulturalDiet(diet as String))
          .toList();
    }

    List<String> allergies = [];
    if (data['allergies'] is List) {
      allergies = (data['allergies'] as List).cast<String>();
    }

    ActivityLevel activityLevel = ActivityLevel.moderatelyActive;
    if (data['activityLevel'] != null) {
      try {
        activityLevel = ActivityLevel.values.firstWhere(
          (level) => level.name == data['activityLevel'],
        );
      } catch (e) {
        // Use default if parsing fails
      }
    }

    Map<String, dynamic> preferences = {};
    if (data['preferences'] is Map) {
      preferences = Map<String, dynamic>.from(data['preferences']);
    }

    return UserProfile(
      id: data['id']?.toString() ?? '',
      name: data['name'] as String,
      email: data['email'] as String,
      dateOfBirth: data['dateOfBirth'] != null ? DateTime.parse(data['dateOfBirth'] as String) : null,
      gender: data['gender'] as String?,
      height: data['height']?.toDouble(),
      weight: data['weight']?.toDouble(),
      healthConditions: healthConditions,
      culturalDietPreferences: culturalDietPreferences,
      activityLevel: activityLevel,
      allergies: allergies,
      preferences: preferences,
      createdAt: data['createdAt'] != null ? DateTime.parse(data['createdAt'] as String) : DateTime.now(),
      updatedAt: data['updatedAt'] != null ? DateTime.parse(data['updatedAt'] as String) : DateTime.now(),
    );
  }

  // Create user profile from Supabase user data
  Future<UserProfile> createUserProfileFromSupabase({
    required String supabaseUserId,
    required String name,
    required String email,
    String? authToken,
  }) async {
    try {
      final dto = {
        'supabaseUserId': supabaseUserId,
        'name': name,
        'email': email,
      };
      
      // Create a new API client with the specific token if provided
      final apiClient = authToken != null 
          ? ApiClient(authToken: authToken)
          : _apiClient;
      
      final response = await apiClient.post('users/profile', body: dto);

      // Handle case where backend returns success with no response body
      if (response['data'] == null) {
        throw Exception('User profile creation failed - no data returned');
      }
      return _dtoToUserProfile(response['data'] as Map<String, dynamic>);
    } catch (e) {
      if (kDebugMode) {
        print('Error creating user profile from Supabase: $e');
      }
      rethrow;
    }
  }

  // Create user profile from Clerk user data (legacy - to be removed)
  Future<UserProfile> createUserProfileFromClerk({
    required String clerkUserId,
    required String firstName,
    required String lastName,
    required String email,
    String? authToken,
  }) async {
    try {
      final dto = {
        'clerkUserId': clerkUserId,
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
      };
      
      // Create a new API client with the specific token if provided
      final apiClient = authToken != null 
          ? ApiClient(authToken: authToken)
          : _apiClient;
      
      final response = await apiClient.post('users/profile', body: dto);

      // Handle case where backend returns success with no response body
      if (response['data'] == null) {
        throw Exception('User profile creation failed - no data returned');
      }
      return _dtoToUserProfile(response['data'] as Map<String, dynamic>);
    } catch (e) {
      if (kDebugMode) {
        print('Error creating user profile from Clerk: $e');
      }
      rethrow;
    }
  }

  // Create user profile
  Future<UserProfile> createUserProfile(UserProfile profile) async {
    try {
      final dto = _userProfileToDto(profile);
      
      final response = await _apiClient.post('users/profile', body: dto);

      // Handle case where backend returns success with no response body
      if (response['data'] == null) {
        throw Exception('User profile creation failed - no data returned');
      }
      return _dtoToUserProfile(response['data'] as Map<String, dynamic>);
    } catch (e) {
      if (kDebugMode) {
        print('Error creating user profile: $e');
      }
      rethrow;
    }
  }

  // Get user profile by user ID (supports both Supabase and Clerk)
  Future<UserProfile?> getUserProfile(String userId, {String? authToken}) async {
    try {
      // Create a new API client with the specific token if provided
      final apiClient = authToken != null 
          ? ApiClient(authToken: authToken)
          : _apiClient;
      
      final response = await apiClient.authenticatedRequest(
        () => apiClient.get('users/profile/$userId'),
      );

      if (response['data'] != null && response['data'] is Map<String, dynamic>) {
        return _dtoToUserProfile(response['data'] as Map<String, dynamic>);
      }

      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching user profile: $e');
      }
      rethrow;
    }
  }

  // Get current user profile  
  Future<UserProfile?> getCurrentUserProfile([String? userId]) async {
    try {
      final currentUserId = userId ?? _apiClient.currentUserId;
      if (currentUserId == null) {
        throw Exception('No user ID provided');
      }

      return await getUserProfile(currentUserId);
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching current user profile: $e');
      }
      rethrow;
    }
  }

  // Update user profile
  Future<UserProfile> updateUserProfile(String userId, UserProfile profile) async {
    try {
      final dto = _userProfileToDto(profile);
      
      final response = await _apiClient.authenticatedRequest(
        () => _apiClient.put('users/profile/$userId', body: dto),
      );

      // Handle case where backend returns success with no response body
      if (response['data'] == null) {
        throw Exception('User profile update failed - no data returned');
      }
      return _dtoToUserProfile(response['data'] as Map<String, dynamic>);
    } catch (e) {
      if (kDebugMode) {
        print('Error updating user profile: $e');
      }
      rethrow;
    }
  }

  // Update current user profile
  Future<UserProfile> updateCurrentUserProfile(UserProfile profile, [String? userId]) async {
    try {
      if (userId == null) {
        throw Exception('No user ID provided');
      }

      return await updateUserProfile(userId, profile);
    } catch (e) {
      if (kDebugMode) {
        print('Error updating current user profile: $e');
      }
      rethrow;
    }
  }

  // Delete user profile
  Future<void> deleteUserProfile(String userId) async {
    try {
      await _apiClient.authenticatedRequest(
        () async {
          await _apiClient.delete('users/profile/$userId');
          return {};
        },
      );
      
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting user profile: $e');
      }
      rethrow;
    }
  }

  // Check if user profile exists
  Future<bool> profileExists(String userId) async {
    try {
      final profile = await getUserProfile(userId);
      return profile != null;
    } catch (e) {
      return false;
    }
  }

  // Legacy method for finding user by email (kept for backward compatibility)
  Future<UserProfile?> findUserByEmail(String email) async {
    try {
      final response = await _apiClient.post('users/me', body: {'email': email});

      if (response['data'] != null && response['data'] is Map<String, dynamic>) {
        return _dtoToUserProfile(response['data'] as Map<String, dynamic>);
      }

      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error finding user by email: $e');
      }
      return null;
    }
  }
}