import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class Api42Service {
  static const String _baseUrl = 'https://api.intra.42.fr';
  static const String _tokenEndpoint = '/oauth/token';
  static const String _tokenInfoEndpoint = '/oauth/token/info';
  static const String _apiVersion = '/v2';
  
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  static String? _cachedAccessToken;
  static DateTime? _tokenExpiresAt;

  static String get _clientId {
    final clientId = dotenv.env['API_UID'];
    if (clientId == null || clientId.isEmpty) {
      throw Exception('API_UID not found in environment variables');
    }
    return clientId;
  }

  static String get _clientSecret {
    final clientSecret = dotenv.env['API_SECRET'];
    if (clientSecret == null || clientSecret.isEmpty) {
      throw Exception('API_SECRET not found in environment variables');
    }
    return clientSecret;
  }

  /// Request a new access token from 42 API
  static Future<String> _requestAccessToken() async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl$_tokenEndpoint'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'grant_type': 'client_credentials',
          'client_id': _clientId,
          'client_secret': _clientSecret,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final accessToken = data['access_token'] as String;
        final expiresIn = data['expires_in'] as int;
        final createdAt = data['created_at'] as int;
        
        final expiresAt = DateTime.fromMillisecondsSinceEpoch(
          (createdAt + expiresIn) * 1000,
        );

        await _storage.write(key: 'api42_access_token', value: accessToken);
        await _storage.write(key: 'api42_token_expires_at', value: expiresAt.toIso8601String());
        
        _cachedAccessToken = accessToken;
        _tokenExpiresAt = expiresAt;

        return accessToken;
      } else {
        final errorData = json.decode(response.body);
        throw Exception('Failed to get access token: ${errorData['error_description'] ?? response.body}');
      }
    } catch (e) {
      throw Exception('Error requesting access token: $e');
    }
  }

  /// Check if the current token is still valid
  static bool _isTokenValid() {
    if (_cachedAccessToken == null || _tokenExpiresAt == null) {
      return false;
    }
    return _tokenExpiresAt!.isAfter(DateTime.now().add(const Duration(minutes: 2)));
  }

  static Future<void> _loadTokenFromStorage() async {
    try {
      final token = await _storage.read(key: 'api42_access_token');
      final expiresAtString = await _storage.read(key: 'api42_token_expires_at');
      
      if (token != null && expiresAtString != null) {
        _cachedAccessToken = token;
        _tokenExpiresAt = DateTime.parse(expiresAtString);
      }
    } catch (e) {
      print('Error loading token from storage: $e');
    }
  }

  /// Get a valid access token (refresh if necessary)
  static Future<String> getAccessToken() async {
    if (_cachedAccessToken == null) {
      await _loadTokenFromStorage();
    }
    if (_isTokenValid()) {
      return _cachedAccessToken!;
    }
    return await _requestAccessToken();
  }

  static Future<void> clearToken() async {
    _cachedAccessToken = null;
    _tokenExpiresAt = null;
    await _storage.delete(key: 'api42_access_token');
    await _storage.delete(key: 'api42_token_expires_at');
  }

  static Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, dynamic>? queryParams,
  }) async {
    final token = await getAccessToken();
    
    Uri uri = Uri.parse('$_baseUrl$_apiVersion$endpoint');
    if (queryParams != null) {
      uri = uri.replace(queryParameters: queryParams.map(
        (key, value) => MapEntry(key, value.toString()),
      ));
    }
    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      
      return {
        'data': data,
        'headers': response.headers,
        'pagination': {
          'page': response.headers['x-page'],
          'per_page': response.headers['x-per-page'],
          'total': response.headers['x-total'],
          'link': response.headers['link'],
        }
      };
    } else if (response.statusCode == 404) {
      return {
        'data': null,
        'headers': response.headers,
        'pagination': null,
        'notFound': true,
      };
    } else if (response.statusCode == 401) {
      await clearToken();
      throw Exception('Authentication failed. Token may be expired.');
    } else {
      throw Exception('API request failed: ${response.statusCode} - ${response.body}');
    }
  }
}
