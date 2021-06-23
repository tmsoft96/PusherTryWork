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
  Channel privateChurchChannel, presenceChurchChannel;

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
          'https://56a527cd47fd.ngrok.io/auth',
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      ),
      enableLogging: true,
    );

    pusher.onConnectionStateChange((state) {
      log("previousState: ${state.previousState}, currentState: ${state.currentState}");
    });

    pusher.onConnectionError((error) {
      log("error: ${error.message}");
    });

    privateChurchChannel = pusher.subscribe("private-church.1000002");

    privateChurchChannel.bind('pusher:subscription_succeeded', (event) {
      log("subscription_suceeded ${event.data}");
      privateChurchChannel.bind('TestimonyApproved', (event) {
        log(event.data);
        setState(() {
          pushData += [event.data];
        });
      });

      //two clients talking to each other
      privateChurchChannel.bind("client-private-church.1000002", (event) {
        log("private client-typing-private-channel-example ${event.data}");
      });
    });

    privateChurchChannel.bind('pusher:subscription_error', (error) {
      log("subscription_error ${error.data}");
    });

    //presence
    presenceChurchChannel = pusher.subscribe("presence-channel-example");

    presenceChurchChannel.bind('pusher:subscription_succeeded', (event) {
      log("presence subscription_suceeded ${event.data}");
      presenceChurchChannel.bind("pusher:member_added", (PusherEvent event) {
        log("presence member_added ${event.data}");
      });

      presenceChurchChannel.bind("pusher:member_removed", (PusherEvent event) {
        log("presence member_removed ${event.data}");
      });
    });
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
                  privateChurchChannel.trigger('my-event', {'name': 'Bob'});
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
