import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:network_info_plus/network_info_plus.dart';

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
      debugShowCheckedModeBanner: false,
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
  final _connectTextController = TextEditingController();

  // For connecting to websocket
  void _connect(BuildContext context, String? ip) {
    String url = "ws://$ip/ws";

    // Connect to websocket
    final channel = WebSocketChannel.connect(Uri.parse(url));

    // Show "connecting" dialog
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (_) {
          return Dialog(
            backgroundColor: Colors.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  CircularProgressIndicator(),
                  SizedBox(height: 15),
                  Text(
                    "Connecting",
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          );
        });

    _connectTextController.clear();
    channel.ready.then(
      (_) {
        Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => RemoteController(channel: channel)))
            .then((value) => Navigator.of(context).pop());
        return;
      },
      onError: (onError) {
        Navigator.of(context).pop();
        const snackBar = SnackBar(
          content: Text("Error connecting to websocket. Please try again."),
        );

        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        return;
      },
    );
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
    _connectTextController.dispose();
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
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const SizedBox(
              height: 50,
            ),
            const Text(
              'Connect to CLAWZILLA websocket',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: 80,
              width: 400,
              child: TextFormField(
                decoration: const InputDecoration(
                  label: Text("IP Address"),
                  hintText: "192.168.X.X",
                ),
                controller: _connectTextController,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: const ButtonStyle(
                    alignment: Alignment.center,
                    padding: MaterialStatePropertyAll(
                      EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 20,
                      ),
                    ),
                  ),
                  onPressed: () =>
                      _connect(context, _connectTextController.text),
                  child: const Text(
                    "Connect",
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                ),
                ElevatedButton(
                  style: const ButtonStyle(
                    alignment: Alignment.center,
                    padding: MaterialStatePropertyAll(
                      EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 20,
                      ),
                    ),
                  ),
                  onPressed: () async =>
                      _connect(context, await NetworkInfo().getWifiGatewayIP()),
                  child: const Text(
                    "Connect to Gateway",
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 50,
            ),
          ],
        ),
      ),
    );
  }
}
