import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:todo_app_tom/home.dart';
import 'package:todo_app_tom/login_page.dart';
import 'package:todo_app_tom/sigin_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: (FirebaseAuth.instance.currentUser == null)
          ? SigninScreen.id
          : HomePage.id,
      routes: {
        SigninScreen.id: (context) => SigninScreen(),
        LoginScreen.id: (context) => LoginScreen(),
        HomePage.id: (context) => HomePage(),
      },
    );
  }
}
