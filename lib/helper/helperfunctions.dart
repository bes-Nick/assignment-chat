import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class HelperFunctions {
  static String sharedPreferenceUserLoggedInKey = "ISLOGGEDIN";
  static String sharedPreferenceUserNameKey = "USERNAMEKEY";
  static String sharedPreferenceUserEmailKey = "USEREMAILKEY";
  static String sharedPreferenceMessageQueueKey = "MESSAGEQUEUEKEY";

  /// saving data to sharedpreference
  static Future<bool> saveUserLoggedInSharedPreference(
      bool isUserLoggedIn) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return await preferences.setBool(
        sharedPreferenceUserLoggedInKey, isUserLoggedIn);
  }

  static Future<bool> saveUserNameSharedPreference(String userName) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return await preferences.setString(sharedPreferenceUserNameKey, userName);
  }

  static Future<bool> saveUserEmailSharedPreference(String userEmail) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return await preferences.setString(sharedPreferenceUserEmailKey, userEmail);
  }

  /// fetching data from sharedpreference

  static Future<bool> getUserLoggedInSharedPreference() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return await preferences.getBool(sharedPreferenceUserLoggedInKey);
  }

  static Future<String> getUserNameSharedPreference() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return await preferences.getString(sharedPreferenceUserNameKey);
  }

  static Future<String> getUserEmailSharedPreference() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return await preferences.getString(sharedPreferenceUserEmailKey);
  }

  static Future<List<String>> getMessageLocalQueue() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    if (preferences.containsKey(sharedPreferenceMessageQueueKey))
      return preferences.getStringList(sharedPreferenceMessageQueueKey);
    return List<String>.empty(); // Returning null if no queue exists yet
  }

  static Future<bool> addMessageToLocalQueue(messageData) async {
    try {
      print(
          'QueueTest: No COnnection, Adding to local queue: ${jsonEncode(messageData)}');
      SharedPreferences preferences = await SharedPreferences.getInstance();
      var currQueue = await getMessageLocalQueue();
      currQueue.add(jsonEncode(messageData));
      preferences.setStringList(sharedPreferenceMessageQueueKey, currQueue);
      return true;
    } catch (ex) {
      print('Error adding to queue : ${ex.toString()}');
      return false;
    }
  }

  // RETURN: null - nothing left
  // RETURN: dynamic - send this to database
  static Future<dynamic> getPendingMessageToSend() async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      var currQueue = await getMessageLocalQueue();
      if (currQueue.isEmpty) return null;

      return jsonDecode(currQueue.first);
    } catch (ex) {
      print('Error getPendingMessageToSend : ${ex.toString()}');
      return null;
    }
  }

  static Future<bool> removeFirstMsgFromQueue() async {
    try {
      print('QueueTest: Removing FIrst Message from queue');
      SharedPreferences preferences = await SharedPreferences.getInstance();
      var currQueue = await getMessageLocalQueue();
      if (currQueue.isNotEmpty) currQueue.removeAt(0);
      preferences.setStringList(sharedPreferenceMessageQueueKey, currQueue);
      return true;
    } catch (ex) {
      print('Error removeFirstMsgFromQueue : ${ex.toString()}');
      return false;
    }
  }
}
