# AI Agent Tunas - Smart Garden Monitoring

AI Agent Tunas adalah aplikasi monitoring tanaman berbasis Flutter dan ESP8266. Aplikasi ini membaca data suhu udara, kelembapan udara, dan kelembapan tanah dari sensor, lalu mengubah data tersebut menjadi saran perawatan tanaman yang mudah dipahami seperti asisten kebun digital.

Project ini dibuat untuk membantu pengguna merawat tanaman secara lebih terarah. Pengguna tidak hanya melihat angka sensor, tetapi juga mendapatkan rekomendasi harian, peringatan kondisi ekstrem, prediksi cuaca sederhana, jadwal pupuk, serta perjalanan tanam bergaya game sampai masa panen.

## Identitas Project

| Bagian | Keterangan |
| --- | --- |
| Nama aplikasi | AI Agent Tunas / Smart Garden |
| Platform aplikasi | Flutter |
| Mikrokontroler | ESP8266 |
| Sensor | DHT22 dan sensor kelembapan tanah analog |
| Komunikasi | Wi-Fi lokal ESP8266, endpoint HTTP JSON |
| Database lokal | SQLite melalui `sqflite`, fallback memori untuk platform tanpa SQLite |
| File aplikasi utama | `lib/main.dart` |
| File AI agent | `lib/ExpertSystem.dart`, `lib/TunasAgentWidget.dart` |
| File perjalanan tanaman | `lib/PlantJourneyWidget.dart` |
| File database | `lib/garden_database.dart` |
| File ESP | `smart_garden.ino` |

## Fitur Utama Aplikasi

1. Monitoring sensor secara real-time

   Aplikasi mengambil data dari ESP8266 setiap 3 detik melalui alamat:

   ```text
   http://192.168.4.1/data
   ```

   Data yang ditampilkan:

   - Suhu udara dalam derajat Celsius.
   - Kelembapan udara dalam persen.
   - Kelembapan tanah dalam persen.
   - Waktu update terakhir.

2. Dashboard status tanaman

   Dashboard menampilkan kartu sensor dengan status otomatis, misalnya:

   - Suhu: dingin, hangat, atau panas.
   - Kelembapan udara: kering, ideal, atau sangat lembap.
   - Kelembapan tanah: kering, cukup, atau basah.

3. AI Agent Tunas

   Tunas adalah sistem pakar sederhana berbasis aturan. Tunas membaca data sensor, jenis tanaman, fase hari tanam, dan kondisi kelembapan untuk menghasilkan saran perawatan.

   Contoh saran:

   - Tanah terlalu kering, maka tanaman perlu disiram.
   - Suhu terlalu panas, maka tanaman perlu perlindungan seperti paranet.
   - Kelembapan udara tinggi, maka pengguna diminta mengecek potensi jamur.
   - Jika hari tertentu masuk jadwal pupuk, Tunas memberi rekomendasi pupuk.

4. Pilihan jenis tanaman

   Pengguna dapat memilih tanaman yang ingin dirawat. Saat ini tanaman yang didukung:

   - Cabai
   - Tomat
   - Terong
   - Sawi
   - Timun

   Setiap tanaman memiliki target berbeda, seperti suhu ideal, kelembapan tanah ideal, musim cocok, jadwal pupuk, dan estimasi hari panen.

5. Perjalanan tanaman seperti game

   Fitur ini membuat proses menanam terasa seperti permainan. Pengguna memilih tanaman, lalu menekan tombol mulai. Setelah itu aplikasi membuat siklus tanam dari Hari 1 sampai hari panen.

   Elemen game yang tersedia:

   - Tombol `Mulai Menanam`.
   - Tampilan hari berjalan seperti timeline.
   - Misi harian.
   - Progress menuju panen.
   - Tombol `Selesaikan Panen` saat tanaman sudah mencapai kisaran umur panen.
   - Dialog kemenangan saat perjalanan selesai.

6. Misi harian tanaman

   Setiap hari Tunas membuat misi sesuai umur tanaman dan kondisi sensor.

   Contoh:

   - Hari 1: tanam bibit dan pastikan drainase baik.
   - Hari pupuk: berikan pupuk sesuai profil tanaman.
   - Tanah kering: lakukan penyiraman.
   - Suhu ekstrem: lindungi tanaman.
   - Hari panen: cek ukuran, warna, dan kematangan hasil.

7. Tanya cepat ke Tunas

   Pengguna bisa menekan topik cepat:

   - Cuaca
   - Siram
   - Pupuk
   - Hama
   - Panen

   Tunas langsung menjawab berdasarkan kondisi sensor dan tanaman yang sedang dipilih.

8. Prediksi cuaca offline

   Aplikasi membuat prediksi sederhana tanpa internet dari rata-rata data sensor terakhir.

   Kondisi yang bisa dideteksi:

   - Berpotensi hujan
   - Panas dan kering
   - Berawan dan lembap
   - Cerah stabil

9. Peringatan otomatis

   Aplikasi menampilkan notifikasi jika ada kondisi penting:

   - Suhu terlalu panas.
   - Tanah mulai kering.
   - Kelembapan udara tinggi.
   - Jadwal pupuk sudah masuk.

10. Riwayat dan grafik sensor

    Data pembacaan sensor disimpan sementara dalam daftar history. Aplikasi menampilkan tren sensor terakhir agar pengguna dapat melihat perubahan kondisi kebun.

11. Penyimpanan data lokal

    Aplikasi menyimpan:

    - Riwayat pemupukan.
    - Siklus tanam aktif.
    - Status tanaman yang sedang berjalan.

    Penyimpanan menggunakan SQLite pada perangkat yang mendukung. Jika SQLite tidak tersedia, aplikasi memakai penyimpanan memori sementara.

## Cara Kerja Sistem

Alur kerja keseluruhan:

```text
Sensor DHT22 + sensor tanah
        |
        v
ESP8266 membaca suhu, kelembapan udara, dan kelembapan tanah
        |
        v
ESP8266 membuat Wi-Fi lokal SmartGarden_WiFi
        |
        v
Aplikasi Flutter terhubung ke Wi-Fi ESP8266
        |
        v
Aplikasi meminta data ke http://192.168.4.1/data
        |
        v
Data JSON masuk ke dashboard
        |
        v
AI Agent Tunas menganalisis data sensor dan jenis tanaman
        |
        v
Aplikasi menampilkan status, saran, misi harian, peringatan, dan progress panen
```

## Cara Kerja AI Agent Tunas

AI Agent Tunas berada di file:

```text
lib/ExpertSystem.dart
lib/TunasAgentWidget.dart
```

Tunas bekerja dengan konsep sistem pakar. Artinya, aplikasi memiliki kumpulan aturan dan pengetahuan tanaman, lalu mencocokkannya dengan data sensor.

### 1. Basis pengetahuan tanaman

Setiap tanaman memiliki profil:

| Data profil | Fungsi |
| --- | --- |
| `minTemperature` | Suhu minimum ideal tanaman |
| `maxTemperature` | Suhu maksimum ideal tanaman |
| `minSoilMoisture` | Kelembapan tanah minimum |
| `maxSoilMoisture` | Kelembapan tanah maksimum |
| `suitableSeasons` | Musim yang cocok |
| `fertilizer` | Rekomendasi pupuk |
| `watering` | Rekomendasi penyiraman |
| `prevention` | Pencegahan hama/penyakit |
| `harvestDays` | Estimasi hari panen |
| `fertilizerIntervalDays` | Interval hari pemupukan |

Contoh untuk Cabai:

- Suhu ideal: 24 sampai 30 C.
- Kelembapan tanah ideal: 55 sampai 75%.
- Estimasi panen: 90 hari.
- Interval pupuk: 10 hari.

### 2. Analisis cuaca

Fungsi `inferCuaca()` membaca suhu, kelembapan udara, dan kelembapan tanah.

Aturan contoh:

- Jika kelembapan udara tinggi dan tanah basah, Tunas memperkirakan kondisi berpotensi hujan.
- Jika suhu tinggi dan udara kering, Tunas memperkirakan kondisi panas dan kering.
- Jika kelembapan udara cukup tinggi, Tunas memperkirakan kondisi berawan dan lembap.
- Jika tidak ada kondisi ekstrem, Tunas menganggap cuaca cerah stabil.

### 3. Misi harian

Fungsi `getDailyMission()` menentukan tugas harian tanaman.

Faktor yang dihitung:

- Jenis tanaman.
- Hari tanam saat ini.
- Suhu udara.
- Kelembapan udara.
- Kelembapan tanah.
- Apakah hari ini jadwal pupuk.
- Apakah sudah masuk masa panen.

Fase tanaman:

- Hari 1: Mulai Menanam.
- Hari 2 sampai 7: Adaptasi Bibit.
- Fase awal: Pertumbuhan Daun.
- Fase tengah: Bunga dan Buah.
- Fase akhir: Pematangan.
- Setelah mencapai `harvestDays`: Siap Panen.

### 4. Jawaban chat cepat

Fungsi `getQuickAnswer()` menjawab pertanyaan cepat dari tombol:

- `Cuaca`: menjelaskan prediksi cuaca dari sensor.
- `Siram`: memberi keputusan perlu siram atau tidak.
- `Pupuk`: memberi jadwal pupuk.
- `Hama`: memberi pencegahan hama.
- `Panen`: memberi estimasi waktu panen.

### 5. Saran utama

Fungsi `getSaran()` membuat ringkasan lengkap:

- Kondisi suhu saat ini.
- Kondisi kelembapan tanah.
- Kesesuaian musim.
- Perkiraan cuaca.
- Rekomendasi pupuk.
- Pencegahan hama.

## Penjelasan File Flutter

### `lib/main.dart`

File utama aplikasi. Fungsinya:

- Menjalankan aplikasi dengan `runApp()`.
- Membuat tema tampilan.
- Menampilkan dashboard.
- Mengambil data dari ESP8266.
- Menyimpan history sensor.
- Mengatur tanaman yang dipilih.
- Mengatur siklus tanam.
- Menampilkan alert otomatis.
- Menghubungkan dashboard dengan Tunas AI Agent.

Bagian penting:

```dart
Timer.periodic(
  const Duration(seconds: 3),
  (Timer t) => fetchData(),
);
```

Kode ini membuat aplikasi mengambil data sensor setiap 3 detik.

```dart
final response = await http
    .get(Uri.parse('http://192.168.4.1/data'))
    .timeout(const Duration(seconds: 2));
```

Kode ini meminta data sensor dari ESP8266 melalui HTTP.

```dart
history.insert(
  0,
  SensorRecord(nextSuhu, nextUdara, nextTanah, lastUpdate),
);
```

Kode ini menyimpan pembacaan sensor terbaru ke daftar riwayat.

### `lib/ExpertSystem.dart`

File ini adalah otak AI Agent Tunas. Isinya:

- Data profil tanaman.
- Aturan prediksi cuaca.
- Aturan misi harian.
- Aturan saran penyiraman.
- Aturan jadwal pupuk.
- Aturan panen.
- Jawaban cepat chatbot.

### `lib/TunasAgentWidget.dart`

File ini adalah tampilan AI Agent Tunas. Fungsinya:

- Menampilkan nama agent.
- Menampilkan tanaman aktif dan kondisi cuaca.
- Menampilkan tombol tanya cepat.
- Menampilkan jawaban Tunas.
- Menampilkan saran utama.
- Menyediakan tombol pilih tanaman.

### `lib/PlantJourneyWidget.dart`

File ini membuat fitur game perjalanan tanaman. Fungsinya:

- Menampilkan pilihan tanaman sebelum mulai.
- Menampilkan timeline hari.
- Menampilkan progress menuju panen.
- Menampilkan misi harian.
- Mengunci panen sampai hari panen tercapai.
- Menampilkan tombol selesai panen.

### `lib/garden_database.dart`

File ini menangani penyimpanan lokal. Fungsinya:

- Menyimpan tanggal pemupukan.
- Menyimpan siklus tanam aktif.
- Mengambil siklus tanam yang belum selesai.
- Menandai siklus tanam sebagai selesai.
- Memberi fallback memori jika SQLite tidak tersedia.

Tabel database:

```text
fertilization_log
- id
- plant_type
- fertilized_at

crop_cycle
- id
- plant_type
- started_at
- completed_at
```

## Penjelasan Kode ESP8266

File ESP berada di:

```text
smart_garden.ino
```

Kode ini bertugas membaca sensor dan menyediakan data dalam bentuk JSON agar bisa dibaca aplikasi Flutter.

### Library yang digunakan

```cpp
#include <ESP8266WiFi.h>
#include <ESP8266WebServer.h>
#include <DHT.h>
```

Fungsinya:

- `ESP8266WiFi.h`: mengatur Wi-Fi pada ESP8266.
- `ESP8266WebServer.h`: membuat server HTTP lokal.
- `DHT.h`: membaca sensor DHT22.

### Konfigurasi Wi-Fi

```cpp
const char* ssid = "SmartGarden_WiFi";
const char* password = "admin12345";
```

ESP8266 membuat jaringan Wi-Fi sendiri bernama `SmartGarden_WiFi`. Pengguna menghubungkan HP/laptop ke Wi-Fi ini agar aplikasi bisa mengambil data dari ESP.

### Konfigurasi sensor

```cpp
#define DHTPIN 4
#define DHTTYPE DHT22
DHT dht(DHTPIN, DHTTYPE);
#define SOIL_PIN A0
```

Penjelasan:

- `DHTPIN 4`: pin data DHT22 terhubung ke GPIO4. Pada NodeMCU biasanya setara dengan pin D2.
- `DHTTYPE DHT22`: jenis sensor suhu dan kelembapan udara yang dipakai adalah DHT22.
- `SOIL_PIN A0`: sensor kelembapan tanah masuk ke pin analog A0.

### Membuat web server

```cpp
ESP8266WebServer server(80);
```

ESP8266 membuka server pada port 80. Karena port 80 adalah port HTTP standar, aplikasi cukup mengakses:

```text
http://192.168.4.1/data
```

### Fungsi `setup()`

```cpp
void setup() {
  Serial.begin(115200);
  dht.begin();
  
  WiFi.softAP(ssid, password);
  Serial.println("\nWi-Fi AP Aktif: " + String(ssid));
  Serial.println("IP Address: 192.168.4.1");

  server.on("/data", handleData);
  server.begin();
}
```

Fungsi ini berjalan sekali saat ESP dinyalakan.

Cara kerjanya:

1. `Serial.begin(115200)` mengaktifkan Serial Monitor untuk debugging.
2. `dht.begin()` memulai sensor DHT22.
3. `WiFi.softAP(ssid, password)` membuat ESP8266 menjadi access point Wi-Fi.
4. `server.on("/data", handleData)` membuat endpoint `/data`.
5. `server.begin()` menjalankan server.

### Fungsi `loop()`

```cpp
void loop() {
  server.handleClient();
}
```

Fungsi ini berjalan terus menerus. Tugasnya mengecek apakah ada request masuk dari aplikasi. Jika aplikasi membuka `/data`, ESP menjalankan fungsi `handleData()`.

### Fungsi `handleData()`

```cpp
void handleData() {
  float h = dht.readHumidity();
  float t = dht.readTemperature();
  int soilRaw = analogRead(SOIL_PIN);
```

Bagian ini membaca:

- `h`: kelembapan udara dari DHT22.
- `t`: suhu udara dari DHT22.
- `soilRaw`: nilai mentah sensor tanah dari A0.

```cpp
int soilPercent = map(soilRaw, 1000, 400, 0, 100);
soilPercent = constrain(soilPercent, 0, 100);
```

Bagian ini mengubah nilai analog menjadi persen.

Logikanya:

- Nilai sekitar 1000 dianggap kering atau 0%.
- Nilai sekitar 400 dianggap basah atau 100%.
- `constrain()` memastikan hasil tetap antara 0 sampai 100.

```cpp
Serial.print("Raw: "); Serial.print(soilRaw);
Serial.print(" | Tanah: "); Serial.println(soilPercent);
```

Bagian ini menampilkan nilai sensor tanah di Serial Monitor untuk pengecekan.

```cpp
String json = "{";
json += "\"suhu\": " + String(t) + ", ";
json += "\"kelembapan_udara\": " + String(h) + ", ";
json += "\"kelembapan_tanah\": " + String(soilPercent);
json += "}";
```

Bagian ini membuat data JSON yang akan dikirim ke aplikasi.

Contoh hasil:

```json
{
  "suhu": 30.5,
  "kelembapan_udara": 72.0,
  "kelembapan_tanah": 64
}
```

```cpp
server.sendHeader("Access-Control-Allow-Origin", "*");
server.send(200, "application/json", json);
```

Bagian ini mengirim response ke aplikasi:

- Status `200` berarti request berhasil.
- Tipe data `application/json` berarti data berupa JSON.
- Header CORS membuat data bisa diakses dari aplikasi/web.

## Alat dan Bahan

| Komponen | Fungsi |
| --- | --- |
| ESP8266 / NodeMCU | Mikrokontroler dan Wi-Fi server |
| DHT22 | Sensor suhu dan kelembapan udara |
| Sensor kelembapan tanah analog | Membaca kadar air tanah |
| Kabel jumper | Menghubungkan sensor |
| Breadboard | Media rangkaian sementara |
| HP/laptop | Menjalankan aplikasi Flutter |
| Tanaman | Objek monitoring |

## Rangkaian Pin

| Komponen | Pin ESP8266 |
| --- | --- |
| DHT22 VCC | 3V3 |
| DHT22 GND | GND |
| DHT22 DATA | GPIO4 / D2 |
| Sensor tanah VCC | 3V3 |
| Sensor tanah GND | GND |
| Sensor tanah AO | A0 |

Catatan: jika modul sensor tanah memiliki kebutuhan tegangan berbeda, sesuaikan dengan modul yang digunakan. Pin A0 ESP8266 memiliki batas tegangan analog, jadi pastikan output sensor aman untuk board yang dipakai.

## Cara Menjalankan Project

### 1. Upload kode ESP8266

1. Buka `smart_garden.ino` di Arduino IDE.
2. Pilih board ESP8266/NodeMCU.
3. Install library:
   - ESP8266 board package.
   - DHT sensor library.
4. Upload kode ke ESP8266.
5. Buka Serial Monitor pada baudrate `115200`.
6. Pastikan muncul Wi-Fi:

   ```text
   SmartGarden_WiFi
   ```

### 2. Hubungkan perangkat ke Wi-Fi ESP

Hubungkan HP/laptop ke:

```text
SSID: SmartGarden_WiFi
Password: admin12345
```

### 3. Jalankan aplikasi Flutter

Di folder project:

```bash
flutter pub get
flutter run
```

Setelah aplikasi terbuka, data sensor akan diambil otomatis dari ESP8266.

## Cara Demo Presentasi

Urutan demo yang disarankan:

1. Tunjukkan rangkaian sensor dan ESP8266.
2. Jelaskan bahwa ESP membuat Wi-Fi sendiri.
3. Hubungkan perangkat ke `SmartGarden_WiFi`.
4. Buka aplikasi Smart Garden.
5. Tunjukkan tiga data sensor utama.
6. Pilih tanaman, misalnya Cabai.
7. Tekan `Mulai Menanam Cabai`.
8. Tunjukkan timeline Hari 1 dan misi harian.
9. Tekan tombol tanya cepat seperti `Cuaca`, `Siram`, `Pupuk`, `Hama`, dan `Panen`.
10. Jelaskan bahwa Tunas memakai aturan dari profil tanaman dan data sensor.
11. Tunjukkan grafik/history sensor.
12. Jelaskan bahwa saat hari panen tercapai, tombol `Selesaikan Panen` aktif.

## Keunggulan Project

- Dapat berjalan secara lokal tanpa internet karena ESP8266 membuat Wi-Fi sendiri.
- Data sensor ditampilkan real-time.
- Tidak hanya monitoring angka, tetapi juga memberi saran perawatan.
- Memiliki AI agent berbasis sistem pakar yang mudah dijelaskan saat presentasi.
- Ada fitur game perjalanan tanaman agar pengguna lebih tertarik merawat tanaman.
- Mendukung beberapa jenis tanaman dengan aturan berbeda.
- Memiliki database lokal untuk menyimpan siklus tanam dan riwayat pupuk.

## Kesimpulan

AI Agent Tunas adalah sistem smart garden yang menggabungkan Internet of Things dan sistem pakar. ESP8266 bertugas mengambil data lingkungan tanaman, sedangkan aplikasi Flutter menampilkan data, menganalisis kondisi, dan memberi rekomendasi perawatan. Dengan fitur perjalanan tanaman seperti game, pengguna dapat mengikuti perkembangan tanaman dari Hari 1 sampai panen dengan panduan harian yang lebih interaktif.
