#include <Arduino.h>

// For Servo
# include <Servo.h>

// For Wireless Connection
#include <ESP8266WiFi.h>
#include <ESPAsyncTCP.h>
#include <ESPAsyncWebServer.h>

// AP config
const char* ssid = "ClawZilla-AP";
const char* password = "cpe103grp4";

// Pins
// Motor 1
const int en1 = D1;
const int in1 = D2;
const int in2 = D3;

// Motor 2
const int en2 = D4;
const int in3 = D5;
const int in4 = D6;

// Claw Servo
Servo myServo;
const int servoPin = D0;

// Create server
AsyncWebServer server(80);
AsyncWebSocket ws("/ws");

// Variables -- TO BE ADJUSTED
unsigned long previousMillis = 0;
const long interval = 10;
char* mv = "";
int speedValue = 0;
int clawValue = 0;
const int angleMin = 120;
const int angleMax = 0;

// Handles incoming messages from clients
void handleWebSocketMessage(void *arg, uint8_t *data, size_t len) {
  AwsFrameInfo *info = (AwsFrameInfo*)arg;
  if (info->final && info->index == 0 && info->len == len && info->opcode == WS_TEXT) {
    data[len] = 0;
    Serial.print("Message: ");
    Serial.println((char*)data);

    // This is where data is handled
    /**** Movements ****/
    if (strcmp((char*)data, "N") == 0) {
//      Serial.println("Moving N");
      mv = "N";
    }

    if (strcmp((char*)data, "NE") == 0) {
//      Serial.println("Moving NE");
      mv = "NE";
    }

    if (strcmp((char*)data, "E") == 0) {
//      Serial.println("Moving E");
      mv = "E";
    }

    if (strcmp((char*)data, "SE") == 0) {
//      Serial.println("Moving SE");
      mv = "SE";
    }

    if (strcmp((char*)data, "S") == 0) {
//      Serial.println("Moving S");
      mv = "S";
    }

    if (strcmp((char*)data, "SW") == 0) {
//      Serial.println("Moving SW");
      mv = "SW";
    }

    if (strcmp((char*)data, "W") == 0) {
//      Serial.println("Moving W");
      mv = "W";
    }

    if (strcmp((char*)data, "NW") == 0) {
//      Serial.println("Moving NW");
      mv = "NW";
    }

    if (strcmp((char*)data, "STOP") == 0) {
//      Serial.println("STOP");
      mv = "STOP";
    }

    String str = String((char*)data);
    int index = str.indexOf("/");
    int len = str.length();

    // Gets the command
    String subStr = str.substring(0, index);
    String valueStr = str.substring(index + 1, len);

    if (subStr.compareTo("speed") == 0) {
      speedValue = valueStr.toInt();
//      Serial.print("Speed: ");
//      Serial.println(speedValue);
      ws.textAll((char*)data);
    }

    if (subStr.compareTo("claw") == 0) {
      clawValue = valueStr.toInt();
//      Serial.print("Claw: ");
//      Serial.println(clawValue);
    }

//    ws.textAll((char*)data);
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

// Inputs: speed1 and speed2, a, b, c, d
void robotMove(int s1, int s2, int a, int b, int c, int d) {
  // Enables the motors
  analogWrite(en1, s1);
  analogWrite(en2, s2);

  // Controls the direction
  digitalWrite(in1, a);
  digitalWrite(in2, b);
  digitalWrite(in3, c);
  digitalWrite(in4, d);
}

void updateHardware() {
  // Movement
  int spd = map(speedValue, 0, 100, 0, 255);
  Serial.print("Speed: ");
  Serial.println(spd);
  /**** Movements ****/
  if (strcmp(mv, "N") == 0) {
    robotMove(spd, spd, 1, 0, 0, 1);
  }

  if (strcmp(mv, "NE") == 0) {
    robotMove(spd/2, spd, 0, 1, 0, 1);
  }

  if (strcmp(mv, "E") == 0) {
    robotMove(spd, spd, 0, 1, 0, 1);
  }

  if (strcmp(mv, "S") == 0) {
    robotMove(spd, spd, 0, 1, 1, 0);
  }

  if (strcmp(mv, "W") == 0) {
    robotMove(spd, spd, 1, 0, 1, 0);
  }

  if (strcmp(mv, "NW") == 0) {
    robotMove(spd, spd/2 , 1, 0, 1, 0);
  }

  if (strcmp(mv, "STOP") == 0) {
    robotMove(0, 0, 0, 0, 0, 0);
  }

  // Claw
  int val = map(clawValue, 0, 100, angleMin, angleMax);
//  Serial.println(val);
  myServo.write(val);
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
  myServo.attach(servoPin);
  myServo.write(0);
  pinMode(in1, OUTPUT);
  pinMode(in2, OUTPUT);
  pinMode(in3, OUTPUT);
  pinMode(in4, OUTPUT);

  initWebSocket();

  server.on("/", HTTP_GET, [](AsyncWebServerRequest * request) {
    request->send(200, "text/plain", "OK");
  });

  server.begin();
}

void loop() {
  // Updates hardware states
  updateHardware();

  // Cleans clients to avoid overloading
  unsigned long t = millis();
  if (t - previousMillis > interval) {
    ws.cleanupClients();
    previousMillis = t;
  }
}
