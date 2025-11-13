import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static Map<String, dynamic>? _cachedUserData;
  static String? _cachedUserId;
  static bool _isLoading = false;
  static bool _hasLoaded = false;

  Future<Map<String, dynamic>?> _getUserData({bool forceRefresh = false}) async {
    final user = _auth.currentUser;
    if (user == null) {
      _clearCache();
      return null;
    }

    if (!forceRefresh && 
        _cachedUserData != null && 
        _cachedUserId == user.uid && 
        _hasLoaded) {
      return _cachedUserData;
    }

    if (_isLoading) {
      while (_isLoading) {
        await Future<void>.delayed(const Duration(milliseconds: 50));
      }
      return _cachedUserData;
    }

    if (forceRefresh || !_hasLoaded || _cachedUserId != user.uid) {
      _isLoading = true;
      try {
        final DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          _cachedUserData = userDoc.data() as Map<String, dynamic>;
          _cachedUserId = user.uid;
          _hasLoaded = true;
        } else {
          _clearCache();
        }
      } catch (e) {
        _clearCache();
      } finally {
        _isLoading = false;
      }
    }

    return _cachedUserData;
  }

  static void _clearCache() {
    _cachedUserData = null;
    _cachedUserId = null;
    _hasLoaded = false;
    _isLoading = false;
  }

  static void clearCache() {
    _clearCache();
  }

  Future<bool> isAdmin({bool forceRefresh = false}) async {
    try {
      final userData = await _getUserData(forceRefresh: forceRefresh);
      if (userData == null) {
        return false;
      }
      final String privilege = (userData['privilege'] as String?) ?? 'customer';
      return privilege.toLowerCase() == 'admin';
    } catch (e) {
      return false;
    }
  }

  Future<String?> getUserPrivilege({bool forceRefresh = false}) async {
    try {
      final userData = await _getUserData(forceRefresh: forceRefresh);
      if (userData == null) {
        return null;
      }
      return userData['privilege'] as String?;
    } catch (e) {
      return null;
    }
  }

  Future<String> getUserRole({bool forceRefresh = false}) async {
    try {
      final userData = await _getUserData(forceRefresh: forceRefresh);
      if (userData == null) {
        return 'employee';
      }
      return userData['userRole'] as String? ?? 'employee';
    } catch (e) {
      return 'employee';
    }
  }

  Future<void> updateUserRole(String role) async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) {
        throw Exception('No user is currently logged in');
      }

      await _firestore.collection('users').doc(user.uid).update({
        'userRole': role,
      });
      
      if (_cachedUserData != null && _cachedUserId == user.uid) {
        _cachedUserData!['userRole'] = role;
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getUserData({bool forceRefresh = false}) async {
    return _getUserData(forceRefresh: forceRefresh);
  }

  T? getCachedField<T>(String fieldName) {
    if (_cachedUserData == null) {
      return null;
    }
    return _cachedUserData![fieldName] as T?;
  }

  bool isCached() {
    return _cachedUserData != null && _hasLoaded;
  }
}


