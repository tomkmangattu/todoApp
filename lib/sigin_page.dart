import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:todo_app_tom/home.dart';
import 'package:todo_app_tom/login_page.dart';

class SigninScreen extends StatefulWidget {
  static String id = 'sign_in_page';
  @override
  _SigninScreenState createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _emailId;
  String _password;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign in to continue'),
      ),
      body: Container(
        padding: EdgeInsets.fromLTRB(10, 20, 10, 0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(hintText: 'Enter your email id'),
                autofocus: true,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please Provide an email id';
                  }
                  return null;
                },
                onChanged: (value) {
                  _emailId = value;
                },
              ),
              SizedBox(
                height: 10,
              ),
              TextFormField(
                decoration: InputDecoration(hintText: 'Enter your password'),
                obscureText: true,
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please provide password';
                  }
                  return null;
                },
                onChanged: (value) {
                  _password = value;
                },
              ),
              SizedBox(
                height: 10,
              ),
              FlatButton(
                color: Colors.blueAccent,
                padding: EdgeInsets.all(10),
                onPressed: () {
                  if (_formKey.currentState.validate()) {
                    _signInWithEmail();
                  }
                },
                child: Text(
                  'Sign in',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Text('Or'),
              SizedBox(
                height: 10,
              ),
              FlatButton(
                color: Colors.blueAccent,
                onPressed: () {
                  Navigator.pushNamed(context, LoginScreen.id);
                },
                child: Text(
                  'Login in',
                  style: TextStyle(color: Colors.white),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _signInWithEmail() async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: _emailId, password: _password)
          .then((value) {
        Navigator.popAndPushNamed(context, HomePage.id);
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found with given details');
      }
      if (e.code == 'wrong-password') {
        print('Wrong user name or password');
      }
    }
  }
}
