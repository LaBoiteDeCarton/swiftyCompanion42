import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class OAuthService {
  static const FlutterAppAuth _appAuth = FlutterAppAuth();
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  static String get _authorizationEndpoint => '${dotenv.env['API_BASE_URL'] ?? ''}/oauth/authorize';
  static String get _tokenEndpoint => '${dotenv.env['API_BASE_URL'] ?? ''}/oauth/token';
  static String get _revokeEndpoint => '${dotenv.env['API_BASE_URL'] ?? ''}/oauth/revoke';

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _idTokenKey = 'id_token';

  static String get _clientId => dotenv.env['API_UID'] ?? '';
  static String get _clientSecret => dotenv.env['API_SECRET'] ?? '';
  static String get _redirectUrl => dotenv.env['REDIRECT_URI'] ?? '';
  static String get _baseUrl => dotenv.env['API_BASE_URL'] ?? '';

  /// Authorize and get tokens
  static Future<AuthorizationTokenResponse?> login() async {
    try {
      final AuthorizationTokenResponse result = await _appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          _clientId,
          _redirectUrl,
          clientSecret: _clientSecret, // Include client secret for token exchange
          serviceConfiguration: AuthorizationServiceConfiguration(
            authorizationEndpoint: _authorizationEndpoint,
            tokenEndpoint: _tokenEndpoint,
            endSessionEndpoint: _revokeEndpoint,
          ),
          scopes: ['public'], // 42 API uses 'public' scope as per documentation
        ),
      );
      await _saveTokens(result);
      return result;
    } on FlutterAppAuthUserCancelledException catch (e) {
      print('User cancelled the OAuth flow: $e');
      return null;
    } on FlutterAppAuthPlatformException catch (e) {
      print('OAuth Platform Error: ${e.message}');
      print('Error code: ${e.code}');
      print('Error details: ${e.details}');
      print('Error type: ${e.runtimeType}');
      rethrow;
    } catch (e) {
      print('OAuth Error: $e');
      print('Error type: ${e.runtimeType}');
      rethrow;
    }
  }

  /// Save tokens to secure storage from AuthorizationTokenResponse
  static Future<void> _saveTokens(AuthorizationTokenResponse? response) async {
    if (response == null) return;
    if (response.accessToken != null) {
      await _secureStorage.write(key: _accessTokenKey, value: response.accessToken);
    }
    if (response.refreshToken != null) {
      await _secureStorage.write(key: _refreshTokenKey, value: response.refreshToken);
    }
    if (response.idToken != null) {
      await _secureStorage.write(key: _idTokenKey, value: response.idToken);
    }
  }

  /// Get stored access token
  static Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: _accessTokenKey);
  }

  /// Get stored refresh token
  static Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: _refreshTokenKey);
  }

  /// Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  /// Refresh access token
  static Future<TokenResponse?> refreshToken() async {
    try {
      final refreshToken = await getRefreshToken();
      if (refreshToken == null) return null;

      final TokenResponse result = await _appAuth.token(
        TokenRequest(
          _clientId,
          _redirectUrl,
          clientSecret: _clientSecret,
          serviceConfiguration: AuthorizationServiceConfiguration(
            authorizationEndpoint: _authorizationEndpoint,
            tokenEndpoint: _tokenEndpoint,
            endSessionEndpoint: _revokeEndpoint,
          ),
          refreshToken: refreshToken,
          scopes: ['public'],
        ),
      );

      await _saveRefreshedTokens(result);

      return result;
    } catch (e) {
      print('Token refresh error: $e');
      return null;
    }
  }

  /// Save refreshed tokens from TokenResponse
  static Future<void> _saveRefreshedTokens(TokenResponse? response) async {
    if (response == null) return;
    if (response.accessToken != null) {
      await _secureStorage.write(key: _accessTokenKey, value: response.accessToken);
    }
    if (response.refreshToken != null) {
      await _secureStorage.write(key: _refreshTokenKey, value: response.refreshToken);
    }
    if (response.idToken != null) {
      await _secureStorage.write(key: _idTokenKey, value: response.idToken);
    }
  }

  /// Logout user
  static Future<void> logout() async {
    try {
      await _secureStorage.delete(key: _accessTokenKey);
      await _secureStorage.delete(key: _refreshTokenKey);
      await _secureStorage.delete(key: _idTokenKey);

      // Optionally revoke token on server
      final accessToken = await getAccessToken();
      if (accessToken != null) {
        await _revokeToken(accessToken);
      }
    } catch (e) {
      print('Logout error: $e');
    }
  }

  /// Revoke token on server
  static Future<void> _revokeToken(String token) async {
    try {
      final response = await http.post(
        Uri.parse(_revokeEndpoint),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'client_id': _clientId,
          'client_secret': _clientSecret,
          'token': token,
        },
      );

      if (response.statusCode != 200) {
        print('Failed to revoke token: ${response.statusCode}');
      }
    } catch (e) {
      print('Token revocation error: $e');
    }
  }

  /// Make authenticated API request
  static Future<http.Response> authenticatedRequest(String endpoint) async {
    String? accessToken = await getAccessToken();
    
    if (accessToken == null) {
      throw Exception('No access token available');
    }

    var response = await http.get(
      Uri.parse('$_baseUrl$endpoint'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    // If token is expired, try to refresh
    if (response.statusCode == 401) {
      final refreshResult = await refreshToken();
      if (refreshResult?.accessToken != null) {
        accessToken = refreshResult!.accessToken;
        response = await http.get(
          Uri.parse('$_baseUrl$endpoint'),
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
        );
      }
    }

    return response;
  }

  /// Get current user profile
  static Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final response = await authenticatedRequest('/v2/me');
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print('Failed to get user profile: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }
}