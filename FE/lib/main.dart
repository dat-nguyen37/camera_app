import 'package:camera_app/providers/user_provider.dart';
import 'package:camera_app/routes/app_routes.dart';
import 'package:camera_app/screens/signup.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => UserProvider(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Signup(),
      onGenerateRoute: AppRoute.generateRoute,
      debugShowCheckedModeBanner: false,
    );
  }
}
