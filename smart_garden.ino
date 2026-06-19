#include <ESP8266WiFi.h>
#include <ESP8266WebServer.h>
#include <DHT.h>


const char* ssid = "SmartGarden_WiFi";
const char* password = "admin12345";


#define DHTPIN 4       
#define DHTTYPE DHT22
DHT dht(DHTPIN, DHTTYPE);
#define SOIL_PIN A0    

ESP8266WebServer server(80);

void setup() {
  Serial.begin(115200);
  dht.begin();
  
  WiFi.softAP(ssid, password);
  Serial.println("\nWi-Fi AP Aktif: " + String(ssid));
  Serial.println("IP Address: 192.168.4.1");

  server.on("/data", handleData);
  server.begin();
}

void loop() {
  server.handleClient();
}

void handleData() {
  float h = dht.readHumidity();
  float t = dht.readTemperature();
  int soilRaw = analogRead(SOIL_PIN);
  
  
  
  int soilPercent = map(soilRaw, 1000, 400, 0, 100); 
  soilPercent = constrain(soilPercent, 0, 100);

  
  Serial.print("Raw: "); Serial.print(soilRaw);
  Serial.print(" | Tanah: "); Serial.println(soilPercent);

  
  String json = "{";
  json += "\"suhu\": " + String(t) + ", ";
  json += "\"kelembapan_udara\": " + String(h) + ", ";
  json += "\"kelembapan_tanah\": " + String(soilPercent);
  json += "}";

  server.sendHeader("Access-Control-Allow-Origin", "*");
  server.send(200, "application/json", json);
}