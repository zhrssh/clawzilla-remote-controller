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
      home: const RemoteControllerV2(channel: null),
    ),
  );
}

class RemoteControllerV2 extends StatefulWidget {
  const RemoteControllerV2({super.key, required this.channel});
  final WebSocketChannel? channel;

  @override
  State<RemoteControllerV2> createState() => _RemoteControllerV2State();
}

class _RemoteControllerV2State extends State<RemoteControllerV2> {
  late final WebSocketChannel? _channel = widget.channel;

  // Car movement
  final JoystickMode _joystickMode = JoystickMode.all;
  double _x = 100;
  double _y = 100;

  // Car speed and car claw
  int _prevSpeedValue = 0;
  // ignore: prefer_final_fields
  double _speedValue = 0;

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
                children: <Widget>[
                  const SizedBox(
                    height: 24,
                  ),
                  const Text(
                    'Movement Controls',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      GameButton(
                        icon: Icons.arrow_upward,
                        onLongPressDown: () {
                          send("N");
                        },
                        onLongPressEnd: () {
                          send("STOP");
                        },
                      ),
                    ],
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        GameButton(
                          icon: Icons.arrow_back,
                          onLongPressDown: () {
                            send("W");
                          },
                          onLongPressEnd: () {
                            send("STOP");
                          },
                        ),
                        GameButton(
                          icon: Icons.arrow_downward,
                          onLongPressDown: () {
                            send("S");
                          },
                          onLongPressEnd: () {
                            send("STOP");
                          },
                        ),
                        GameButton(
                          icon: Icons.arrow_forward,
                          onLongPressDown: () {
                            send("E");
                          },
                          onLongPressEnd: () {
                            send("STOP");
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                ],
              ),
            ),
          ),
          // Expanded(
          //   child: Container(
          //     color: Colors.grey[300],
          //     child: Column(
          //       mainAxisAlignment: MainAxisAlignment.center,
          //       children: [
          //         SafeArea(
          //           child: Joystick(
          //             mode: _joystickMode,
          //             listener: (details) {
          //               double newX = details.x.roundToDouble();
          //               double newY = details.y.roundToDouble();

          //               if (newX == _x && newY == _y) {
          //                 return;
          //               }

          //               // Updates widget
          //               setState(() {
          //                 _x = newX;
          //                 _y = newY;
          //               });

          //               // Sends command
          //               // Move Forward
          //               if (_x == 0 && _y == -1) {
          //                 send("N");
          //               }

          //               // Move Forward & Right
          //               if (_x == 1 && _y == -1) {
          //                 send("NE");
          //               }

          //               // Move Right
          //               if (_x == 1 && _y == 0) {
          //                 send("E");
          //               }

          //               // Move Back & Right
          //               if (_x == 1 && _y == 1) {
          //                 send("SE");
          //               }

          //               // Move Back
          //               if (_x == 0 && _y == 1) {
          //                 send("S");
          //               }

          //               // Move Back & Left
          //               if (_x == -1 && _y == 1) {
          //                 send("SW");
          //               }

          //               // Move Left
          //               if (_x == -1 && _y == 0) {
          //                 send("W");
          //               }

          //               // Move Forward and Left
          //               if (_x == -1 && _y == -1) {
          //                 send("NW");
          //               }

          //               // Stop
          //               if (_x == 0 && _y == 0) {
          //                 send("STOP");
          //               }
          //             },
          //           ),
          //         ),
          //       ],
          //     ),
          //   ),
          // ),
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
                  final String string = snapshot.data;
                  final splitted = string.split("/");

                  if (splitted[0].compareTo("speed") == 0) {
                    final double val = double.parse(splitted[1]);
                    _speedValue = val;
                  }

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SfSlider.vertical(
                        min: 0,
                        max: 100,
                        value: _speedValue,
                        interval: 25,
                        stepSize: 10,
                        showLabels: true,
                        showDividers: true,
                        showTicks: true,
                        onChanged: (newValue) {
                          final int num = newValue.toInt();
                          if (num != _prevSpeedValue) {
                            // Sends to NodeMCU
                            send("speed/$num");
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
                  );
                }),
              ),
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.grey[300],
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: const ButtonStyle(
                      backgroundColor: MaterialStatePropertyAll(Colors.green),
                      shape: MaterialStatePropertyAll(CircleBorder()),
                      fixedSize: MaterialStatePropertyAll(
                        Size(120, 120),
                      ),
                    ),
                    onPressed: () => send("claw/0"),
                    child: const Text(
                      "Open",
                      style: TextStyle(fontSize: 24),
                    ),
                  ),
                  ElevatedButton(
                    style: const ButtonStyle(
                      backgroundColor: MaterialStatePropertyAll(Colors.red),
                      shape: MaterialStatePropertyAll(CircleBorder()),
                      fixedSize: MaterialStatePropertyAll(
                        Size(120, 120),
                      ),
                    ),
                    onPressed: () => send("claw/100"),
                    child: const Text("Grab", style: TextStyle(fontSize: 24)),
                  )
                ],
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
