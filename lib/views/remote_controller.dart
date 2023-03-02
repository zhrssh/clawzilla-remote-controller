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

  // Sets the orientation to landscape
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ClawZilla connected...')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Container(
                width: 600,
                height: 100,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black54,
                    style: BorderStyle.solid,
                  ),
                ),
                child: StreamBuilder(
                  stream: _channel?.stream, // TODO: Change ? to !
                  builder: (context, snapshot) {
                    return Text(snapshot.hasData ? '${snapshot.data}' : '');
                  },
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                Column(children: [
                  GestureDetector(
                    child: IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.arrow_upward_rounded),
                    ),
                    onLongPressDown: (details) {
                      if (kDebugMode) {
                        print(details.globalPosition);
                      }
                    },
                    onLongPressEnd: (details) {
                      if (kDebugMode) {
                        print("Up button released.");
                      }
                    },
                    onLongPressCancel: () {
                      if (kDebugMode) {
                        print("Up button cancelled.");
                      }
                    },
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                  GestureDetector(
                    child: IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.arrow_downward_rounded),
                    ),
                    onLongPressDown: (details) {
                      if (kDebugMode) {
                        print(details.globalPosition);
                      }
                    },
                    onLongPressEnd: (details) {
                      if (kDebugMode) {
                        print("Down button released.");
                      }
                    },
                    onLongPressCancel: () {
                      if (kDebugMode) {
                        print("Down button cancelled.");
                      }
                    },
                  ),
                ]),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                ),
                GestureDetector(
                  child: IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                  onLongPressDown: (details) {
                    if (kDebugMode) {
                      print(details.globalPosition);
                    }
                  },
                  onLongPressEnd: (details) {
                    if (kDebugMode) {
                      print("Left button released.");
                    }
                  },
                  onLongPressCancel: () {
                    if (kDebugMode) {
                      print("Left button cancelled.");
                    }
                  },
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                ),
                GestureDetector(
                  child: IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.arrow_forward_rounded),
                  ),
                  onLongPressDown: (details) {
                    if (kDebugMode) {
                      print(details.globalPosition);
                    }
                  },
                  onLongPressEnd: (details) {
                    if (kDebugMode) {
                      print("Right button released.");
                    }
                  },
                  onLongPressCancel: () {
                    if (kDebugMode) {
                      print("Right button cancelled.");
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
