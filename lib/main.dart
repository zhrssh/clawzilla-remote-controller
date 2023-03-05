import 'package:flutter/foundation.dart';
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
  void _connect(BuildContext context) {
    NetworkInfo().getWifiGatewayIP().then((value) {
      String url = "ws://$value/ws";

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
                        fontFamily: "arial",
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            );
          });

      // Connect to websocket (Debug)
      if (kDebugMode) {
        print(url);
        Future.delayed(const Duration(seconds: 3)).then((value) {
          Navigator.of(context).pop();
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const RemoteController(channel: null)));
        });
        return;
      }

      // Connect to websocket
      final channel = WebSocketChannel.connect(Uri.parse(url));

      channel.ready.then((_) {
        Navigator.of(context).pop();
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => RemoteController(channel: channel)));
      }).catchError((onError) {
        Navigator.of(context).pop();
        const snackBar = SnackBar(
          content: Text("Error connecting to CLAWZILLA. Please try again."),
        );

        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        return;
      });
    });
  }

  // Sets the orientation to landscape
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations(
      [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight],
    );
  }

  @override
  void dispose() {
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Connect to CLAWZILLA.',
              style: TextStyle(
                fontFamily: "arial",
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Padding(padding: EdgeInsets.symmetric(vertical: 4)),
            ElevatedButton(
              style: const ButtonStyle(
                alignment: Alignment.center,
                padding: MaterialStatePropertyAll(
                  EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 30,
                  ),
                ),
              ),
              onPressed: () => _connect(context),
              child: const Text(
                "Connect",
                style: TextStyle(
                  fontFamily: "arial",
                  fontSize: 24,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
