import 'package:sqflite/sqflite.dart';
import '../models/device_data.dart';
import 'database_service.dart';

class DeviceDataService {
  final DatabaseService _db = DatabaseService();

  // 插入设备数据
  Future<bool> insertData(DeviceData data) async {
    try {
      final db = await _db.database;
      await db.insert('health_data', {
        'device_id': data.deviceId,
        'timestamp': data.timestamp.millisecondsSinceEpoch,
        'blood_pressure_systolic': int.parse(data.bloodPressure.split('/')[0]),
        'blood_pressure_diastolic': int.parse(data.bloodPressure.split('/')[1]),
        'heart_rate': data.heartRate,
        'blood_sugar': data.sugarLevel,
        'blood_oxygen': data.hemoglobin.round(),
        'temperature': data.temperature,
      });
      return true;
    } catch (e) {
      print('Error inserting device data: $e');
      return false;
    }
  }

  // 获取最新数据
  Future<DeviceData?> getLatestData(String deviceId) async {
    try {
      final data = await _db.getLatestHealthData(deviceId);
      if (data == null) return null;

      return DeviceData(
        id: data['id'],
        deviceId: data['device_id'],
        timestamp: DateTime.fromMillisecondsSinceEpoch(data['timestamp']),
        temperature: data['temperature'],
        bloodPressure: '${data['blood_pressure_systolic']}/${data['blood_pressure_diastolic']}',
        heartRate: data['heart_rate'],
        sugarLevel: data['blood_sugar'],
        hemoglobin: data['blood_oxygen'].toDouble(),
        batteryLevel: 100, // 这里需要从实际设备获取
      );
    } catch (e) {
      print('Error getting latest device data: $e');
      return null;
    }
  }

  // 获取时间范围内的数据
  Future<List<DeviceData>> getDataInRange(
    String deviceId,
    DateTime start,
    DateTime end,
  ) async {
    try {
      final dataList = await _db.getHealthDataInRange(deviceId, start, end);
      return dataList.map((data) => DeviceData(
        id: data['id'],
        deviceId: data['device_id'],
        timestamp: DateTime.fromMillisecondsSinceEpoch(data['timestamp']),
        temperature: data['temperature'],
        bloodPressure: '${data['blood_pressure_systolic']}/${data['blood_pressure_diastolic']}',
        heartRate: data['heart_rate'],
        sugarLevel: data['blood_sugar'],
        hemoglobin: data['blood_oxygen'].toDouble(),
        batteryLevel: 100, // 这里需要从实际设备获取
      )).toList();
    } catch (e) {
      print('Error getting device data range: $e');
      return [];
    }
  }
} 