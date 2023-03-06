#include <Arduino.h>

// For Wireless Connection
#include <ESP8266WiFi.h>
#include <ESPAsyncTCP.h>
#include <ESPAsyncWebServer.h>

const char* ssid = "ClawZilla-AP";
const char* password = "cpe103grp4";

// Pins
const int ledPins[4] = { D0, D1, D2, D3 };
const int clawPinLed = D4;

// Create server
AsyncWebServer server(80);
AsyncWebSocket ws("/ws");

unsigned long previousMillis = 0;
const long interval = 10;

// Handles incoming messages from clients
void handleWebSocketMessage(void *arg, uint8_t *data, size_t len) {
  AwsFrameInfo *info = (AwsFrameInfo*)arg;
  if (info->final && info->index == 0 && info->len == len && info->opcode == WS_TEXT) {
    data[len] = 0;
    Serial.println((char*)data);
    
    // This is where data is handled;
    // Searches for '/'
    char * s_ptr = strchr((char*)data, '/');
    if (s_ptr != NULL) {
      // Handle claw motion
      int arr[3] = {};
      for (int i = 1; i < 4; i++) {

        // Checks if the next address is null
        if (*(s_ptr + i) == 0) {
          arr[i - 1] = '\0' + '0';
          break;
        }

        arr[i - 1] = *(s_ptr + i) - '0';
      }

      // Converts int array to one integer number
      int num = 0;
      for (int i : arr) {
        // break on termination
        if (i == 48) break;
        num = num * 10 + i;
      }

      // Notify all clients
      ws.textAll(String(num));

      // Value to pass on the motor
      analogWrite(clawPinLed, map(num, 0, 100, 0, 255));
    }

    if (strcmp((char*)data, "forward") == 0) {
      // Move forward
      digitalWrite(ledPins[0], HIGH);
    }

    if (strcmp((char*)data, "backward") == 0) {
      // Move backward
      digitalWrite(ledPins[1], HIGH);
    }

    if (strcmp((char*)data, "left") == 0) {
      // Move left
      digitalWrite(ledPins[2], HIGH);
      return;
    }

    if (strcmp((char*)data, "right") == 0) {
      // Move right
      digitalWrite(ledPins[3], HIGH);
    }

    if (strcmp((char*)data, "stop") == 0) {
      // Stop
      digitalWrite(ledPins[0], LOW);
      digitalWrite(ledPins[1], LOW);
      digitalWrite(ledPins[2], LOW);
      digitalWrite(ledPins[3], LOW);
    }
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
  pinMode(clawPinLed, OUTPUT);
  digitalWrite(clawPinLed, LOW);
  for (int i : ledPins) {
    pinMode(i, OUTPUT);
    digitalWrite(i, LOW);
  }

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
