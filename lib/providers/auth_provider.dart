// lib/providers/auth_provider.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../apis/supabase_auth_api.dart';
import '../apis/supabase_user_api.dart';
import '../models/user_model.dart';
import '../providers/events_provider.dart';
import '../providers/reports_provider.dart';

class AuthProvider with ChangeNotifier {
  final SupabaseAuthAPI _authAPI = SupabaseAuthAPI();
  final SupabaseUserAPI _userAPI = SupabaseUserAPI();

  // Optional references to other providers — set via initProviders()
  // We use late + nullable to avoid circular dependency at construction time
  Events? _eventsProvider;
  Reports? _reportsProvider;

  UserModel? _currentUserProfile;
  User? _authUser;
  bool _isLoading = false;
  String? _errorMessage;

  /// Guard flag: true while signUp() is inserting the user row so the
  /// auth-state listener doesn't try to load a profile that doesn't exist yet.
  bool _isInsertingUser = false;

  UserModel? get currentUserProfile => _currentUserProfile;
  User? get authUser => _authUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _authUser != null;
  bool get isGeneralPublic => _currentUserProfile?.cluster.isEmpty ?? true;
  bool get isPGHCluster =>
      _currentUserProfile?.cluster.toLowerCase() == 'pgh';

  // Backward compatibility alias
  UserModel? get currentUser => _currentUserProfile;

  AuthProvider() {
    _initializeAuthListener();
  }

  /// Call this once after all providers are created (e.g. in main.dart
  /// or wherever you set up MultiProvider) so AuthProvider can notify
  /// Events and Reports when the user changes.
  ///
  /// Example in main.dart:
  ///   final authProvider   = AuthProvider();
  ///   final eventsProvider = Events();
  ///   final reportsProvider = Reports(eventTotalsProvider);
  ///   authProvider.initProviders(eventsProvider, reportsProvider);
  void initProviders(Events events, Reports reports) {
    _eventsProvider  = events;
    _reportsProvider = reports;

    // If a user is already loaded when providers are injected (e.g. app
    // restart with existing session), wire them up immediately.
    if (_currentUserProfile != null) {
      _notifyProviders(_currentUserProfile!);
    }
  }

  // ─── Auth listener ────────────────────────────────────────────────────────

  void _initializeAuthListener() {
    _authAPI.getUser().listen((user) async {
      _authUser = user;
      if (user != null) {
        // Skip loading the profile if signUp() is in the middle of inserting
        // the user row — it will call _loadUserProfile itself once done.
        if (_isInsertingUser) {
          debugPrint('[AuthProvider] Auth state changed during user insertion — skipping profile load.');
          return;
        }
        await _loadUserProfile(user.id);
      } else {
        _currentUserProfile = null;
        _clearProviders(); // Reset Events/Reports to empty streams on logout
      }
      notifyListeners();
    });
  }

  // ─── Profile loading ──────────────────────────────────────────────────────

  /// Fetches the full users table row for the given Supabase auth UUID.
  /// Uses a direct Future query (not a stream) so we get the result once
  /// and immediately wire up dependent providers.
  Future<void> _loadUserProfile(String authId) async {
    try {
      debugPrint('[AuthProvider] Loading user profile for authId: $authId');

      // Use maybeSingle() so we get null instead of an exception when 0 rows exist.
      final response = await Supabase.instance.client
          .from('users')
          .select()
          .eq('authid', authId)
          .maybeSingle();

      if (response == null) {
        debugPrint('[AuthProvider] No user profile found for authId: $authId — skipping.');
        _currentUserProfile = null;
        _clearProviders();
        notifyListeners();
        return;
      }

      _currentUserProfile = UserModel.fromJson(response);

      debugPrint('[AuthProvider] Loaded user: ${_currentUserProfile!.userName}');
      debugPrint('[AuthProvider] encoder_id: ${_currentUserProfile!.encoderId}');
      debugPrint('[AuthProvider] cluster: ${_currentUserProfile!.cluster}');
      debugPrint('[AuthProvider] office: ${_currentUserProfile!.office}');
      debugPrint('[AuthProvider] bldgName: ${_currentUserProfile!.bldgName}');

      // Wire up Events and Reports providers now that we have the full profile
      _notifyProviders(_currentUserProfile!);
    } catch (e) {
      debugPrint('[AuthProvider] Error loading user profile: $e');
      // Set error message so UI can show feedback
      _errorMessage = 'Failed to load user profile: ${e.toString()}';
      _currentUserProfile = null;
      // Clear providers since we don't have valid user data
      _clearProviders();
      notifyListeners();
    }
  }

  /// Tells Events and Reports providers which user is logged in so they
  /// can filter their streams accordingly.
  void _notifyProviders(UserModel user) {
    if (_eventsProvider != null) {
      _eventsProvider!.setCurrentUser(
        cluster:  user.cluster,
        office:   user.office,
        bldgName: user.bldgName,
      );
      debugPrint('[AuthProvider] → Events.setCurrentUser called');
    }

    if (_reportsProvider != null) {
      // Pass user.encoderId — this is users.encoder_id UUID, NOT authid
      _reportsProvider!.setCurrentUser(user.encoderId, user);
      debugPrint('[AuthProvider] → Reports.setCurrentUser called '
          'with encoderId=${user.encoderId}');
    }
  }

  /// Resets Events and Reports to empty streams on logout.
  void _clearProviders() {
    _eventsProvider?.setCurrentUser(
      cluster: '', office: '', bldgName: '',
    );
    _reportsProvider?.setCurrentUser('', UserModel(userName: ''));
    debugPrint('[AuthProvider] Providers cleared on logout');
  }

  // ─── Auth actions ─────────────────────────────────────────────────────────

  /// Sign up with email and password.
  /// Returns null on success, error message string on failure.
  Future<String?> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String middleName = '',
    String suffix     = '',
    String cluster    = '',
    String office     = '',
    String bldgName   = '',
    String position   = '',
    String zone       = '',
    int    userType   = 0,
  }) async {
    _isLoading     = true;
    _errorMessage  = null;
    notifyListeners();

    try {
      // Generate a unique username
      String username =
          '${firstName.toLowerCase()}_${lastName.toLowerCase()}'
          .replaceAll(' ', '_');

      final usernameExists = await _userAPI.usernameExists(username);
      if (usernameExists) {
        int counter = 1;
        while (await _userAPI.usernameExists('${username}_$counter')) {
          counter++;
        }
        username = '${username}_$counter';
      }

      // Create Supabase auth account
      final authResponse = await _authAPI.signUp(email, password);
      if (authResponse.user == null) {
        _errorMessage = 'Failed to create account';
        _isLoading    = false;
        notifyListeners();
        return _errorMessage;
      }

      await Future.delayed(const Duration(milliseconds: 500));

      // Insert into users table — encoder_id is auto-generated by Supabase
      // (gen_random_uuid() default), so we do NOT set it here.
      // It will be read back via _loadUserProfile after login.
      final userModel = UserModel(
        userName:  username,
        firstName: firstName,
        middleName: middleName,
        lastName:  lastName,
        suffix:    suffix,
        email:     email,
        authId:    authResponse.user!.id,
        cluster:   cluster,
        office:    office,
        bldgName:  bldgName,
        position:  position,
        zone:      zone,
        userType:  userType,
        // encoderId intentionally left empty here — Supabase generates it.
        // _loadUserProfile will read the generated value back.
      );

      // Raise the guard BEFORE inserting so the auth-state listener
      // (which fires as a side-effect of signUp) doesn't race with us.
      _isInsertingUser = true;
      await _userAPI.addUser(username, userModel);
      _isInsertingUser = false;

      // Now that the row exists, load the full profile (includes encoder_id).
      await _loadUserProfile(authResponse.user!.id);

      _authUser  = authResponse.user;
      _isLoading = false;
      notifyListeners();
      return null; // success
    } catch (e) {
      _isInsertingUser = false; // always reset the guard on error
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      debugPrint('[AuthProvider] Sign up error: $e');
      _isLoading = false;
      notifyListeners();
      return _errorMessage;
    }
  }

  /// Sign in with email and password.
  /// Returns null on success, error message string on failure.
  Future<String?> signIn(String email, String password) async {
    _isLoading    = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final authResponse = await _authAPI.signIn(email, password);

      if (authResponse.user != null) {
        _authUser = authResponse.user;
        // _loadUserProfile fetches encoder_id and calls _notifyProviders
        await _loadUserProfile(authResponse.user!.id);
        _isLoading = false;
        notifyListeners();
        return null; // success
      }

      _errorMessage = 'Invalid credentials';
      _isLoading    = false;
      notifyListeners();
      return _errorMessage;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      debugPrint('[AuthProvider] Sign in error: $e');
      _isLoading = false;
      notifyListeners();
      return _errorMessage;
    }
  }

  /// Sign out
  Future<void> signOut([BuildContext? context]) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authAPI.signOut();
      _currentUserProfile = null;
      _authUser           = null;
      _errorMessage       = null;
      _clearProviders();
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('[AuthProvider] Sign out error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // ─── Profile updates ──────────────────────────────────────────────────────

  Future<bool> updateProfile({
    String? firstName,
    String? middleName,
    String? lastName,
    String? suffix,
    String? cluster,
    String? office,
    String? bldgName,
    String? position,
    String? zone,
  }) async {
    if (_currentUserProfile == null) return false;

    _isLoading    = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updates = <String, dynamic>{};
      if (firstName  != null) updates['firstname']  = firstName;
      if (middleName != null) updates['middlename'] = middleName;
      if (lastName   != null) updates['lastname']   = lastName;
      if (suffix     != null) updates['suffix']     = suffix;
      if (cluster    != null) updates['cluster']    = cluster;
      if (office     != null) updates['office']     = office;
      if (bldgName   != null) updates['bldgname']   = bldgName;
      if (position   != null) updates['encoder_position'] = position;
      if (zone       != null) updates['zone']       = zone;

      await _userAPI.editUser(_currentUserProfile!.userName, updates);

      // Reload full profile so all providers get the updated values
      await _loadUserProfile(_authUser!.id);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading    = false;
      notifyListeners();
      return false;
    }
  }

  // ─── Other auth actions ───────────────────────────────────────────────────

  Future<bool> resetPassword(String email) async {
    _isLoading    = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authAPI.resetPassword(email);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading    = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> verifyEmail() async {
    try {
      await _authAPI.verifyEmail();
    } catch (e) {
      debugPrint('[AuthProvider] Verify email error: $e');
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ─── Access helpers ───────────────────────────────────────────────────────

  bool get hasCalendarAccess => !isGeneralPublic;
}