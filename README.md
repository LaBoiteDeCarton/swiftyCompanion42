# SwiftyCompanion - 42 OAuth Flutter App

A Flutter application that implements OAuth authentication with the 42 API to display student profiles and information.

## Features

- **OAuth 2.0 Authentication**: Secure login using 42's OAuth system
- **User Profile Display**: Shows comprehensive student information including:
  - Profile picture and basic info
  - Campus information
  - Level and progress
  - Wallet and correction points
  - Recent projects with status
- **Secure Token Storage**: Uses Flutter Secure Storage for token management
- **Automatic Token Refresh**: Handles token expiration automatically
- **Cross-Platform**: Works on both iOS and Android

## Prerequisites

- Flutter SDK (3.9.2 or higher)
- Dart SDK
- 42 API credentials (UID and Secret)
- Android Studio / Xcode for building

## Setup Instructions

### 1. Environment Configuration

Create a `.env` file in the project root with your 42 API credentials:

```env
API_UID=your_42_api_uid_here
API_SECRET=your_42_api_secret_here
REDIRECT_URI=com.swiftycompanion://callback
API_BASE_URL=https://api.intra.42.fr
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Android Configuration

The Android configuration is already set up in `android/app/build.gradle.kts` with the redirect scheme `com.swiftycompanion`.

### 4. iOS Configuration

The iOS configuration is set up in `ios/Runner/Info.plist` with the URL scheme.

### 5. 42 API Application Setup

1. Go to [42's API applications page](https://profile.intra.42.fr/oauth/applications)
2. Create a new application
3. Set the redirect URI to: `com.swiftycompanion://callback`
4. Copy the UID and Secret to your `.env` file

## Project Structure

```
lib/
├── main.dart                 # App entry point with authentication flow
├── models/
│   └── user_profile.dart     # Data models for user and project
├── screens/
│   ├── login_screen.dart     # OAuth login interface
│   └── home_screen.dart      # User profile display
└── services/
    └── oauth_service.dart    # OAuth and API handling
```

## Key Components

### OAuthService
- Handles OAuth 2.0 flow with 42 API
- Manages secure token storage
- Provides authenticated API requests
- Automatic token refresh

### LoginScreen
- Beautiful OAuth login interface
- Error handling for authentication failures
- User cancellation handling

### HomeScreen
- Displays comprehensive user profile
- Shows recent projects with status indicators
- Logout functionality

## OAuth Flow

1. User taps "Login with 42"
2. App opens browser with 42 OAuth authorization
3. User logs in and grants permissions
4. Browser redirects back to app with authorization code
5. App exchanges code for access token
6. Token is securely stored for future API calls

## API Endpoints Used

- **Authorization**: `https://api.intra.42.fr/oauth/authorize`
- **Token Exchange**: `https://api.intra.42.fr/oauth/token`
- **User Profile**: `https://api.intra.42.fr/v2/me`
- **Token Revocation**: `https://api.intra.42.fr/oauth/revoke`

## Error Handling

- User cancellation detection
- Network error handling
- Token expiration and refresh
- API error responses

## Security Features

- Secure token storage using Flutter Secure Storage
- PKCE (Proof Key for Code Exchange) implementation
- Automatic token cleanup on logout
- Server-side token revocation

## Running the App

```bash
# For Android
flutter run

# For iOS
flutter run -d ios

# For specific device
flutter devices
flutter run -d device_id
```

## Dependencies

- `flutter_appauth`: OAuth 2.0 and OpenID Connect client
- `flutter_secure_storage`: Secure storage for tokens
- `flutter_dotenv`: Environment variable management
- `http`: HTTP requests for API calls

## Troubleshooting

### Common Issues

1. **Redirect URI mismatch**: Ensure the redirect URI in your 42 app matches exactly
2. **Android build issues**: Make sure the redirect scheme is lowercase
3. **iOS URL scheme**: Verify the CFBundleURLSchemes in Info.plist
4. **Environment variables**: Check that .env file is properly loaded

### Debug Commands

```bash
# Check dependencies
flutter doctor

# Clean build
flutter clean
flutter pub get

# View logs
flutter logs
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is part of the 42 curriculum and follows the school's guidelines.
