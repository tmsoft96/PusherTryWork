import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:pusher_client/pusher_client.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  PusherClient pusher;
  Channel channel;

  List<dynamic> pushData = [];

  @override
  void initState() {
    super.initState();
    pushData.clear();

    String token = getToken();

    pusher = new PusherClient(
      "3268e4a021fcb8fc2cfd",
      PusherOptions(
        // if local on android use 10.0.2.2
        // host: 'localhost',
        // encrypted: false,
        auth: PusherAuth(
          'https://138977fb5eb7.ngrok.io/broadcasting/auth',
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      ),
      enableLogging: true,
    );

    channel = pusher.subscribe("private-orders");

    pusher.onConnectionStateChange((state) {
      log("previousState: ${state.previousState}, currentState: ${state.currentState}");
    });

    pusher.onConnectionError((error) {
      log("error: ${error.message}");
    });

    channel.bind('my-event', (event) {
      log(event.data);
      setState(() {
        pushData += [event.data];
      });
    });

    channel.bind('client-my-event', (event) {
      log(event.data);
      setState(() {
        pushData += [event.data];
      });
    });

    // channel.bind('order-filled', (event) {
    //   log("Order Filled Event" + event.data.toString());
    // });
  }

  String getToken() => "369693a4e8a1595d7091";

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Example Pusher App'),
        ),
        body: SingleChildScrollView(
          child: Center(
              child: Column(
            children: [
              // RaisedButton(
              //   child: Text('Unsubscribe Private Orders'),
              //   onPressed: () {
              //     pusher.unsubscribe('private-orders');
              //   },
              // ),
              // RaisedButton(
              //   child: Text('Unbind Status Update'),
              //   onPressed: () {
              //     channel.unbind('status-update');
              //   },
              // ),
              // RaisedButton(
              //   child: Text('Unbind Order Filled'),
              //   onPressed: () {
              //     channel.unbind('order-filled');
              //   },
              // ),
              // RaisedButton(
              //   child: Text('Bind Status Update'),
              //   onPressed: () {
              //     channel.bind('status-update', (PusherEvent event) {
              //       log("Status Update Event" + event.data.toString());
              //     });
              //   },
              // ),
              RaisedButton(
                child: Text('Trigger Client Typing'),
                onPressed: () {
                  channel.trigger('my-event', {'name': 'Bob'});
                },
              ),
              for (var data in pushData) Text("$data"),
            ],
          )),
        ),
      ),
    );
  }
}
