import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/database_service.dart';

class AuthProvider with ChangeNotifier {
  bool _isLoggedIn = false;
  String? _userId;
  String? _userEmail;
  final DatabaseService _db = DatabaseService();
  final SharedPreferences _prefs;

  AuthProvider(this._prefs) {
    _initializeAuth();
  }

  bool get isLoggedIn => _isLoggedIn;
  String? get userId => _userId;
  String? get userEmail => _userEmail;

  Future<void> _initializeAuth() async {
    print('Initializing auth...'); // 调试输出
    // 使用预设的管理员账户
    final adminEmail = 'admin@warmsage.com';
    final userData = await _db.getUserByEmail(adminEmail);
    print('User data: $userData'); // 调试输出
    
    if (userData != null) {
      _isLoggedIn = true;
      _userId = userData['userId'];    // 将是 'admin_001'
      _userEmail = userData['email'];  // 将是 'admin@warmsage.com'
      
      // 保存到本地存储
      await _prefs.setString('userEmail', _userEmail!);
      print('User logged in: $_userEmail'); // 调试输出
      
      notifyListeners();
    }
  }

  Future<bool> login({required String email, required String password}) async {
    try {
      final userData = await _db.getUserByEmail(email, password: password);
      if (userData != null) {
        _isLoggedIn = true;
        _userId = userData['userId'];
        _userEmail = email;
        
        // 保存登录状态到本地存储
        await _prefs.setString('userEmail', email);
        
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final success = await _db.createUser(
        email: email,
        password: password,
        name: name,
      );
      
      if (success) {
        return login(email: email, password: password);
      }
      return false;
    } catch (e) {
      print('Registration error: $e');
      return false;
    }
  }

  Future<void> logout() async {
    _isLoggedIn = false;
    _userId = null;
    _userEmail = null;
    await _prefs.remove('userEmail');
    notifyListeners();
  }
} 