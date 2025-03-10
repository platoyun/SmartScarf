import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  Database? _database;
  
  // 模拟数据库存储
  final Map<String, Map<String, dynamic>> _users = {
    'admin@warmsage.com': {
      'userId': 'admin_001',
      'email': 'admin@warmsage.com',
      'password': 'admin123',
      'name': 'Admin User',
    }
  };

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'warmsage.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        // 创建用户表
        await db.execute('''
          CREATE TABLE users(
            id TEXT PRIMARY KEY,
            email TEXT UNIQUE,
            password TEXT,
            name TEXT,
            device_id TEXT,
            device_name TEXT,
            device_status INTEGER DEFAULT 0,
            emergency_contact TEXT,           // 添加紧急联系人
            emergency_phone TEXT,             // 添加紧急电话
            emergency_contact2 TEXT,          // 第二紧急联系人
            emergency_phone2 TEXT             // 第二紧急电话
          )
        ''');

        // 创建健康数据表
        await db.execute('''
          CREATE TABLE health_data(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            device_id TEXT,
            timestamp INTEGER,
            blood_pressure_systolic INTEGER,  // 收缩压
            blood_pressure_diastolic INTEGER, // 舒张压
            heart_rate INTEGER,
            blood_sugar REAL,
            blood_oxygen INTEGER,
            temperature REAL,
            FOREIGN KEY (device_id) REFERENCES users (device_id)
          )
        ''');

        // 插入模拟用户数据
        await db.insert('users', {
          'id': 'user_001',
          'email': 'admin@warmsage.com',
          'password': 'admin123',
          'name': 'Admin User',
          'device_id': 'DEVICE_001',
          'device_name': 'WarmSage Pro',
          'device_status': 1,
          'emergency_contact': '张医生',
          'emergency_phone': '13800138000',
          'emergency_contact2': '李护士',
          'emergency_phone2': '13900139000'
        });

        // 插入模拟健康数据
        final now = DateTime.now();
        final List<Map<String, dynamic>> mockData = List.generate(
          24, // 生成24小时的数据
          (index) => {
            'device_id': 'DEVICE_001',
            'timestamp': now.subtract(Duration(hours: 23 - index)).millisecondsSinceEpoch,
            'blood_pressure_systolic': 110 + (index % 20),  // 改变范围
            'blood_pressure_diastolic': 70 + (index % 10),  // 改变范围
            'heart_rate': 75 + (index % 15),
            'blood_sugar': 5.5 + (index % 10) / 10,
            'blood_oxygen': 98 + (index % 3),
            'temperature': 36.5 + (index % 10) / 10,
          },
        );

        final batch = db.batch();
        for (var data in mockData) {
          batch.insert('health_data', data);
        }
        await batch.commit();
      },
    );
  }

  // 获取用户的最新健康数据
  Future<Map<String, dynamic>?> getLatestHealthData(String deviceId) async {
    final db = await database;
    final results = await db.query(
      'health_data',
      where: 'device_id = ?',
      whereArgs: [deviceId],
      orderBy: 'timestamp DESC',
      limit: 1,
    );
    return results.isNotEmpty ? results.first : null;
  }

  // 获取特定时间范围内的健康数据
  Future<List<Map<String, dynamic>>> getHealthDataInRange(
    String deviceId,
    DateTime start,
    DateTime end,
  ) async {
    final db = await database;
    return await db.query(
      'health_data',
      where: 'device_id = ? AND timestamp BETWEEN ? AND ?',
      whereArgs: [
        deviceId,
        start.millisecondsSinceEpoch,
        end.millisecondsSinceEpoch,
      ],
      orderBy: 'timestamp ASC',
    );
  }

  // 添加新的健康数据
  Future<bool> addHealthData(Map<String, dynamic> data) async {
    try {
      final db = await database;
      await db.insert('health_data', data);
      return true;
    } catch (e) {
      print('Error adding health data: $e');
      return false;
    }
  }

  // 获取用户设备状态
  Future<int> getDeviceStatus(String deviceId) async {
    final db = await database;
    final results = await db.query(
      'users',
      columns: ['device_status'],
      where: 'device_id = ?',
      whereArgs: [deviceId],
    );
    return results.isNotEmpty ? results.first['device_status'] as int : 0;
  }

  // 更新设备状态
  Future<bool> updateDeviceStatus(String deviceId, int status) async {
    try {
      final db = await database;
      await db.update(
        'users',
        {'device_status': status},
        where: 'device_id = ?',
        whereArgs: [deviceId],
      );
      return true;
    } catch (e) {
      print('Error updating device status: $e');
      return false;
    }
  }

  // 模拟初始化
  Future<void> initialize() async {
    await Future.delayed(const Duration(milliseconds: 500));
    print('Database initialized with ${_users.length} users');
  }

  // 检查用户是否存在
  Future<bool> checkUserExists(String email) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _users.containsKey(email);
  }

  // 获取用户信息
  Future<Map<String, dynamic>?> getUserByEmail(String email, {String? password}) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> results = await db.query(
        'users',
        where: 'email = ?',
        whereArgs: [email],
      );

      if (results.isEmpty) return null;
      
      final user = results.first;
      if (password != null && user['password'] != password) {
        return null;
      }

      return {
        'userId': user['id'],
        'email': user['email'],
        'name': user['name'],
      };
    } catch (e) {
      print('Error getting user: $e');
      return null;
    }
  }

  // 创建新用户
  Future<bool> createUser({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final db = await database;
      final id = 'user_${DateTime.now().millisecondsSinceEpoch}';
      
      await db.insert('users', {
        'id': id,
        'email': email,
        'password': password,
        'name': name,
      });
      return true;
    } catch (e) {
      print('Error creating user: $e');
      return false;
    }
  }

  // 获取所有用户（不包含密码）
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    return _users.values.map((user) => {
      'userId': user['userId'],
      'email': user['email'],
      'name': user['name'],
    }).toList();
  }

  // 更新用户信息
  Future<bool> updateUser({
    required String email,
    String? newPassword,
    String? newName,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    final user = _users[email];
    if (user == null) return false;

    if (newPassword != null) {
      user['password'] = newPassword;
    }
    if (newName != null) {
      user['name'] = newName;
    }

    return true;
  }

  // 删除用户
  Future<bool> deleteUser(String email) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    if (!_users.containsKey(email)) return false;
    
    _users.remove(email);
    return true;
  }

  // 获取用户的紧急联系人信息
  Future<List<Map<String, String>>> getEmergencyContacts(String userId) async {
    final db = await database;
    final results = await db.query(
      'users',
      columns: ['emergency_contact', 'emergency_phone', 'emergency_contact2', 'emergency_phone2'],
      where: 'id = ?',
      whereArgs: [userId],
    );

    if (results.isEmpty) return [];

    final user = results.first;
    return [
      if (user['emergency_contact'] != null && user['emergency_phone'] != null)
        {
          'name': user['emergency_contact'] as String,
          'phone': user['emergency_phone'] as String,
        },
      if (user['emergency_contact2'] != null && user['emergency_phone2'] != null)
        {
          'name': user['emergency_contact2'] as String,
          'phone': user['emergency_phone2'] as String,
        },
    ];
  }

  // 更新紧急联系人信息
  Future<bool> updateEmergencyContact(
    String userId, {
    String? contact1Name,
    String? contact1Phone,
    String? contact2Name,
    String? contact2Phone,
  }) async {
    try {
      final db = await database;
      final updates = <String, dynamic>{};
      
      if (contact1Name != null) updates['emergency_contact'] = contact1Name;
      if (contact1Phone != null) updates['emergency_phone'] = contact1Phone;
      if (contact2Name != null) updates['emergency_contact2'] = contact2Name;
      if (contact2Phone != null) updates['emergency_phone2'] = contact2Phone;

      if (updates.isEmpty) return true;

      await db.update(
        'users',
        updates,
        where: 'id = ?',
        whereArgs: [userId],
      );
      return true;
    } catch (e) {
      print('Error updating emergency contacts: $e');
      return false;
    }
  }

  Future<void> addNewHealthData() async {
    await addHealthData({
      'device_id': 'DEVICE_001',
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'blood_pressure_systolic': 125,
      'blood_pressure_diastolic': 85,
      // ... 其他数据
    });
  }
} 