import 'package:fastic_counter/theme/typography.dart';
import 'package:flutter/material.dart';
import 'package:fastic_counter/ui/screens/step_counter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'package:cron/cron.dart';
import 'package:intl/intl.dart';

import 'bloc/counter/counter_bloc.dart';
import 'bloc/simple_bloc_observer.dart';

Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();

  Bloc.observer = SimpleBlocObserver();

  tz.initializeTimeZones();

  // Initialize the local notifications
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  // Schedule the daily notification for 8 p.m.
  void scheduleNotification() async {
    DateTime now = DateTime.now();
    DateTime firstNotification;
    int notificationHour = 20;
    int notificationMinute = 0;

    // If the function is run before 8p.m. set the reminder for today, otherwise for tomorrow
    if (now.hour < notificationHour) {
      firstNotification = new DateTime(now.year, now.month, now.day, notificationHour, notificationMinute);
    } else {
      firstNotification = new DateTime(now.year, now.month, now.day + 1, notificationHour, notificationMinute);
    }

    await flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        'Huhu :)',
        'Du hast Dein Daily Goal noch nicht erreicht.',
        tz.TZDateTime.from(firstNotification, tz.local),
        const NotificationDetails(
            android: AndroidNotificationDetails('your channel id',
                'your channel name', 'your channel description')),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time
    );
  }

  scheduleNotification();

  SharedPreferences prefs = await SharedPreferences.getInstance();

  // Run a cron job, every day at 19:59, which is one minute before the daily notification is sent
  // If the Daily Goal is already reached -> Cancel the Notification and set a new notification for the next day
  final cron = Cron();
  cron.schedule(Schedule.parse('59 19 * * *'), () async {
    String date = DateFormat('yyyy-MM-dd').format(DateTime.now());

    if (prefs.getInt('goal' + date) != null) {
      if (prefs.getBool('goalReached' + date)) {
        flutterLocalNotificationsPlugin.cancel(0);
        scheduleNotification();
      }
    } else {
      flutterLocalNotificationsPlugin.cancel(0);
      scheduleNotification();
    }
  });

  runApp(MyApp());

}



class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Fastic Counter',
      theme: ThemeData(
        textTheme: AppTypography.textTheme,
        scaffoldBackgroundColor: Colors.white,
        backgroundColor: Colors.white,
        appBarTheme: AppBarTheme(color: Colors.white, elevation: 0.0),
      ),
      home: BlocProvider(
        create: (_) => CounterBloc(),
        child: StepCounter(),
      ),
    );
  }
}
