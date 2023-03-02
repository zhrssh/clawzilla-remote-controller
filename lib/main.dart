import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

// Routes
import './views/remote_controller.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ClawZilla',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'ClawZilla Remote Controller'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // For connecting to websocket
  final _connController = TextEditingController();

  void _connect() {
    String url = _connController.text;

    // Clear text
    _connController.clear();

    // Connect to websocket (Debug)
    if (kDebugMode) {
      print(url);
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const RemoteController(channel: null)));
      return;
    }

    // Connect to websocket
    final channel = WebSocketChannel.connect(Uri.parse(url));
    channel.ready.then((_) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => RemoteController(channel: channel)));
    });
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
    _connController.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Text(
            'Connect to WebSocket',
            style: TextStyle(
              fontFamily: "arial bold",
              fontSize: 24,
            ),
          ),
          SizedBox(
            width: 600,
            child: TextFormField(
              controller: _connController,
              validator: (value) {
                if (value == null) {
                  return "Text Field can not be empty.";
                } else {
                  return "Connecting...";
                }
              },
              decoration: const InputDecoration(
                  labelText: "Type here the web socket link"),
              style: const TextStyle(
                fontFamily: "arial",
                fontSize: 18,
              ),
            ),
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: 4)),
          ElevatedButton(
            onPressed: _connect,
            child: const Text(
              "Connect",
              style: TextStyle(
                fontFamily: "arial",
                fontSize: 18,
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
