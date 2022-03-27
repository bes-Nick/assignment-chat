import 'dart:convert';

import 'package:chatapp/helper/authenticate.dart';
import 'package:chatapp/helper/helperfunctions.dart';
import 'package:chatapp/services/database.dart';
import 'package:chatapp/views/chatrooms.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Connectivity _connectivity = Connectivity();
  DatabaseMethods _databaseMethods = DatabaseMethods();
  bool userIsLoggedIn;

  void listenToNetworkConnectivity() {
    _connectivity.onConnectivityChanged.listen((connectivityResult) async {
      print(
          'QueueTest: COnnectivity Status Changed: ${connectivityResult.name}');
      // Called every time Connectivity result changes
      if (connectivityResult.name != ConnectivityResult.none.name) {
        // Now it's connected...

        var pendingMessage = await HelperFunctions.getPendingMessageToSend();
        while (pendingMessage != null) {
          // Sending this pendingMessage to database
          try {
            print(
                'QueueTest: Sending Pending Message: ${jsonEncode(pendingMessage)}');
            await _databaseMethods.addMessage(
                pendingMessage.chatRoomId, pendingMessage.chatMessageData);
          } catch (err) {
            // As there's an error sending this message we return
            // assuming that there's no connection and we wait
            // for connection status to update again
            return;
          }

          await HelperFunctions.removeFirstMsgFromQueue();
          pendingMessage = await HelperFunctions.getPendingMessageToSend();
        }
      }
    });
  }

  @override
  void initState() {
    getLoggedInState();
    listenToNetworkConnectivity();
    super.initState();
  }

  getLoggedInState() async {
    await HelperFunctions.getUserLoggedInSharedPreference().then((value) {
      setState(() {
        userIsLoggedIn = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlutterChat',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color(0xff145C9E),
        scaffoldBackgroundColor: Color(0xff1F1F1F),
        accentColor: Color(0xff007EF4),
        fontFamily: "OverpassRegular",
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: userIsLoggedIn != null
          ? userIsLoggedIn
              ? ChatRoom()
              : Authenticate()
          : Container(
              child: Center(
                child: Authenticate(),
              ),
            ),
    );
  }
}
