import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';
import 'package:flutter_joystick/flutter_joystick.dart';

// Joystick config
const ballSize = 20.0;
const step = 10.0;

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "ClawZilla",
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const RemoteController(channel: null),
    ),
  );
}

class RemoteController extends StatefulWidget {
  const RemoteController({super.key, required this.channel});
  final WebSocketChannel? channel;

  @override
  State<RemoteController> createState() => _RemoteControllerState();
}

class _RemoteControllerState extends State<RemoteController> {
  late final WebSocketChannel? _channel = widget.channel;

  // Car movement
  final JoystickMode _joystickMode = JoystickMode.all;
  double _x = 100;
  double _y = 100;

  // Car speed and car claw
  int _prevSpeedValue = 0;
  // ignore: prefer_final_fields
  double _speedValue = 0;

  int _prevClawValue = 0;
  // ignore: prefer_final_fields
  double _clawValue = 0;

  // Send message to server
  void send(String? message) {
    _channel?.sink.add(message);
  }

  // Sets the orientation to landscape
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations(
      [
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ],
    );
  }

  @override
  void dispose() {
    _channel?.sink.close(null, "End connection");
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    _x = MediaQuery.of(context).size.width / 2 - ballSize / 2;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Controller connected.'),
      ),
      body: Row(
        children: <Widget>[
          Expanded(
            child: Container(
              color: Colors.grey[300],
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SafeArea(
                    child: Joystick(
                      mode: _joystickMode,
                      listener: (details) {
                        double newX = details.x.roundToDouble();
                        double newY = details.y.roundToDouble();

                        if (newX == _x && newY == _y) {
                          return;
                        }

                        // Updates widget
                        setState(() {
                          _x = newX;
                          _y = newY;
                        });

                        // Sends to NodeMCU
                        send(jsonEncode(
                          {
                            "move": {
                              "x": _x,
                              "y": _y,
                            }
                          },
                        ));
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.grey[300],
              child: StreamBuilder(
                initialData: "0",
                stream: _channel?.stream,
                builder: ((context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }

                  // Updates slider value from nodemcu response
                  final dynamic decoded = jsonDecode(snapshot.data);
                  if (decoded is Map<String, dynamic>) {
                    // Assigns values
                    if (decoded.containsKey("speed")) {
                      final int speedInt = decoded["speed"];
                      _speedValue = speedInt.toDouble();
                    }

                    if (decoded.containsKey("claw")) {
                      final int clawInt = decoded["claw"];
                      _clawValue = clawInt.toDouble();
                    }
                  }

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SfSlider.vertical(
                            min: 0,
                            max: 100,
                            value: _speedValue,
                            interval: 25,
                            showLabels: true,
                            showDividers: true,
                            showTicks: true,
                            onChanged: (newValue) {
                              final int num = newValue.toInt();
                              if (num != _prevSpeedValue) {
                                // Sends to NodeMCU
                                send(jsonEncode(
                                  {
                                    "speed": num,
                                  },
                                ));
                                _prevSpeedValue = num;
                              }
                            },
                          ),
                          const SizedBox(height: 10.0),
                          const Text(
                            'Speed',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SfSlider.vertical(
                            min: 0,
                            max: 100,
                            value: _clawValue,
                            interval: 25,
                            showLabels: true,
                            showDividers: true,
                            showTicks: true,
                            onChanged: (newValue) {
                              final int num = newValue.toInt();
                              if (num != _prevClawValue) {
                                send(jsonEncode(
                                  {
                                    "claw": num,
                                  },
                                ));
                                _prevClawValue = num;
                              }
                            },
                          ),
                          const SizedBox(height: 10.0),
                          const Text(
                            'Claw',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class GameButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onLongPressDown;
  final VoidCallback onLongPressEnd;

  const GameButton(
      {super.key,
      required this.icon,
      required this.onLongPressDown,
      required this.onLongPressEnd});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressDown: (_) => onLongPressDown.call(),
      onLongPressEnd: (_) => onLongPressEnd.call(),
      onLongPressCancel: onLongPressEnd,
      child: Container(
        width: 60.0,
        height: 60.0,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(
          icon,
          size: 30.0,
        ),
      ),
    );
  }
}
