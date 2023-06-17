import 'dart:math';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

notify(tit, desc) {
  FlutterLocalNotificationsPlugin flip = FlutterLocalNotificationsPlugin();

  // app_icon needs to be a added as a drawable
  // resource to the Android head project.
  var android = const AndroidInitializationSettings('@mipmap/ic_launcher');

  var IOS = const DarwinInitializationSettings();

  // initialise settings for both Android and iOS device.
  var settings = InitializationSettings(android: android, iOS: IOS);

  flip.initialize(settings);

  _showNotificationWithDefaultSound(flip, tit, desc);
}

Future _showNotificationWithDefaultSound(flip, tit, desc) async {
  // Show a notification after every 15 minute with the first
  // appearance happening a minute after invoking the method

  var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
      'your channel id', 'your channel name',
      channelDescription: 'your channel description',
      importance: Importance.max,
      priority: Priority.high);

  var iOSPlatformChannelSpecifics = const DarwinNotificationDetails();

  // initialise channel platform for both Android and iOS device.
  var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics);

  Random random = new Random();
  int randomNumber = random.nextInt(500);

  await flip.show(randomNumber, '$tit', '$desc', platformChannelSpecifics,
      payload: 'Default_Sound');
}
