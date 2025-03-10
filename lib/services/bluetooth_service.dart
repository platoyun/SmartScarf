// import 'package:flutter_blue/flutter_blue.dart';
import '../models/device_data.dart';
import 'device_data_service.dart';

class BluetoothService {
  final DeviceDataService _dataService = DeviceDataService();
  
  // 处理接收到的蓝牙数据
  void handleDeviceData(List<int> data, String deviceId) {
    // 解析蓝牙数据
    final deviceData = DeviceData(
      deviceId: deviceId,
      timestamp: DateTime.now(),
      temperature: parseTemperature(data),
      bloodPressure: parseBloodPressure(data),
      heartRate: parseHeartRate(data),
      sugarLevel: parseSugarLevel(data),
      hemoglobin: parseHemoglobin(data),
      batteryLevel: parseBatteryLevel(data),
    );
    
    // 存储到数据库
    _dataService.insertData(deviceData);
  }

  // 解析温度数据
  double parseTemperature(List<int> data) {
    // 这里是示例实现，需要根据实际设备的数据格式进行修改
    try {
      // 假设温度数据在前两个字节，以0.1℃为单位
      int rawTemp = (data[0] << 8) | data[1];
      return rawTemp / 10.0;
    } catch (e) {
      print('Error parsing temperature: $e');
      return 36.5; // 返回默认值
    }
  }

  // 解析血压数据
  String parseBloodPressure(List<int> data) {
    try {
      // 假设收缩压和舒张压分别在不同字节
      int systolic = data[2];
      int diastolic = data[3];
      return '$systolic/$diastolic';
    } catch (e) {
      print('Error parsing blood pressure: $e');
      return '120/80'; // 返回默认值
    }
  }

  // 解析心率数据
  int parseHeartRate(List<int> data) {
    try {
      // 假设心率数据在第4个字节
      return data[4];
    } catch (e) {
      print('Error parsing heart rate: $e');
      return 75; // 返回默认值
    }
  }

  // 解析血糖数据
  double parseSugarLevel(List<int> data) {
    try {
      // 假设血糖数据在第5、6个字节，以0.1 mmol/L为单位
      int rawSugar = (data[5] << 8) | data[6];
      return rawSugar / 10.0;
    } catch (e) {
      print('Error parsing sugar level: $e');
      return 5.5; // 返回默认值
    }
  }

  // 解析血红蛋白数据
  double parseHemoglobin(List<int> data) {
    try {
      // 假设血红蛋白数据在第7个字节，以g/dL为单位
      return data[7].toDouble();
    } catch (e) {
      print('Error parsing hemoglobin: $e');
      return 15.0; // 返回默认值
    }
  }

  // 解析电池电量数据
  int parseBatteryLevel(List<int> data) {
    try {
      // 假设电池电量在最后一个字节，以百分比表示
      return data[8];
    } catch (e) {
      print('Error parsing battery level: $e');
      return 100; // 返回默认值
    }
  }
} 