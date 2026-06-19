// ignore_for_file: file_names

class PlantProfile {
  const PlantProfile({
    required this.name,
    required this.minTemperature,
    required this.maxTemperature,
    required this.minSoilMoisture,
    required this.maxSoilMoisture,
    required this.suitableSeasons,
    required this.fertilizer,
    required this.watering,
    required this.prevention,
  });

  final String name;
  final double minTemperature;
  final double maxTemperature;
  final double minSoilMoisture;
  final double maxSoilMoisture;
  final List<String> suitableSeasons;
  final String fertilizer;
  final String watering;
  final String prevention;
}

enum WeatherKind { rain, hot, humid, stable }

class WeatherInsight {
  const WeatherInsight({
    required this.kind,
    required this.condition,
    required this.inferredSeason,
    required this.description,
  });

  final WeatherKind kind;
  final String condition;
  final String inferredSeason;
  final String description;
}

class ExpertSystem {
  ExpertSystem._();

  static const List<String> supportedPlants = [
    'Cabai',
    'Tomat',
    'Terong',
    'Sawi',
    'Timun',
  ];

  static const Map<String, PlantProfile> knowledgeBase = {
    'Cabai': PlantProfile(
      name: 'Cabai',
      minTemperature: 24,
      maxTemperature: 30,
      minSoilMoisture: 55,
      maxSoilMoisture: 75,
      suitableSeasons: ['Musim Kemarau', 'Musim Peralihan'],
      fertilizer:
          'Gunakan NPK seimbang setiap 10-14 hari. Saat berbunga, pilih pupuk yang lebih kaya kalium.',
      watering:
          'Siram 1 kali pagi hari; tambah siram sore hanya saat tanah cepat kering.',
      prevention:
          'Jaga sirkulasi udara dan periksa kutu daun, trips, serta bercak antraknosa.',
    ),
    'Tomat': PlantProfile(
      name: 'Tomat',
      minTemperature: 22,
      maxTemperature: 29,
      minSoilMoisture: 60,
      maxSoilMoisture: 80,
      suitableSeasons: ['Musim Kemarau', 'Musim Peralihan'],
      fertilizer:
          'Berikan kompos saat tanam, lalu NPK rendah nitrogen setiap 10-14 hari setelah mulai berbunga.',
      watering:
          'Siram teratur 1 kali sehari pada pangkal tanaman dan hindari membasahi daun.',
      prevention:
          'Pasang ajir, pangkas daun bawah, dan pantau busuk daun serta lalat buah.',
    ),
    'Terong': PlantProfile(
      name: 'Terong',
      minTemperature: 24,
      maxTemperature: 32,
      minSoilMoisture: 55,
      maxSoilMoisture: 75,
      suitableSeasons: ['Musim Kemarau', 'Musim Peralihan'],
      fertilizer:
          'Gunakan kompos matang dan pupuk NPK setiap 14 hari dengan dosis bertahap.',
      watering:
          'Siram 1 kali sehari; pada cuaca sangat panas cek kembali kelembapan pada sore hari.',
      prevention:
          'Bersihkan gulma dan pantau kumbang daun, tungau, serta busuk buah.',
    ),
    'Sawi': PlantProfile(
      name: 'Sawi',
      minTemperature: 18,
      maxTemperature: 28,
      minSoilMoisture: 65,
      maxSoilMoisture: 85,
      suitableSeasons: ['Musim Hujan', 'Musim Peralihan'],
      fertilizer:
          'Gunakan kompos dan pupuk kaya nitrogen dengan dosis ringan setiap 7-10 hari.',
      watering:
          'Jaga media tetap lembap dengan siram ringan 1-2 kali sehari tanpa menggenangi akar.',
      prevention:
          'Periksa ulat daun dan busuk akar; beri jarak tanam agar daun cepat kering.',
    ),
    'Timun': PlantProfile(
      name: 'Timun',
      minTemperature: 23,
      maxTemperature: 30,
      minSoilMoisture: 60,
      maxSoilMoisture: 80,
      suitableSeasons: ['Musim Kemarau', 'Musim Peralihan'],
      fertilizer:
          'Berikan kompos, lalu pupuk NPK kaya kalium saat tanaman mulai berbunga.',
      watering:
          'Siram merata 1 kali sehari dan pertahankan kelembapan stabil saat pembentukan buah.',
      prevention:
          'Gunakan rambatan, buang daun sakit, dan pantau embun tepung serta lalat buah.',
    ),
  };

  static PlantProfile getProfile(String plantType) {
    return knowledgeBase[plantType] ?? knowledgeBase['Cabai']!;
  }

  static WeatherInsight inferCuaca({
    required double suhu,
    required double kelembapanUdara,
    required double kelembapanTanah,
  }) {
    if (kelembapanUdara >= 82 && kelembapanTanah >= 65) {
      return const WeatherInsight(
        kind: WeatherKind.rain,
        condition: 'Berpotensi hujan',
        inferredSeason: 'Musim Hujan',
        description:
            'Udara dan tanah sama-sama lembap. Tunas memperkirakan hujan atau embun tebal; tunda penyiraman dan jaga drainase.',
      );
    }

    if (suhu >= 33 && kelembapanUdara < 60) {
      return const WeatherInsight(
        kind: WeatherKind.hot,
        condition: 'Panas dan kering',
        inferredSeason: 'Musim Kemarau',
        description:
            'Suhu tinggi dengan udara kering. Tunas memperkirakan cuaca panas; cek air tanaman pada pagi dan sore.',
      );
    }

    if (kelembapanUdara >= 70) {
      return const WeatherInsight(
        kind: WeatherKind.humid,
        condition: 'Berawan dan lembap',
        inferredSeason: 'Musim Peralihan',
        description:
            'Udara cukup lembap dan berpotensi berawan. Pantau jamur daun serta perubahan cuaca mendadak.',
      );
    }

    return const WeatherInsight(
      kind: WeatherKind.stable,
      condition: 'Cerah stabil',
      inferredSeason: 'Musim Kemarau',
      description:
          'Data sensor menunjukkan kondisi relatif stabil. Perawatan dan penyiraman normal dapat dilanjutkan.',
    );
  }

  static String getSaran({
    required double suhu,
    required double kelembapanUdara,
    required double kelembapanTanah,
    required String jenisTanaman,
  }) {
    final profile = getProfile(jenisTanaman);
    final weather = inferCuaca(
      suhu: suhu,
      kelembapanUdara: kelembapanUdara,
      kelembapanTanah: kelembapanTanah,
    );
    final findings = <String>[];

    if (suhu < profile.minTemperature) {
      findings.add(
        'Suhu ${_number(suhu)} C masih dingin. Target ${_number(profile.minTemperature)}-${_number(profile.maxTemperature)} C; pindahkan ke area yang lebih hangat atau tambah paparan matahari pagi.',
      );
    } else if (suhu > profile.maxTemperature) {
      findings.add(
        'Suhu ${_number(suhu)} C terlalu panas. Target ${_number(profile.minTemperature)}-${_number(profile.maxTemperature)} C; beri paranet dan cek air pada media.',
      );
    } else {
      findings.add(
        'Suhu ${_number(suhu)} C sudah pas untuk ${profile.name}. Pertahankan kondisi ini, ya!',
      );
    }

    if (kelembapanTanah < profile.minSoilMoisture) {
      findings.add(
        'Tanah ${_number(kelembapanTanah)}% terlalu kering. ${profile.watering}',
      );
    } else if (kelembapanTanah > profile.maxSoilMoisture) {
      findings.add(
        'Tanah ${_number(kelembapanTanah)}% terlalu basah. Tunda penyiraman dan periksa drainase agar akar tidak membusuk.',
      );
    } else {
      findings.add(
        'Kelembapan tanah ${_number(kelembapanTanah)}% berada di zona ideal ${_number(profile.minSoilMoisture)}-${_number(profile.maxSoilMoisture)}%.',
      );
    }

    if (profile.suitableSeasons.contains(weather.inferredSeason)) {
      findings.add(
        '${weather.inferredSeason} yang terdeteksi cocok untuk ${profile.name}. Tetap sesuaikan penyiraman dengan pembacaan sensor.',
      );
    } else {
      findings.add(
        '${weather.inferredSeason} yang terdeteksi bukan kondisi utama ${profile.name}. Beri perlindungan tambahan dan tingkatkan pemeriksaan penyakit.',
      );
    }

    return 'Halo! Tunas sudah mempelajari kondisi $jenisTanaman kamu.\n\n'
        'Kondisi sekarang:\n- ${findings.join('\n- ')}\n\n'
        'Perkiraan cuaca Tunas:\n${weather.condition}. ${weather.description}\n\n'
        'Pupuk:\n${profile.fertilizer}\n\n'
        'Pencegahan:\n${profile.prevention}\n\n'
        'Semangat merawat kebunnya!';
  }

  static String _number(double value) {
    return value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toStringAsFixed(1);
  }
}
