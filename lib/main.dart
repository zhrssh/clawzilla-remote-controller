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
  final _connectTextController = TextEditingController();

  // For connecting to websocket
  void _connect(BuildContext context) {
    String url = "ws://${_connectTextController.text}/ws";

    // Connect to websocket
    final channel = WebSocketChannel.connect(Uri.parse(url));

    _connectTextController.clear();
    channel.ready.then(
      (_) async {
        Navigator.of(context).pop();

        SystemChrome.setPreferredOrientations(
          [
            DeviceOrientation.landscapeLeft,
            DeviceOrientation.landscapeRight,
          ],
        );

        await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => RemoteController(channel: channel)));
      },
      onError: (onError) {
        Navigator.of(context).pop();
        const snackBar = SnackBar(
          content: Text("Error connecting to CLAWZILLA. Please try again."),
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
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              height: 50,
            ),
            const Expanded(
              child: Text(
                'Connect to CLAWZILLA',
                style: TextStyle(
                  fontFamily: "arial",
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(
              height: 80,
              width: 400,
              child: TextFormField(
                decoration: const InputDecoration(
                  label: Text("Gateway IP Address"),
                  hintText: "192.168.X.X",
                ),
                controller: _connectTextController,
              ),
            ),
            Expanded(
              child: ElevatedButton(
                style: const ButtonStyle(
                  alignment: Alignment.center,
                  padding: MaterialStatePropertyAll(
                    EdgeInsets.symmetric(
                      horizontal: 30,
                    ),
                  ),
                ),
                onPressed: () => _connect(context),
                child: const Text(
                  "Connect",
                  style: TextStyle(
                    fontFamily: "arial",
                    fontSize: 16,
                  ),
                ),
              ),
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
