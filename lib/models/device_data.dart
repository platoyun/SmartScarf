class DeviceData {
  final int? id;
  final String deviceId;
  final DateTime timestamp;
  final double temperature;
  final String bloodPressure;
  final int heartRate;
  final double sugarLevel;
  final double hemoglobin;
  final int batteryLevel;

  DeviceData({
    this.id,
    required this.deviceId,
    required this.timestamp,
    required this.temperature,
    required this.bloodPressure,
    required this.heartRate,
    required this.sugarLevel,
    required this.hemoglobin,
    required this.batteryLevel,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'device_id': deviceId,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'temperature': temperature,
      'blood_pressure': bloodPressure,
      'heart_rate': heartRate,
      'sugar_level': sugarLevel,
      'hemoglobin': hemoglobin,
      'battery_level': batteryLevel,
    };
  }

  factory DeviceData.fromMap(Map<String, dynamic> map) {
    return DeviceData(
      id: map['id'],
      deviceId: map['device_id'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
      temperature: map['temperature'],
      bloodPressure: map['blood_pressure'],
      heartRate: map['heart_rate'],
      sugarLevel: map['sugar_level'],
      hemoglobin: map['hemoglobin'],
      batteryLevel: map['battery_level'],
    );
  }
} 