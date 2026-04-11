import 'dart:io';

import 'package:camera_app/providers/tab_provider.dart';
import 'package:camera_app/providers/user_provider.dart';
import 'package:camera_app/providers/detection_provider.dart';
import 'package:camera_app/routes/app_routes.dart';
import 'package:camera_app/screens/signin.dart';
import 'package:camera_app/services/notification_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ezviz_flutter/ezviz_flutter.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> _firebaseMessagingBackgroundHandler(
  RemoteMessage message,
) async {
  // Chỉ đăng ký handler này khi Firebase iOS đã cấu hình; tạm thời BỎ với iOS
  try {
    await Firebase.initializeApp();
  } catch (_) {}
  print(
    "Handling a background message: ${message.messageId}",
  );
}

Future<void> _initFirebaseSafely() async {
  if (Platform.isAndroid) {
    // Android đã có google-services.json → ok
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(
      _firebaseMessagingBackgroundHandler,
    );
  } else if (Platform.isIOS) {
    // CHƯA cấu hình iOS → KHÔNG initialize để tránh crash
    // Khi bạn đã có cấu hình iOS, thay thế bằng:
    // await Firebase.initializeApp(
    //   options: DefaultFirebaseOptions.ios, // nếu dùng flutterfire
    // );
    // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initFirebaseSafely();

  // Init notification service CHỈ khi Android, hoặc khi iOS đã init Firebase
  if (Platform.isAndroid ||
      (Platform.isIOS && Firebase.apps.isNotEmpty)) {
    await NotificationService.init();
    NotificationService.listenFCM();
  }
  EzvizConstants.setRegion(EzvizRegion.china);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => UserProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => TabProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => DetectionProvider(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      home: Signin(),
      onGenerateRoute: AppRoute.generateRoute,
      debugShowCheckedModeBanner: false,
    );
  }
}
