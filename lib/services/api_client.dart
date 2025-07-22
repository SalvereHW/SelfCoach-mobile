import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../state/auth.dart' as app_auth;

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  ApiException(this.message, {this.statusCode, this.data});

  @override
  String toString() => 'ApiException: $message';
}

class ApiClient {
  static const String baseUrl = kDebugMode
      ? 'http://localhost:3000/api/'  // Back to localhost for testing
      : 'https://selfcoach-backend.onrender.com/api/';  // Production

  late final Dio _dio;
  BuildContext? _context;
  String? _overrideToken;
  
  // Throttling for connection checks
  DateTime? _lastConnectionCheck;
  bool? _lastConnectionResult;
  static const Duration _connectionCheckThrottle = Duration(seconds: 30);

  ApiClient({BuildContext? context, String? authToken}) {
    _context = context;
    _overrideToken = authToken;
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      // Don't set any default headers to avoid preflight
    ));

    // Add interceptor for authentication and headers
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = _authToken;
        if (token != null) {
          // Use Authorization header for simplicity - if this causes preflight, we'll move to query params
          options.headers['Authorization'] = 'Bearer $token';
        }
        
        // Only convert to query parameters for GET requests to avoid preflight
        // For POST/PATCH/PUT, preserve JSON body to maintain data types
        if (options.data != null && options.data is Map<String, dynamic> && options.method == 'GET') {
          final data = options.data as Map<String, dynamic>;
          options.queryParameters.addAll(data.map((k, v) => MapEntry(k, v.toString())));
          options.data = null;  // Remove body data for GET requests
        }
        
        if (kDebugMode) {
          print('${options.method}: ${options.uri}');
          print('Headers: ${options.headers}');
          print('Query params: ${options.queryParameters}');
        }
        
        handler.next(options);
      },
      onResponse: (response, handler) {
        if (kDebugMode) {
          print('Response: ${response.statusCode} ${response.statusMessage}');
        }
        handler.next(response);
      },
      onError: (error, handler) {
        if (kDebugMode) {
          print('Request failed: ${error.message}');
          print('Error type: ${error.type}');
          print('Response: ${error.response?.statusCode} ${error.response?.statusMessage}');
        }
        handler.next(error);
      },
    ));
  }

  // Get the current session token from context or override
  String? get _authToken {
    // Use override token first if provided
    if (_overrideToken != null) {
      return _overrideToken;
    }
    
    if (_context != null && _context!.mounted) {
      try {
        final authState = Provider.of<app_auth.AppAuthState>(_context!, listen: false);
        return authState.sessionToken;
      } catch (e) {
        if (kDebugMode) {
          print('Error getting auth token: $e');
        }
      }
    }
    return null;
  }

  // Check if user is authenticated
  bool get isAuthenticated {
    if (_context != null && _context!.mounted) {
      try {
        final authState = Provider.of<app_auth.AppAuthState>(_context!, listen: false);
        final authenticated = authState.isAuthenticated;
        if (kDebugMode) {
          print('API Client auth check: $authenticated (status: ${authState.status})');
          print('Auth token available: ${_authToken != null}');
        }
        return authenticated;
      } catch (e) {
        if (kDebugMode) {
          print('Error checking auth status: $e');
        }
      }
    }
    if (kDebugMode) {
      print('API Client: No valid context available for auth check');
    }
    return false;
  }

  // Generic GET request
  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, String>? queryParams,
    Duration? timeout,
  }) async {
    try {
      final response = await _dio.get(
        endpoint,
        queryParameters: queryParams,
        options: Options(
          sendTimeout: timeout,
          receiveTimeout: timeout,
        ),
      );

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Generic POST request
  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? queryParams,
    Duration? timeout,
  }) async {
    try {
      final response = await _dio.post(
        endpoint,
        data: body,
        queryParameters: queryParams,
        options: Options(
          sendTimeout: timeout,
          receiveTimeout: timeout,
        ),
      );

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Generic PUT request
  Future<Map<String, dynamic>> put(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? queryParams,
    Duration? timeout,
  }) async {
    try {
      final response = await _dio.put(
        endpoint,
        data: body,
        queryParameters: queryParams,
        options: Options(
          sendTimeout: timeout,
          receiveTimeout: timeout,
        ),
      );

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Generic PATCH request
  Future<Map<String, dynamic>> patch(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? queryParams,
    Duration? timeout,
  }) async {
    try {
      final response = await _dio.patch(
        endpoint,
        data: body,
        queryParameters: queryParams,
        options: Options(
          sendTimeout: timeout,
          receiveTimeout: timeout,
        ),
      );

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Generic DELETE request
  Future<Map<String, dynamic>> delete(
    String endpoint, {
    Map<String, String>? queryParams,
    Duration? timeout,
  }) async {
    try {
      final response = await _dio.delete(
        endpoint,
        queryParameters: queryParams,
        options: Options(
          sendTimeout: timeout,
          receiveTimeout: timeout,
        ),
      );

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Handle HTTP response
  Map<String, dynamic> _handleResponse(Response response) {
    // Handle 401 Unauthorized even if it comes as a "successful" response
    if (response.statusCode == 401) {
      _handleSessionExpired();
    }
    
    if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
      final baseResponse = <String, dynamic>{
        'statusCode': response.statusCode,
        'statusMessage': response.statusMessage,
      };
      
      if (response.data is Map<String, dynamic>) {
        // If response data is already a map, merge it with status info
        final dataMap = response.data as Map<String, dynamic>;
        return {...baseResponse, ...dataMap};
      } else if (response.data is String) {
        try {
          final parsed = jsonDecode(response.data as String) as Map<String, dynamic>;
          return {...baseResponse, ...parsed};
        } catch (e) {
          // If JSON parsing fails, wrap the string response
          return {...baseResponse, 'data': response.data};
        }
      } else if (response.data == null) {
        // Handle null response data (common for 201 Created responses)
        return {...baseResponse, 'data': null, 'success': true};
      } else {
        return {...baseResponse, 'data': response.data};
      }
    } else {
      throw ApiException(
        'HTTP ${response.statusCode}: ${response.statusMessage}',
        statusCode: response.statusCode,
        data: response.data,
      );
    }
  }

  // Handle errors and convert to ApiException
  ApiException _handleError(dynamic error) {
    if (error is DioException) {
      if (error.response != null) {
        final statusCode = error.response!.statusCode;
        final data = error.response!.data;
        
        // Handle 401 Unauthorized - automatically logout
        if (statusCode == 401) {
          _handleSessionExpired();
        }
        
        if (data is Map<String, dynamic>) {
          final message = data['message'] ?? data['error'] ?? error.message;
          return ApiException(message, statusCode: statusCode, data: data);
        } else {
          return ApiException(
            'HTTP $statusCode: ${error.response!.statusMessage}',
            statusCode: statusCode,
            data: data,
          );
        }
      } else {
        return ApiException('Network error: ${error.message}');
      }
    }

    return ApiException('Unexpected error: ${error.toString()}');
  }

  // Handle session expired - automatic logout
  void _handleSessionExpired() {
    if (_context != null && _context!.mounted) {
      try {
        if (kDebugMode) {
          print('Session expired - automatically logging out user');
        }
        
        final authState = Provider.of<app_auth.AppAuthState>(_context!, listen: false);
        
        // Perform logout asynchronously to avoid blocking the current request
        Future.microtask(() async {
          await authState.signOut();
          
          if (kDebugMode) {
            print('User automatically logged out due to session expiration');
          }
          
          // Show user-friendly notification
          if (_context != null && _context!.mounted) {
            final messenger = ScaffoldMessenger.of(_context!);
            messenger.showSnackBar(
              const SnackBar(
                content: Text('Your session has expired. Please sign in again.'),
                duration: Duration(seconds: 4),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        });
      } catch (e) {
        if (kDebugMode) {
          print('Error during automatic logout: $e');
        }
      }
    }
  }

  // Refresh session token if needed
  Future<bool> refreshTokenIfNeeded() async {
    try {
      if (_context != null && _context!.mounted) {
        final authState = Provider.of<app_auth.AppAuthState>(_context!, listen: false);
        return authState.refreshSession();
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('Token refresh failed: $e');
      }
      return false;
    }
  }

  // Check if current session is still valid
  Future<bool> isSessionValid() async {
    try {
      if (_context != null && _context!.mounted) {
        final authState = Provider.of<app_auth.AppAuthState>(_context!, listen: false);
        
        // Check if user is authenticated and session is not expired
        if (!authState.isAuthenticated) {
          return false;
        }
        
        // Check token expiry if available
        final sessionToken = authState.sessionToken;
        if (sessionToken != null) {
          // Simple validation - you could decode JWT to check expiry
          // For now, just check if we have a valid token format
          final parts = sessionToken.split('.');
          if (parts.length != 3) {
            return false; // Invalid JWT format
          }
        }
        
        return true;
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('Session validation failed: $e');
      }
      return false;
    }
  }

  // Helper method to make authenticated requests with automatic token refresh
  Future<Map<String, dynamic>> authenticatedRequest(
    Future<Map<String, dynamic>> Function() request,
  ) async {
    try {
      return await request();
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        final refreshed = await refreshTokenIfNeeded();
        if (refreshed) {
          return await request();
        }
        throw ApiException('Session expired. Please login again.');
      }
      rethrow;
    }
  }

  // Get user ID from current session
  String? get currentUserId {
    if (_context != null && _context!.mounted) {
      try {
        final authState = Provider.of<app_auth.AppAuthState>(_context!, listen: false);
        return authState.userId;
      } catch (e) {
        if (kDebugMode) {
          print('Error getting current user ID: $e');
        }
      }
    }
    return null;
  }

  // Check if connection is available (with throttling)
  Future<bool> checkConnection() async {
    // Throttle connection checks to avoid spam
    final now = DateTime.now();
    if (_lastConnectionCheck != null &&
        now.difference(_lastConnectionCheck!) < _connectionCheckThrottle) {
      if (kDebugMode) {
        print('Connection check throttled, returning cached result: $_lastConnectionResult');
      }
      return _lastConnectionResult ?? false;
    }
    
    try {
      if (kDebugMode) {
        print('Testing connection to: http://localhost:3000/');
      }
      
      // Use a simple health check endpoint to localhost
      final response = await _dio.get(
        'http://localhost:3000/',
        options: Options(
          sendTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
          // Disable any headers that might cause preflight
          headers: {},
        ),
      );
      
      final isSuccess = response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300;
      
      // Cache the result
      _lastConnectionCheck = now;
      _lastConnectionResult = isSuccess;
      
      if (kDebugMode) {
        print('Connection test result: $isSuccess (status: ${response.statusCode})');
        if (response.data != null) {
          print('Response data: ${response.data}');
        }
      }
      
      return isSuccess;
    } catch (e) {
      // Cache the failed result
      _lastConnectionCheck = now;
      _lastConnectionResult = false;
      
      if (kDebugMode) {
        print('Connection check failed: $e');
        if (e is DioException) {
          print('DioException type: ${e.type}');
          print('DioException message: ${e.message}');
          if (e.response != null) {
            print('Response status: ${e.response!.statusCode}');
            print('Response data: ${e.response!.data}');
          }
        }
      }
      return false;
    }
  }

  // Test method to simulate session expiry (for debugging purposes)
  void simulateSessionExpiry() {
    if (kDebugMode) {
      print('Simulating session expiry for testing...');
      _handleSessionExpired();
    }
  }
}