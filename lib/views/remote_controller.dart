import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class RemoteController extends StatefulWidget {
  const RemoteController({super.key, required this.channel});
  final WebSocketChannel? channel;

  @override
  State<RemoteController> createState() => _RemoteControllerState();
}

class _RemoteControllerState extends State<RemoteController> {
  late final WebSocketChannel? _channel = widget.channel;
  double _sliderValue = 50;

  // Send message to server
  void send(String? message) {
    if (kDebugMode) {
      print("Sending '$message'");
      return;
    }

    _channel?.sink.add(message);
  }

  // Sets the orientation to landscape
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
  }

  @override
  void dispose() {
    if (kDebugMode) {
      print("Ending websocket connection...");
    }
    _channel?.sink.close(null, "End connection");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                mainAxisSize: MainAxisSize.min,
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
                          send("forward");
                          if (kDebugMode) {
                            print("Moving forward.");
                          }
                        },
                        onLongPressEnd: () {
                          send("stop");
                          if (kDebugMode) {
                            print("Stop.");
                          }
                        },
                      ),
                    ],
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        GameButton(
                          icon: Icons.arrow_back,
                          onLongPressDown: () {
                            send("left");
                            if (kDebugMode) {
                              print("Moving left.");
                            }
                          },
                          onLongPressEnd: () {
                            send("stop");
                            if (kDebugMode) {
                              print("Stop.");
                            }
                          },
                        ),
                        const SizedBox(
                          width: 100.0,
                        ),
                        GameButton(
                          icon: Icons.arrow_forward,
                          onLongPressDown: () {
                            send("right");
                            if (kDebugMode) {
                              print("Moving right.");
                            }
                          },
                          onLongPressEnd: () {
                            send("stop");
                            if (kDebugMode) {
                              print("Stop.");
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      GameButton(
                        icon: Icons.arrow_downward,
                        onLongPressDown: () {
                          send("backward");
                          if (kDebugMode) {
                            print("Moving backward.");
                          }
                        },
                        onLongPressEnd: () {
                          send("stop");
                          if (kDebugMode) {
                            print("Stop.");
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.grey[300],
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Text(
                      'Claw Control',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    Slider(
                      min: 0,
                      max: 100,
                      value: _sliderValue,
                      onChanged: (newValue) {
                        setState(() {
                          _sliderValue = newValue;

                          send("claw/${_sliderValue.toInt()}");
                          if (kDebugMode) {
                            print(_sliderValue.toInt());
                          }
                        });
                      },
                    ),
                  ],
                ),
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
