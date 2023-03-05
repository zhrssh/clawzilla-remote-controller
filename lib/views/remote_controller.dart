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
                        },
                        onLongPressEnd: () {
                          send("stop");
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
                          },
                          onLongPressEnd: () {
                            send("stop");
                          },
                        ),
                        const SizedBox(
                          width: 100.0,
                        ),
                        GameButton(
                          icon: Icons.arrow_forward,
                          onLongPressDown: () {
                            send("right");
                          },
                          onLongPressEnd: () {
                            send("stop");
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
                        },
                        onLongPressEnd: () {
                          send("stop");
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
