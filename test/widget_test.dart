import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_garden/ExpertSystem.dart';
import 'package:smart_garden/main.dart';

void main() {
  test('knowledge base mendukung lima tanaman', () {
    expect(ExpertSystem.knowledgeBase.keys, [
      'Cabai',
      'Tomat',
      'Terong',
      'Sawi',
      'Timun',
    ]);
  });

  test('Tunas memberi peringatan ketika cabai terlalu panas dan kering', () {
    final advice = ExpertSystem.getSaran(
      suhu: 36,
      kelembapanUdara: 45,
      kelembapanTanah: 30,
      jenisTanaman: 'Cabai',
    );

    expect(advice, contains('terlalu panas'));
    expect(advice, contains('terlalu kering'));
    expect(advice, contains('Pupuk:'));
    expect(advice, contains('Pencegahan:'));
  });

  test('Tunas menyimpulkan cuaca dari sensor tanpa input musim', () {
    final weather = ExpertSystem.inferCuaca(
      suhu: 27,
      kelembapanUdara: 90,
      kelembapanTanah: 80,
    );

    expect(weather.kind, WeatherKind.rain);
    expect(weather.inferredSeason, 'Musim Hujan');
  });

  test('Hari 1 memberi misi tanam dan belum memakai pupuk kimia', () {
    final mission = ExpertSystem.getDailyMission(
      jenisTanaman: 'Cabai',
      day: 1,
      suhu: 27,
      kelembapanUdara: 60,
      kelembapanTanah: 65,
    );

    expect(mission.phase, 'Mulai Menanam');
    expect(mission.fertilizerToday, isFalse);
    expect(mission.tasks.join(' '), contains('Belum perlu pupuk'));
  });

  test('Cabai dapat diselesaikan ketika mencapai umur panen', () {
    final mission = ExpertSystem.getDailyMission(
      jenisTanaman: 'Cabai',
      day: 90,
      suhu: 27,
      kelembapanUdara: 60,
      kelembapanTanah: 65,
    );

    expect(mission.harvestReady, isTrue);
    expect(mission.title, 'Saatnya panen!');
  });

  testWidgets('dashboard menampilkan Tunas AI Agent', (tester) async {
    await tester.pumpWidget(const SmartGardenApp());
    expect(find.text('Smart Garden'), findsOneWidget);
    expect(find.text('Tunas AI Agent'), findsOneWidget);
    expect(find.text('Perjalanan Tanaman'), findsOneWidget);
    expect(find.text('Mulai Menanam Cabai'), findsOneWidget);
  });

  testWidgets('timeline game tidak overflow pada layar mobile', (tester) async {
    await tester.binding.setSurfaceSize(const Size(360, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const SmartGardenApp());
    expect(tester.takeException(), isNull);
    expect(find.text('Preview Hari'), findsOneWidget);
  });
}
