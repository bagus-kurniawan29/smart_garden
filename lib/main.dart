import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'ExpertSystem.dart';
import 'PlantJourneyWidget.dart';
import 'TunasAgentWidget.dart';
import 'garden_database.dart';

void main() {
  runApp(const SmartGardenApp());
}

class SmartGardenApp extends StatelessWidget {
  const SmartGardenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Garden Monitor',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF10B981),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF3F6F4),
        textTheme: Theme.of(context).textTheme.apply(
          bodyColor: const Color(0xFF122033),
          displayColor: const Color(0xFF122033),
        ),
      ),
      home: const DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  static const int hotTemperatureLimit = 34;
  static const int lowSoilLimit = 40;
  static const int highAirHumidityLimit = 85;

  int suhu = 31;
  int lembapUdara = 33;
  int lembapTanah = 68;
  String selectedPlant = 'Cabai';
  DateTime lastUpdate = DateTime.now();
  DateTime? lastFertilized;
  CropCycle? activeCropCycle;
  bool _cycleBusy = false;
  Timer? timer;
  String? _lastToastKey;

  final List<SensorRecord> history = [
    SensorRecord(
      31,
      33,
      68,
      DateTime.now().subtract(const Duration(minutes: 2)),
    ),
    SensorRecord(
      34,
      78,
      72,
      DateTime.now().subtract(const Duration(minutes: 6)),
    ),
    SensorRecord(
      36,
      60,
      65,
      DateTime.now().subtract(const Duration(minutes: 9)),
    ),
    SensorRecord(
      31,
      45,
      58,
      DateTime.now().subtract(const Duration(minutes: 13)),
    ),
    SensorRecord(
      30,
      51,
      55,
      DateTime.now().subtract(const Duration(minutes: 16)),
    ),
  ];

  int? get daysSinceFertilized => lastFertilized == null
      ? null
      : DateTime.now().difference(lastFertilized!).inDays;

  bool get fertilizationDue =>
      daysSinceFertilized == null || daysSinceFertilized! >= 7;

  PlantProfile get selectedPlantProfile =>
      ExpertSystem.getProfile(selectedPlant);

  int? get currentCropDay => activeCropCycle?.currentDay;

  DailyMission? get dailyMission => currentCropDay == null
      ? null
      : ExpertSystem.getDailyMission(
          jenisTanaman: selectedPlant,
          day: currentCropDay!,
          suhu: suhu.toDouble(),
          kelembapanUdara: lembapUdara.toDouble(),
          kelembapanTanah: lembapTanah.toDouble(),
        );

  WeatherInsight get tunasWeather => ExpertSystem.inferCuaca(
    suhu: suhu.toDouble(),
    kelembapanUdara: lembapUdara.toDouble(),
    kelembapanTanah: lembapTanah.toDouble(),
  );

  String get tunasAdvice => ExpertSystem.getSaran(
    suhu: suhu.toDouble(),
    kelembapanUdara: lembapUdara.toDouble(),
    kelembapanTanah: lembapTanah.toDouble(),
    jenisTanaman: selectedPlant,
  );

  List<GardenAlert> get alerts {
    final items = <GardenAlert>[];

    if (suhu >= hotTemperatureLimit) {
      items.add(
        GardenAlert(
          title: 'Suhu terlalu panas',
          message: 'Suhu $suhu C melewati batas $hotTemperatureLimit C.',
          color: const Color(0xFFDC2626),
          icon: Icons.local_fire_department_rounded,
          key: 'hot',
        ),
      );
    }

    if (lembapTanah <= lowSoilLimit) {
      items.add(
        GardenAlert(
          title: 'Tanah mulai kering',
          message: 'Kelembapan tanah $lembapTanah%, perlu cek penyiraman.',
          color: const Color(0xFFF97316),
          icon: Icons.water_drop_outlined,
          key: 'soil',
        ),
      );
    }

    if (lembapUdara >= highAirHumidityLimit) {
      items.add(
        GardenAlert(
          title: 'Kelembapan udara tinggi',
          message: 'Kelembapan $lembapUdara%, rawan jamur pada daun.',
          color: const Color(0xFF2563EB),
          icon: Icons.cloudy_snowing,
          key: 'air',
        ),
      );
    }

    if (fertilizationDue) {
      final fertilizerMessage = daysSinceFertilized == null
          ? 'Belum ada riwayat pemupukan di database.'
          : 'Terakhir dipupuk $daysSinceFertilized hari lalu.';
      items.add(
        GardenAlert(
          title: 'Jadwal pupuk sudah masuk',
          message: fertilizerMessage,
          color: const Color(0xFFDC2626),
          icon: Icons.notification_important_rounded,
          key: 'fertilizer',
        ),
      );
    }

    return items;
  }

  OfflineWeatherForecast get forecast {
    final recent = history.take(5).toList();
    final avgTemp =
        recent.map((e) => e.temperature).reduce((a, b) => a + b) /
        recent.length;
    final avgAir =
        recent.map((e) => e.airHumidity).reduce((a, b) => a + b) /
        recent.length;
    final avgSoil =
        recent.map((e) => e.soilHumidity).reduce((a, b) => a + b) /
        recent.length;

    final insight = ExpertSystem.inferCuaca(
      suhu: avgTemp,
      kelembapanUdara: avgAir,
      kelembapanTanah: avgSoil,
    );
    final (icon, color) = switch (insight.kind) {
      WeatherKind.rain => (Icons.thunderstorm_rounded, const Color(0xFF2563EB)),
      WeatherKind.hot => (Icons.wb_sunny_rounded, const Color(0xFFDC2626)),
      WeatherKind.humid => (Icons.cloud_rounded, const Color(0xFF0284C7)),
      WeatherKind.stable => (Icons.eco_rounded, const Color(0xFF10B981)),
    };

    return OfflineWeatherForecast(
      title: 'Prediksi Tunas: ${insight.condition}',
      description: insight.description,
      icon: icon,
      color: color,
    );
  }

  @override
  void initState() {
    super.initState();
    _loadPlantData();
    fetchData();
    timer = Timer.periodic(
      const Duration(seconds: 3),
      (Timer t) => fetchData(),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _showAlertToast());
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> fetchData() async {
    try {
      final response = await http
          .get(Uri.parse('http://192.168.4.1/data'))
          .timeout(const Duration(seconds: 2));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final nextSuhu = _asInt(data['suhu'], fallback: suhu);
        final nextUdara = _asInt(
          data['kelembapan_udara'],
          fallback: lembapUdara,
        );
        final nextTanah = _asInt(
          data['kelembapan_tanah'],
          fallback: lembapTanah,
        );

        setState(() {
          suhu = nextSuhu;
          lembapUdara = nextUdara;
          lembapTanah = nextTanah;
          lastUpdate = DateTime.now();
          history.insert(
            0,
            SensorRecord(nextSuhu, nextUdara, nextTanah, lastUpdate),
          );
          if (history.length > 10) {
            history.removeLast();
          }
        });
        _showAlertToast();
      }
    } catch (_) {
      // ESP8266 biasanya memakai Wi-Fi lokal tanpa internet. Data terakhir tetap dipakai.
    }
  }

  int _asInt(dynamic value, {required int fallback}) {
    if (value is int) return value;
    if (value is double) return value.round();
    return int.tryParse(value.toString()) ?? fallback;
  }

  Future<void> _loadPlantData() async {
    final plant = selectedPlant;
    final savedDate = await GardenDatabase.instance.getLastFertilization(plant);
    final cropCycle = await GardenDatabase.instance.getActiveCropCycle(plant);
    if (!mounted || selectedPlant != plant) return;
    setState(() {
      lastFertilized = savedDate;
      activeCropCycle = cropCycle;
    });
  }

  void _changePlant(String plant) {
    if (plant == selectedPlant) return;
    setState(() {
      selectedPlant = plant;
      lastFertilized = null;
      activeCropCycle = null;
    });
    _loadPlantData();
  }

  Future<void> _startCropJourney() async {
    setState(() => _cycleBusy = true);
    final cycle = await GardenDatabase.instance.startCropCycle(selectedPlant);
    if (!mounted) return;
    setState(() {
      activeCropCycle = cycle;
      _cycleBusy = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Perjalanan $selectedPlant dimulai. Selamat datang di Hari 1!',
        ),
        backgroundColor: const Color(0xFF15803D),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _completeCropJourney() async {
    final cycle = activeCropCycle;
    if (cycle == null || dailyMission?.harvestReady != true) return;
    setState(() => _cycleBusy = true);
    await GardenDatabase.instance.completeCropCycle(cycle);
    if (!mounted) return;
    setState(() {
      activeCropCycle = null;
      _cycleBusy = false;
    });
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(
          Icons.emoji_events_rounded,
          color: Color(0xFFF59E0B),
          size: 54,
        ),
        title: const Text('Perjalanan Selesai!'),
        content: Text(
          'Selamat, $selectedPlant kamu sudah mencapai waktu panen. Kamu bisa memulai perjalanan tanaman baru.',
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Keren!'),
          ),
        ],
      ),
    );
  }

  Future<void> _markFertilizedToday() async {
    final recordedAt = await GardenDatabase.instance.recordFertilization(
      selectedPlant,
    );
    if (!mounted) return;
    setState(() {
      lastFertilized = recordedAt;
      _lastToastKey = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Pemupukan $selectedPlant tersimpan di database. Pengingat dimulai ulang.',
        ),
        backgroundColor: const Color(0xFF0F766E),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showAlertToast() {
    if (!mounted || alerts.isEmpty) return;
    final alert = alerts.first;
    final key = '${alert.key}-${DateTime.now().hour}-${DateTime.now().minute}';
    if (_lastToastKey == key) return;
    _lastToastKey = key;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(alert.icon, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(child: Text('${alert.title}: ${alert.message}')),
          ],
        ),
        backgroundColor: alert.color,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isWide = width >= 900;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1180),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Header(
                    lastUpdate: _formatDateTime(lastUpdate),
                    alertCount: alerts.length,
                  ),
                  const SizedBox(height: 18),
                  _ResponsiveGrid(
                    minItemWidth: 220,
                    spacing: 14,
                    children: [
                      SensorPieCard(
                        title: 'Suhu Udara',
                        value: suhu,
                        unit: 'C',
                        maxValue: 50,
                        status: temperatureStatus(suhu),
                        icon: Icons.thermostat_rounded,
                      ),
                      SensorPieCard(
                        title: 'Kelembapan Udara',
                        value: lembapUdara,
                        unit: '%',
                        maxValue: 100,
                        status: airHumidityStatus(lembapUdara),
                        icon: Icons.water_drop_rounded,
                      ),
                      SensorPieCard(
                        title: 'Kelembapan Tanah',
                        value: lembapTanah,
                        unit: '%',
                        maxValue: 100,
                        status: soilHumidityStatus(lembapTanah),
                        icon: Icons.grass_rounded,
                      ),
                      StatusCard(
                        due: fertilizationDue,
                        daysSince: daysSinceFertilized,
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  AlertsPanel(alerts: alerts),
                  const SizedBox(height: 18),
                  PlantJourneyWidget(
                    selectedPlant: selectedPlant,
                    profile: selectedPlantProfile,
                    currentDay: currentCropDay,
                    mission: dailyMission,
                    startedAt: activeCropCycle?.startedAt,
                    busy: _cycleBusy,
                    onPlantChanged: _changePlant,
                    onStart: _startCropJourney,
                    onComplete: _completeCropJourney,
                  ),
                  const SizedBox(height: 18),
                  TunasAgentWidget(
                    saran: tunasAdvice,
                    jenisTanaman: selectedPlant,
                    cuaca: tunasWeather,
                    currentDay: currentCropDay,
                    suhu: suhu,
                    kelembapanUdara: lembapUdara,
                    kelembapanTanah: lembapTanah,
                    onPlantChanged: _changePlant,
                  ),
                  const SizedBox(height: 18),
                  if (isWide)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 6,
                          child: ChartPanel(records: history.reversed.toList()),
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          flex: 4,
                          child: Column(
                            children: [
                              OfflineWeatherPanel(forecast: forecast),
                              const SizedBox(height: 18),
                              TaskPanel(
                                due: fertilizationDue,
                                daysSince: daysSinceFertilized,
                                lastFertilized: lastFertilized == null
                                    ? 'Belum pernah'
                                    : _formatDate(lastFertilized!),
                                onDone: _markFertilizedToday,
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  else ...[
                    ChartPanel(records: history.reversed.toList()),
                    const SizedBox(height: 18),
                    OfflineWeatherPanel(forecast: forecast),
                    const SizedBox(height: 18),
                    TaskPanel(
                      due: fertilizationDue,
                      daysSince: daysSinceFertilized,
                      lastFertilized: lastFertilized == null
                          ? 'Belum pernah'
                          : _formatDate(lastFertilized!),
                      onDone: _markFertilizedToday,
                    ),
                  ],
                  const SizedBox(height: 18),
                  HistoryPanel(records: history),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime value) {
    return '${value.day.toString().padLeft(2, '0')}/'
        '${value.month.toString().padLeft(2, '0')}/${value.year}';
  }

  String _formatDateTime(DateTime value) {
    return '${_formatDate(value)} '
        '${value.hour.toString().padLeft(2, '0')}:'
        '${value.minute.toString().padLeft(2, '0')}:'
        '${value.second.toString().padLeft(2, '0')}';
  }
}

class SensorRecord {
  SensorRecord(
    this.temperature,
    this.airHumidity,
    this.soilHumidity,
    this.time,
  );

  final int temperature;
  final int airHumidity;
  final int soilHumidity;
  final DateTime time;
}

class SensorStatus {
  const SensorStatus({
    required this.label,
    required this.color,
    required this.description,
  });

  final String label;
  final Color color;
  final String description;
}

class GardenAlert {
  const GardenAlert({
    required this.title,
    required this.message,
    required this.color,
    required this.icon,
    required this.key,
  });

  final String title;
  final String message;
  final Color color;
  final IconData icon;
  final String key;
}

class OfflineWeatherForecast {
  const OfflineWeatherForecast({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });

  final String title;
  final String description;
  final IconData icon;
  final Color color;
}

SensorStatus temperatureStatus(int value) {
  if (value >= 35) {
    return const SensorStatus(
      label: 'Panas',
      color: Color(0xFFDC2626),
      description: 'Butuh perhatian',
    );
  }
  if (value >= 28) {
    return const SensorStatus(
      label: 'Hangat',
      color: Color(0xFFF59E0B),
      description: 'Masih normal',
    );
  }
  return const SensorStatus(
    label: 'Dingin',
    color: Color(0xFF0284C7),
    description: 'Suhu rendah',
  );
}

SensorStatus airHumidityStatus(int value) {
  if (value >= 85) {
    return const SensorStatus(
      label: 'Sangat lembap',
      color: Color(0xFF2563EB),
      description: 'Rawan jamur',
    );
  }
  if (value >= 45) {
    return const SensorStatus(
      label: 'Ideal',
      color: Color(0xFF10B981),
      description: 'Udara aman',
    );
  }
  return const SensorStatus(
    label: 'Kering',
    color: Color(0xFFF97316),
    description: 'Udara kering',
  );
}

SensorStatus soilHumidityStatus(int value) {
  if (value <= 35) {
    return const SensorStatus(
      label: 'Kering',
      color: Color(0xFFDC2626),
      description: 'Perlu siram',
    );
  }
  if (value <= 65) {
    return const SensorStatus(
      label: 'Cukup',
      color: Color(0xFFF59E0B),
      description: 'Pantau berkala',
    );
  }
  return const SensorStatus(
    label: 'Basah',
    color: Color(0xFF2563EB),
    description: 'Air cukup',
  );
}

class Header extends StatelessWidget {
  const Header({super.key, required this.lastUpdate, required this.alertCount});

  final String lastUpdate;
  final int alertCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: const Color(0xFF134E4A),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.eco_rounded, color: Color(0xFF99F6E4)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Smart Garden',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Monitoring lokal ESP | Update $lastUpdate',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFFCBD5E1),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: alertCount > 0
                  ? const Color(0xFFDC2626)
                  : const Color(0xFF134E4A),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.notifications_active_rounded,
                  size: 18,
                  color: Colors.white,
                ),
                const SizedBox(width: 6),
                Text(
                  '$alertCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SensorPieCard extends StatelessWidget {
  const SensorPieCard({
    super.key,
    required this.title,
    required this.value,
    required this.unit,
    required this.maxValue,
    required this.status,
    required this.icon,
  });

  final String title;
  final int value;
  final String unit;
  final int maxValue;
  final SensorStatus status;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 174,
      padding: const EdgeInsets.all(17),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          SizedBox(
            width: 88,
            height: 88,
            child: CustomPaint(
              painter: DonutPainter(
                progress: (value / maxValue).clamp(0, 1),
                color: status.color,
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 18, color: status.color),
                    Text(
                      '$value$unit',
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title.toUpperCase(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  status.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: status.color,
                    fontSize: 23,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  status.description,
                  style: const TextStyle(color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class StatusCard extends StatelessWidget {
  const StatusCard({super.key, required this.due, required this.daysSince});

  final bool due;
  final int? daysSince;

  @override
  Widget build(BuildContext context) {
    final color = due ? const Color(0xFFDC2626) : const Color(0xFF10B981);

    return Container(
      height: 174,
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.task_alt_rounded, color: color),
              ),
              const Spacer(),
              Text(
                due ? 'ALERT' : 'AMAN',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                daysSince == null ? 'Belum' : '$daysSince hari',
                style: const TextStyle(
                  fontSize: 31,
                  height: 1,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                due ? 'Jadwal pupuk masuk' : 'Siklus pupuk aman',
                style: const TextStyle(color: Color(0xFF64748B)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class AlertsPanel extends StatelessWidget {
  const AlertsPanel({super.key, required this.alerts});

  final List<GardenAlert> alerts;

  @override
  Widget build(BuildContext context) {
    if (alerts.isEmpty) {
      return _Panel(title: 'Notifikasi Aktif', child: const _EmptyAlert());
    }

    return _Panel(
      title: 'Notifikasi Aktif',
      child: Column(
        children: alerts.map((alert) => _AlertTile(alert: alert)).toList(),
      ),
    );
  }
}

class OfflineWeatherPanel extends StatelessWidget {
  const OfflineWeatherPanel({super.key, required this.forecast});

  final OfflineWeatherForecast forecast;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      title: 'Perkiraan Cuaca Offline',
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: forecast.color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: forecast.color,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(forecast.icon, color: Colors.white),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    forecast.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    forecast.description,
                    style: const TextStyle(
                      color: Color(0xFF475569),
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChartPanel extends StatelessWidget {
  const ChartPanel({super.key, required this.records});

  final List<SensorRecord> records;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      title: 'Tren Sensor Terakhir',
      trailing: const _Legend(),
      child: SizedBox(
        height: 260,
        width: double.infinity,
        child: CustomPaint(painter: SensorChartPainter(records)),
      ),
    );
  }
}

class TaskPanel extends StatelessWidget {
  const TaskPanel({
    super.key,
    required this.due,
    required this.daysSince,
    required this.lastFertilized,
    required this.onDone,
  });

  final bool due;
  final int? daysSince;
  final String lastFertilized;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final color = due ? const Color(0xFFDC2626) : const Color(0xFF10B981);

    return _Panel(
      title: 'Task Kebun',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.11),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    due
                        ? Icons.notification_important_rounded
                        : Icons.check_rounded,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        due
                            ? 'Pemupukan perlu dilakukan'
                            : 'Pemupukan masih aman',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        daysSince == null
                            ? 'Belum ada catatan pemupukan'
                            : 'Terakhir: $lastFertilized | $daysSince hari lalu',
                        style: const TextStyle(color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _TaskRow(
            checked: !due,
            title: 'Siklus pemupukan 7 hari',
            subtitle: due ? 'Status: jatuh tempo' : 'Status: selesai',
          ),
          const SizedBox(height: 10),
          const _TaskRow(
            checked: true,
            title: 'Cek kelembapan tanah',
            subtitle: 'Pantau sebelum menyiram',
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton.icon(
              onPressed: onDone,
              icon: const Icon(Icons.task_alt_rounded),
              label: const Text('Tandai Pupuk Hari Ini'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF0F766E),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HistoryPanel extends StatelessWidget {
  const HistoryPanel({super.key, required this.records});

  final List<SensorRecord> records;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      title: 'Riwayat Data',
      child: Column(
        children: [
          const _HistoryHeader(),
          const Divider(height: 1),
          ...records.take(8).map((record) => _HistoryRow(record: record)),
        ],
      ),
    );
  }
}

class DonutPainter extends CustomPainter {
  DonutPainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = size.width * 0.12;
    final rect = Offset.zero & size;
    final arcRect = rect.deflate(strokeWidth / 2);
    final background = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    final foreground = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(arcRect, -math.pi / 2, math.pi * 2, false, background);
    canvas.drawArc(
      arcRect,
      -math.pi / 2,
      math.pi * 2 * progress,
      false,
      foreground,
    );
  }

  @override
  bool shouldRepaint(covariant DonutPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}

class SensorChartPainter extends CustomPainter {
  SensorChartPainter(this.records);

  final List<SensorRecord> records;

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..strokeWidth = 1;
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    final chartRect = Rect.fromLTWH(34, 12, size.width - 46, size.height - 42);

    for (var i = 0; i <= 4; i++) {
      final y = chartRect.top + chartRect.height * i / 4;
      canvas.drawLine(
        Offset(chartRect.left, y),
        Offset(chartRect.right, y),
        gridPaint,
      );
      textPainter.text = TextSpan(
        text: '${100 - i * 25}',
        style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(0, y - 7));
    }

    if (records.length < 2) return;

    _drawLine(
      canvas,
      chartRect,
      records.map((e) => e.temperature).toList(),
      const Color(0xFF0F9F8E),
      true,
    );
    _drawLine(
      canvas,
      chartRect,
      records.map((e) => e.airHumidity).toList(),
      const Color(0xFF2563EB),
      false,
    );
    _drawLine(
      canvas,
      chartRect,
      records.map((e) => e.soilHumidity).toList(),
      const Color(0xFFF59E0B),
      false,
    );
  }

  void _drawLine(
    Canvas canvas,
    Rect rect,
    List<int> values,
    Color color,
    bool fill,
  ) {
    final path = Path();
    final fillPath = Path();
    final points = <Offset>[];

    for (var i = 0; i < values.length; i++) {
      final x = rect.left + rect.width * i / math.max(1, values.length - 1);
      final y = rect.bottom - rect.height * (values[i].clamp(0, 100) / 100);
      points.add(Offset(x, y));
      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, rect.bottom);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    if (fill) {
      fillPath.lineTo(points.last.dx, rect.bottom);
      fillPath.close();
      canvas.drawPath(fillPath, Paint()..color = color.withValues(alpha: 0.12));
    }

    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    for (final point in points) {
      canvas.drawCircle(point, 4, Paint()..color = Colors.white);
      canvas.drawCircle(
        point,
        4,
        Paint()
          ..color = color
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke,
      );
    }
  }

  @override
  bool shouldRepaint(covariant SensorChartPainter oldDelegate) {
    return oldDelegate.records != records;
  }
}

class _ResponsiveGrid extends StatelessWidget {
  const _ResponsiveGrid({
    required this.children,
    required this.minItemWidth,
    required this.spacing,
  });

  final List<Widget> children;
  final double minItemWidth;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final count = math.max(
          1,
          ((constraints.maxWidth + spacing) / (minItemWidth + spacing)).floor(),
        );
        return GridView.builder(
          itemCount: children.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: count,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
            mainAxisExtent: 174,
          ),
          itemBuilder: (_, index) => children[index],
        );
      },
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.title, required this.child, this.trailing});

  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(borderRadius: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0,
                  ),
                ),
              ),
              ?trailing,
            ],
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }
}

class _AlertTile extends StatelessWidget {
  const _AlertTile({required this.alert});

  final GardenAlert alert;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: alert.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(alert.icon, color: alert.color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert.title,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 3),
                Text(
                  alert.message,
                  style: const TextStyle(color: Color(0xFF475569)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyAlert extends StatelessWidget {
  const _EmptyAlert();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF10B981).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Row(
        children: [
          Icon(Icons.check_circle_rounded, color: Color(0xFF10B981)),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Semua kondisi kebun aman. Tidak ada peringatan aktif.',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskRow extends StatelessWidget {
  const _TaskRow({
    required this.checked,
    required this.title,
    required this.subtitle,
  });

  final bool checked;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          checked
              ? Icons.check_circle_rounded
              : Icons.radio_button_unchecked_rounded,
          color: checked ? const Color(0xFF10B981) : const Color(0xFFF97316),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(subtitle, style: const TextStyle(color: Color(0xFF64748B))),
            ],
          ),
        ),
      ],
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    return const Wrap(
      spacing: 12,
      children: [
        _LegendItem(color: Color(0xFF0F9F8E), label: 'Suhu'),
        _LegendItem(color: Color(0xFF2563EB), label: 'Udara'),
        _LegendItem(color: Color(0xFFF59E0B), label: 'Tanah'),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
        ),
      ],
    );
  }
}

class _HistoryHeader extends StatelessWidget {
  const _HistoryHeader();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(child: Text('Waktu', style: _tableHeaderStyle)),
          Expanded(child: Text('Suhu', style: _tableHeaderStyle)),
          Expanded(child: Text('Udara', style: _tableHeaderStyle)),
          Expanded(child: Text('Tanah', style: _tableHeaderStyle)),
        ],
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.record});

  final SensorRecord record;

  @override
  Widget build(BuildContext context) {
    final time =
        '${record.time.hour.toString().padLeft(2, '0')}:${record.time.minute.toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 13),
      child: Row(
        children: [
          Expanded(child: Text(time, style: _tableBodyStyle)),
          Expanded(
            child: Text('${record.temperature} C', style: _tableBodyStyle),
          ),
          Expanded(
            child: Text('${record.airHumidity}%', style: _tableBodyStyle),
          ),
          Expanded(
            child: Text('${record.soilHumidity}%', style: _tableBodyStyle),
          ),
        ],
      ),
    );
  }
}

BoxDecoration _cardDecoration({double borderRadius = 22}) {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(borderRadius),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.05),
        blurRadius: 20,
        offset: const Offset(0, 12),
      ),
    ],
  );
}

const _tableHeaderStyle = TextStyle(
  color: Color(0xFF475569),
  fontWeight: FontWeight.w800,
  fontSize: 12,
);

const _tableBodyStyle = TextStyle(
  color: Color(0xFF1E293B),
  fontWeight: FontWeight.w600,
);
