import 'dart:io';

import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final socket = await Socket.connect(InternetAddress("192.168.1.0"), 15000);

  runApp(MaterialApp(
    title: 'Flutter Demo',
    theme: ThemeData(
      primarySwatch: Colors.blue,
    ),
    home: Scaffold(
      body: Builder(builder: (BuildContext context) {
        return GestureDetector(
          onTapUp: (details) {
            final posString = "${details.globalPosition.dx / MediaQuery
                .of(context)
                .size
                .width},${details.globalPosition.dy / MediaQuery
                .of(context)
                .size
                .height}";
            socket.write(posString);
            print("sent $posString");
          },
        );
      },
      ),
    ),
  ));
}


