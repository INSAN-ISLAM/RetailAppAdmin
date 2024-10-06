
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:flutter/material.dart';
import 'AdminPanel/AdminNavigationBarPage.dart';
import 'AdminPanel/LogInPage.dart';
import 'package:firebase_core/firebase_core.dart';

import 'core/notification_service.dart';
//import 'fcm_notification.dart';
import 'firebase_options.dart';


initializeNotification () async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  print('User granted permission: ${settings.authorizationStatus}');
}

handleForegroundMessage () {
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Got a message whilst in the foreground!');
    print('Message data: ${message.data}');

    if (message.notification != null) {
      print('Message also contained a notification: ${message.notification}');
      NotificationServices().showNotification(
        title: message.notification!.title,
        body: message.notification!.body,
      );
    }
  });
}


Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();

  print("Handling a background message: ${message.messageId}");
}


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  NotificationServices().initNotification();


  initializeNotification();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);


  handleForegroundMessage();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
   MyApp({super.key});
  final user = FirebaseAuth.instance.currentUser;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home:user == null ?  LogInScreen() :  AdminMainBottomNavBar(),
      //home: AdmFirebaseListAmountExample() ,
    );
  }
}







// class MyApp extends StatelessWidget {
//   MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: "Retail App",
//       debugShowCheckedModeBanner: false,
//       color: Colors.blueAccent,
//       theme: ThemeData(primaryColor: Colors.lightBlue),
//       darkTheme: ThemeData(primaryColor: Colors.black54),
//       themeMode: ThemeMode.dark,
//       home: FutureBuilder<User?>(
//         future: FirebaseAuth.instance.authStateChanges().first,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Scaffold(
//               body: Center(
//                 child: CircularProgressIndicator(), // or a splash screen
//               ),
//             );
//           }
//           else if (snapshot.hasError) {
//             return Scaffold(
//               body: Center(child: Text('Error: ${snapshot.error}')),
//             );
//           }
//           else {
//             final user = snapshot.data;
//             if (user != null) {
//               if (user.uid == "O2GV6e7kUUN4ZhRTgs4JwvUipg43") {
//                 return AdminMainBottomNavBar();
//               } else {
//                 return Text('data');
//               }

//             } else {
//               return LogInSreen();
//             }
//           }
//         },
//       ),
//     );
//   }
// }