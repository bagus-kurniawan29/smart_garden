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
    required this.harvestDays,
    required this.fertilizerIntervalDays,
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
  final int harvestDays;
  final int fertilizerIntervalDays;
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

class DailyMission {
  const DailyMission({
    required this.day,
    required this.phase,
    required this.title,
    required this.tasks,
    required this.fertilizerToday,
    required this.harvestReady,
  });

  final int day;
  final String phase;
  final String title;
  final List<String> tasks;
  final bool fertilizerToday;
  final bool harvestReady;
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
      harvestDays: 90,
      fertilizerIntervalDays: 10,
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
      harvestDays: 75,
      fertilizerIntervalDays: 10,
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
      harvestDays: 90,
      fertilizerIntervalDays: 14,
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
      harvestDays: 40,
      fertilizerIntervalDays: 7,
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
      harvestDays: 45,
      fertilizerIntervalDays: 10,
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

  static DailyMission getDailyMission({
    required String jenisTanaman,
    required int day,
    required double suhu,
    required double kelembapanUdara,
    required double kelembapanTanah,
  }) {
    final profile = getProfile(jenisTanaman);
    final safeDay = day < 1 ? 1 : day;
    final harvestReady = safeDay >= profile.harvestDays;
    final fertilizerToday =
        safeDay > 1 &&
        safeDay < profile.harvestDays &&
        safeDay % profile.fertilizerIntervalDays == 0;

    final phase = switch (safeDay) {
      1 => 'Mulai Menanam',
      <= 7 => 'Adaptasi Bibit',
      _ when safeDay < profile.harvestDays * 0.4 => 'Pertumbuhan Daun',
      _ when safeDay < profile.harvestDays * 0.75 => 'Bunga dan Buah',
      _ when !harvestReady => 'Pematangan',
      _ => 'Siap Panen',
    };

    final tasks = <String>[];
    if (safeDay == 1) {
      tasks.add(
        'Tanam bibit $jenisTanaman dan pastikan media memiliki drainase yang baik.',
      );
      tasks.add(
        'Belum perlu pupuk kimia hari ini; cukup kompos matang pada media.',
      );
    } else if (fertilizerToday) {
      tasks.add('Hari pemupukan: ${profile.fertilizer}');
    } else {
      final nextFertilizer =
          profile.fertilizerIntervalDays -
          (safeDay % profile.fertilizerIntervalDays);
      tasks.add(
        'Belum perlu pupuk hari ini. Jadwal berikutnya sekitar $nextFertilizer hari lagi.',
      );
    }

    if (kelembapanTanah < profile.minSoilMoisture) {
      tasks.add(
        'Tanah ${_number(kelembapanTanah)}% terlalu kering. ${profile.watering}',
      );
    } else if (kelembapanTanah > profile.maxSoilMoisture) {
      tasks.add(
        'Tanah terlalu basah. Tunda penyiraman dan cek lubang drainase.',
      );
    } else {
      tasks.add(
        'Kelembapan tanah ideal. Pertahankan di ${profile.minSoilMoisture.toInt()}-${profile.maxSoilMoisture.toInt()}%.',
      );
    }

    if (suhu < profile.minTemperature || suhu > profile.maxTemperature) {
      tasks.add(
        'Suhu ${_number(suhu)} C di luar target ${profile.minTemperature.toInt()}-${profile.maxTemperature.toInt()} C. Lindungi tanaman dari perubahan ekstrem.',
      );
    } else {
      tasks.add('Suhu ${_number(suhu)} C cocok untuk fase hari ini.');
    }

    if (kelembapanUdara >= 80) {
      tasks.add(
        'Udara sangat lembap; periksa jamur dan beri ruang sirkulasi udara.',
      );
    }

    if (harvestReady) {
      tasks
        ..clear()
        ..add(
          '$jenisTanaman sudah mencapai kisaran umur panen ${profile.harvestDays} hari.',
        )
        ..add(
          'Periksa ukuran, warna, dan kematangan hasil sebelum menekan Selesaikan Panen.',
        );
    }

    return DailyMission(
      day: safeDay,
      phase: phase,
      title: harvestReady ? 'Saatnya panen!' : 'Misi Hari $safeDay',
      tasks: tasks,
      fertilizerToday: fertilizerToday,
      harvestReady: harvestReady,
    );
  }

  static String getQuickAnswer({
    required String topic,
    required String jenisTanaman,
    required int? currentDay,
    required double suhu,
    required double kelembapanUdara,
    required double kelembapanTanah,
  }) {
    final profile = getProfile(jenisTanaman);
    final weather = inferCuaca(
      suhu: suhu,
      kelembapanUdara: kelembapanUdara,
      kelembapanTanah: kelembapanTanah,
    );
    final day = currentDay ?? 1;
    final mission = getDailyMission(
      jenisTanaman: jenisTanaman,
      day: day,
      suhu: suhu,
      kelembapanUdara: kelembapanUdara,
      kelembapanTanah: kelembapanTanah,
    );

    return switch (topic) {
      'Cuaca' => '${weather.condition}. ${weather.description}',
      'Siram' =>
        kelembapanTanah < profile.minSoilMoisture
            ? 'Tanah sedang kering. ${profile.watering}'
            : kelembapanTanah > profile.maxSoilMoisture
            ? 'Jangan siram dulu, tanah masih terlalu basah. Periksa drainase.'
            : 'Tanah berada di zona ideal. Cukup pantau agar tidak berubah drastis.',
      'Pupuk' =>
        currentDay == null
            ? 'Mulai perjalanan tanam dulu agar Tunas dapat menghitung jadwal pupuk.'
            : mission.fertilizerToday
            ? 'Hari ini jadwal pupuk! ${profile.fertilizer}'
            : mission.tasks.first,
      'Hama' => profile.prevention,
      'Panen' =>
        currentDay == null
            ? '$jenisTanaman biasanya siap sekitar ${profile.harvestDays} hari setelah dimulai.'
            : mission.harvestReady
            ? '$jenisTanaman sudah masuk waktu panen. Periksa kematangan lalu selesaikan perjalanan.'
            : 'Masih ${profile.harvestDays - currentDay} hari menuju kisaran panen. Kamu sedang di fase ${mission.phase}.',
      _ => 'Tunas siap membantu merawat $jenisTanaman kamu!',
    };
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
