import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/services.dart';
import 'dart:async';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal() {
    _initDeepLinkListener();
  }

  final _supabase = Supabase.instance.client;
  static const _channel = MethodChannel('com.zerosetup/deeplink');

  /// Stream of auth state changes.
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  /// Current user.
  User? get currentUser => _supabase.auth.currentUser;

  /// Initializes the deep link listener to catch redirects from the browser via our custom C++ bridge.
  void _initDeepLinkListener() {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onLink') {
        final uriString = call.arguments as String;
        final uri = Uri.parse(uriString);
        print('Received custom deep link from C++: $uri');
        if (uri.scheme == 'zerosetup') {
          try {
            await _supabase.auth.getSessionFromUrl(uri);
            print('Successfully processed custom deep link auth');
          } catch (e) {
            print('Error processing deep link: $e');
          }
        }
      }
    });

    // Also check if the app was launched directly with a deep link (args usually passed to main)
    // But since Windows single-instance mutex ensures the main app catches it via WM_COPYDATA,
    // this listener is the primary entry point.
  }

  /// Sign in with Google.
  Future<void> signInWithGoogle() async {
    await _supabase.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: 'zerosetup://callback',
    );
  }

  /// Sign in with GitHub.
  Future<void> signInWithGithub() async {
    await _supabase.auth.signInWithOAuth(
      OAuthProvider.github,
      redirectTo: 'zerosetup://callback',
    );
  }

  /// Sign out.
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

}
