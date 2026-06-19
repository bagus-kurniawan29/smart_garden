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

  testWidgets('dashboard menampilkan Tunas AI Agent', (tester) async {
    await tester.pumpWidget(const SmartGardenApp());
    expect(find.text('Smart Garden'), findsOneWidget);
    expect(find.text('Tunas AI Agent'), findsOneWidget);
  });
}
