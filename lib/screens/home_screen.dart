import 'package:flutter/material.dart';
import '../providers/auth_provider.dart';
import '../services/database_service.dart';
import '../widgets/health_data_card.dart';
import 'package:fl_chart/fl_chart.dart';
import '../screens/emergency_contacts_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late DatabaseService _db;
  Map<String, dynamic>? _latestData;
  List<Map<String, dynamic>>? _recentData;

  @override
  void initState() {
    super.initState();
    _db = DatabaseService();
    _loadData();
  }

  Future<void> _loadData() async {
    final deviceId = 'DEVICE_001'; // 这里应该从用户数据中获取
    final now = DateTime.now();
    final oneMinuteAgo = now.subtract(const Duration(minutes: 1));

    final latest = await _db.getLatestHealthData(deviceId);
    final recent = await _db.getHealthDataInRange(deviceId, oneMinuteAgo, now);

    setState(() {
      _latestData = latest;
      _recentData = recent;
    });
  }

  String _getBloodPressureStatus(int systolic, int diastolic) {
    if (systolic < 120 && diastolic < 80) return '正常';
    if (systolic < 130 && diastolic < 80) return '正常偏高';
    return '偏高';
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    if (_latestData == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final heartRateData =
        _recentData?.map((data) {
          return FlSpot(
            data['timestamp'].toDouble(),
            data['heart_rate'].toDouble(),
          );
        }).toList();

    final bloodOxygenData =
        _recentData?.map((data) {
          return FlSpot(
            data['timestamp'].toDouble(),
            data['blood_oxygen'].toDouble(),
          );
        }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Warm Sage'),
        leading: const Icon(Icons.notifications),
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => EmergencyContactsScreen(
                        userId: 'user_001', // 这里应该使用实际的用户ID
                      ),
                ),
              );
            },
            child: CircleAvatar(
              child: const Icon(Icons.person),
              backgroundColor: Colors.grey[300],
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // 蓝色大框
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.blue[100],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Device Name',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'Slogan something...',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // 左侧三个图标
                        Row(
                          children: [
                            SvgPicture.asset(
                              'assets/images/GPS.svg',
                              height: 24,
                              width: 24,
                            ),
                            const SizedBox(width: 16),
                            SvgPicture.asset(
                              'assets/images/diedao.svg',
                              height: 24,
                              width: 24,
                            ),
                            const SizedBox(width: 16),
                            SvgPicture.asset(
                              'assets/images/lanya.svg',
                              height: 24,
                              width: 24,
                            ),
                          ],
                        ),
                        // 右侧电池显示
                        Column(
                          children: [
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  height: 60,
                                  width: 60,
                                  child: CircularProgressIndicator(
                                    value: 0.75, // 75%电量
                                    backgroundColor: Colors.grey[300],
                                    color: Colors.green,
                                    strokeWidth: 8,
                                  ),
                                ),
                                const Text('Battery'),
                              ],
                            ),
                            const Text('75%'),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // 2x2 健康指标网格
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.5,
                children: [
                  HealthDataCard(
                    title: '血压',
                    currentValue:
                        '${_latestData!['blood_pressure_systolic']}/${_latestData!['blood_pressure_diastolic']}',
                    unit: 'mmHg',
                    color: Colors.blue,
                    status: _getBloodPressureStatus(
                      _latestData!['blood_pressure_systolic'],
                      _latestData!['blood_pressure_diastolic'],
                    ),
                  ),
                  HealthDataCard(
                    title: '心率',
                    currentValue: '${_latestData!['heart_rate']}',
                    unit: 'bpm',
                    color: Colors.red,
                    chartData: heartRateData,
                  ),
                  HealthDataCard(
                    title: '血糖',
                    currentValue: _latestData!['blood_sugar'].toStringAsFixed(
                      1,
                    ),
                    unit: 'mmol/L',
                    color: Colors.orange,
                  ),
                  HealthDataCard(
                    title: '血氧',
                    currentValue: '${_latestData!['blood_oxygen']}',
                    unit: '%',
                    color: Colors.purple,
                    chartData: bloodOxygenData,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // 温度控制
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      'Current Temperature',
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: () {},
                        ),
                        const Text(
                          '26°C',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // SOS按钮
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'SOS Emergency Call',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
