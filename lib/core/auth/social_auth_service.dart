import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../logging/talker_config.dart';
import '../network/result.dart';
import '../error/failure.dart';

/// Social authentication service for Google and Apple sign-in
///
/// Usage:
/// ```dart
/// final auth = SocialAuthService();
/// await auth.initialize();
/// final result = await auth.signInWithGoogle();
/// ```
class SocialAuthService {
  static SocialAuthService? _instance;
  static SocialAuthService get instance => _instance ??= SocialAuthService._();

  SocialAuthService._();

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile', 'openid'],
  );
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const String _googleUserKey = 'google_user';
  static const String _appleUserKey = 'apple_user';

  bool _isInitialized = false;
  GoogleSignInAccount? _currentGoogleUser;
  AuthorizationCredentialAppleID? _currentAppleUser;

  /// Initialize social authentication
  Future<void> initialize() async {
    try {
      // Check if Google Sign-In is available
      final isGoogleAvailable = await _googleSignIn.isSignedIn();
      if (isGoogleAvailable) {
        _currentGoogleUser = _googleSignIn.currentUser;
      }

      _isInitialized = true;
      TalkerConfig.logInfo('Social authentication initialized');
    } catch (e, stackTrace) {
      TalkerConfig.logError(
        'Failed to initialize social authentication',
        e,
        stackTrace,
      );
    }
  }

  /// Check if Google Sign-In is available
  bool get isGoogleAvailable => _isInitialized;

  /// Check if Apple Sign-In is available
  bool get isAppleAvailable =>
      _isInitialized && defaultTargetPlatform == TargetPlatform.iOS;

  /// Get current Google user
  GoogleSignInAccount? get currentGoogleUser => _currentGoogleUser;

  /// Get current Apple user
  AuthorizationCredentialAppleID? get currentAppleUser => _currentAppleUser;

  /// Sign in with Google
  Future<Result<SocialUser>> signInWithGoogle() async {
    try {
      if (!isGoogleAvailable) {
        return Error(Failure('Google Sign-In not available'));
      }

      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return Error(Failure('Google Sign-In cancelled by user'));
      }

      _currentGoogleUser = googleUser;

      // Get authentication details
      final googleAuth = await googleUser.authentication;
      if (googleAuth.accessToken == null) {
        return Error(Failure('Failed to get Google access token'));
      }

      final socialUser = SocialUser(
        id: googleUser.id,
        email: googleUser.email,
        name: googleUser.displayName ?? '',
        photoUrl: googleUser.photoUrl,
        provider: SocialProvider.google,
        accessToken: googleAuth.accessToken!,
        idToken: googleAuth.idToken,
      );

      // Save user data
      await _saveGoogleUser(socialUser);

      TalkerConfig.logInfo('Google Sign-In successful: ${googleUser.email}');
      return Success(socialUser);
    } catch (e, stackTrace) {
      TalkerConfig.logError('Google Sign-In failed', e, stackTrace);
      return Error(Failure('Google Sign-In failed: $e', stack: stackTrace));
    }
  }

  /// Sign in with Apple
  Future<Result<SocialUser>> signInWithApple() async {
    try {
      if (!isAppleAvailable) {
        return Error(Failure('Apple Sign-In not available'));
      }

      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      _currentAppleUser = credential;

      final socialUser = SocialUser(
        id: credential.userIdentifier ?? '',
        email: credential.email ?? '',
        name: _getAppleDisplayName(credential),
        photoUrl: null,
        provider: SocialProvider.apple,
        accessToken: credential.identityToken ?? '',
        idToken: credential.identityToken,
      );

      // Save user data
      await _saveAppleUser(socialUser);

      TalkerConfig.logInfo('Apple Sign-In successful: ${credential.email}');
      return Success(socialUser);
    } catch (e, stackTrace) {
      TalkerConfig.logError('Apple Sign-In failed', e, stackTrace);
      return Error(Failure('Apple Sign-In failed: $e', stack: stackTrace));
    }
  }

  /// Sign out from Google
  Future<Result<void>> signOutFromGoogle() async {
    try {
      await _googleSignIn.signOut();
      _currentGoogleUser = null;
      await _storage.delete(key: _googleUserKey);

      TalkerConfig.logInfo('Google Sign-Out successful');
      return const Success(null);
    } catch (e, stackTrace) {
      TalkerConfig.logError('Google Sign-Out failed', e, stackTrace);
      return Error(Failure('Google Sign-Out failed: $e', stack: stackTrace));
    }
  }

  /// Sign out from Apple
  Future<Result<void>> signOutFromApple() async {
    try {
      _currentAppleUser = null;
      await _storage.delete(key: _appleUserKey);

      TalkerConfig.logInfo('Apple Sign-Out successful');
      return const Success(null);
    } catch (e, stackTrace) {
      TalkerConfig.logError('Apple Sign-Out failed', e, stackTrace);
      return Error(Failure('Apple Sign-Out failed: $e', stack: stackTrace));
    }
  }

  /// Sign out from all providers
  Future<Result<void>> signOutFromAll() async {
    try {
      final results = await Future.wait([
        signOutFromGoogle(),
        signOutFromApple(),
      ]);

      final hasError = results.any((result) => result.isFailure);
      if (hasError) {
        return Error(Failure('Some sign-outs failed'));
      }

      TalkerConfig.logInfo('Sign-out from all providers successful');
      return const Success(null);
    } catch (e, stackTrace) {
      TalkerConfig.logError(
        'Sign-out from all providers failed',
        e,
        stackTrace,
      );
      return Error(
        Failure('Sign-out from all providers failed: $e', stack: stackTrace),
      );
    }
  }

  /// Get Apple display name from credential
  String _getAppleDisplayName(AuthorizationCredentialAppleID credential) {
    final givenName = credential.givenName ?? '';
    final familyName = credential.familyName ?? '';

    if (givenName.isNotEmpty && familyName.isNotEmpty) {
      return '$givenName $familyName';
    } else if (givenName.isNotEmpty) {
      return givenName;
    } else if (familyName.isNotEmpty) {
      return familyName;
    } else {
      return 'Apple User';
    }
  }

  /// Save Google user data
  Future<void> _saveGoogleUser(SocialUser user) async {
    try {
      await _storage.write(
        key: _googleUserKey,
        value: jsonEncode(user.toJson()),
      );
    } catch (e) {
      TalkerConfig.logError('Failed to save Google user data', e);
    }
  }

  /// Save Apple user data
  Future<void> _saveAppleUser(SocialUser user) async {
    try {
      await _storage.write(
        key: _appleUserKey,
        value: jsonEncode(user.toJson()),
      );
    } catch (e) {
      TalkerConfig.logError('Failed to save Apple user data', e);
    }
  }

  /// Load saved Google user
  Future<SocialUser?> loadGoogleUser() async {
    try {
      final userData = await _storage.read(key: _googleUserKey);
      if (userData != null) {
        return SocialUser.fromJson(
          jsonDecode(userData) as Map<String, dynamic>,
        );
      }
      return null;
    } catch (e) {
      TalkerConfig.logError('Failed to load Google user data', e);
      return null;
    }
  }

  /// Load saved Apple user
  Future<SocialUser?> loadAppleUser() async {
    try {
      final userData = await _storage.read(key: _appleUserKey);
      if (userData != null) {
        return SocialUser.fromJson(
          jsonDecode(userData) as Map<String, dynamic>,
        );
      }
      return null;
    } catch (e) {
      TalkerConfig.logError('Failed to load Apple user data', e);
      return null;
    }
  }

  /// Check if user is signed in with any provider
  bool get isSignedIn =>
      _currentGoogleUser != null || _currentAppleUser != null;

  /// Get current user from any provider
  SocialUser? get currentUser {
    if (_currentGoogleUser != null) {
      return SocialUser(
        id: _currentGoogleUser!.id,
        email: _currentGoogleUser!.email,
        name: _currentGoogleUser!.displayName ?? '',
        photoUrl: _currentGoogleUser!.photoUrl,
        provider: SocialProvider.google,
        accessToken: '', // Would need to get fresh token
        idToken: null,
      );
    } else if (_currentAppleUser != null) {
      return SocialUser(
        id: _currentAppleUser!.userIdentifier ?? '',
        email: _currentAppleUser!.email ?? '',
        name: _getAppleDisplayName(_currentAppleUser!),
        photoUrl: null,
        provider: SocialProvider.apple,
        accessToken: _currentAppleUser!.identityToken ?? '',
        idToken: _currentAppleUser!.identityToken,
      );
    }
    return null;
  }
}

/// Social user data class
class SocialUser {
  final String id;
  final String email;
  final String name;
  final String? photoUrl;
  final SocialProvider provider;
  final String accessToken;
  final String? idToken;

  SocialUser({
    required this.id,
    required this.email,
    required this.name,
    this.photoUrl,
    required this.provider,
    required this.accessToken,
    this.idToken,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'photoUrl': photoUrl,
      'provider': provider.toString(),
      'accessToken': accessToken,
      'idToken': idToken,
    };
  }

  factory SocialUser.fromJson(Map<String, dynamic> json) {
    return SocialUser(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      photoUrl: json['photoUrl'] as String?,
      provider: SocialProvider.values.firstWhere(
        (p) => p.toString() == json['provider'],
        orElse: () => SocialProvider.google,
      ),
      accessToken: json['accessToken'] as String,
      idToken: json['idToken'] as String?,
    );
  }
}

/// Social provider enum
enum SocialProvider { google, apple }
