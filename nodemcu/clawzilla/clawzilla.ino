#include <Arduino.h>
#include <ArduinoJson.h>

// For Wireless Connection
#include <ESP8266WiFi.h>
#include <ESPAsyncTCP.h>
#include <ESPAsyncWebServer.h>

// AP config
const char* ssid = "ClawZilla-AP";
const char* password = "cpe103grp4";

// ArduinoJson
StaticJsonDocument<200> doc;

// Pins

// Create server
AsyncWebServer server(80);
AsyncWebSocket ws("/ws");

// Variables
unsigned long previousMillis = 0;
const long interval = 10;
int x = 0;
int y = 0;
int speedValue = 0;
int clawValue = 0;

// Handles incoming messages from clients
void handleWebSocketMessage(void *arg, uint8_t *data, size_t len) {
  AwsFrameInfo *info = (AwsFrameInfo*)arg;
  if (info->final && info->index == 0 && info->len == len && info->opcode == WS_TEXT) {
    data[len] = 0;
    Serial.println((char*)data);

    // This is where data is handled;
    const DeserializationError error = deserializeJson(doc, (char*)data);

    // Test if parsing succeeds
    if (error) {
      Serial.print(F("deserializeJson failed: "));
      Serial.println(error.f_str());
      return;
    }

    // Set values
    if (!doc["move"].isNull()) {
      x = doc["move"]["x"];
      y = doc["move"]["y"];
    }

    if (!doc["speed"].isNull()) {
      speedValue = doc["speed"];
    }

    if (!doc["claw"].isNull()) {
      clawValue = doc["claw"];
    }

    // Print values
    Serial.print(x);
    Serial.print(" ");
    Serial.println(y);
    Serial.print("speed=");
    Serial.println(speedValue);
    Serial.print("claw=");
    Serial.println(clawValue);

    // Send value back to application
    String msg;
    serializeJson(doc, msg);
    ws.textAll(msg);
  }
}

// Checks if there are new events
void onEvent(AsyncWebSocket *server, AsyncWebSocketClient *client, AwsEventType type,
             void *arg, uint8_t *data, size_t len) {
  switch (type) {
    case WS_EVT_CONNECT:
      Serial.printf("WebSocket client #%u connected from %s\n", client->id(), client->remoteIP().toString().c_str());
      break;
    case WS_EVT_DISCONNECT:
      Serial.printf("WebSocket client #%u disconnected\n", client->id());
      break;
    case WS_EVT_DATA:
      handleWebSocketMessage(arg, data, len);
      break;
    case WS_EVT_PONG:
    case WS_EVT_ERROR:
      break;
  }
}

void initWebSocket() {
  ws.onEvent(onEvent);
  server.addHandler(&ws);
}

void setup() {
  // put your setup code here, to run once:
  Serial.begin(9600);
  Serial.println("Setting Access Point...");

  WiFi.softAP(ssid, password);

  IPAddress IP = WiFi.softAPIP();
  Serial.print("AP IP Address: ");
  Serial.println(IP);

  // Pins and initializations

  initWebSocket();

  server.on("/", HTTP_GET, [](AsyncWebServerRequest * request) {
    request->send(200, "text/plain", "OK");
  });

  server.begin();
}

void loop() {
  // Updates hardware states


  // Cleans clients to avoid overloading
  unsigned long t = millis();
  if (t - previousMillis > interval) {
    ws.cleanupClients();
    previousMillis = t;
  }
}
