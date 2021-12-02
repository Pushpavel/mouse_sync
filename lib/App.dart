import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

const SERVER_PORT = 15555;
const DISCOVERY_PORT = 5001;

class App extends HookWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final server = useState<Socket?>(null);

    useEffect(() {
      if (server.value != null) return;
      // Discovering the server by listening to the discovery port in every network interfaces
      RawDatagramSocket.bind(InternetAddress.anyIPv4, DISCOVERY_PORT).then((udpSocket) {
        print("discovering server...");
        udpSocket.readEventsEnabled = true;
        udpSocket.writeEventsEnabled = true;
        udpSocket.broadcastEnabled = true;

        udpSocket.listen((event) async {
          if (event != RawSocketEvent.read || server.value != null) return;
          print("server found, connecting...");
          final datagram = udpSocket.receive()!;
          // use the host address where the udp broadcast was sent to connect to the server
          server.value = await Socket.connect(datagram.address.address, SERVER_PORT);
          print("connected to server");
          udpSocket.close();

          try {
            await server.value!.done;
          } finally {
            print("disconnected from server");
            server.value = null;
          }
        });
      });
    }, [server.value]);

    return ValueListenableBuilder(
      valueListenable: server,
      builder: (context, socket, child) {
        // Server is not yet found, display a loading screen
        if (socket == null)
          return centeredScreen(Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("Discovering Server..."),
              SizedBox(height: 16),
              CircularProgressIndicator(),
            ],
          ));

        // Server is connected so we can start the event dispatch
        return GestureDetector(
          onTap: () {
            print("tap");
            dispatchMouseEvent("click", server);
          },
          onSecondaryTap: () {
            print("secondary tap");
            dispatchMouseEvent("rightClick", server);
          },
          onPanUpdate: (DragUpdateDetails details) {
            print("drag update");
            dispatchMouseEvent("move;${details.delta.dx},${details.delta.dy}", server);
          },
          child: centeredScreen(Text("Have Fun 😀")),
        );
      },
    );
  }
}

Widget centeredScreen(Widget widget) {
  return Scaffold(
    body: Container(
      child: Center(
        child: widget,
      ),
    ),
  );
}

dispatchMouseEvent(String event, ValueNotifier<Socket?> socket) {
  socket.value?.write(event + '\n');
}
