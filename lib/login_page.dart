import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:todo_app_tom/home.dart';

class LoginScreen extends StatefulWidget {
  static String id = 'login_page';
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _emailId;
  String _pass1;
  String _pass2;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Log in to continue'),
      ),
      body: Container(
        padding: EdgeInsets.fromLTRB(10, 10, 20, 0),
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
                    return 'Please enter an email id';
                  }
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
                    return 'Please enter a password';
                  }
                },
                onChanged: (value) {
                  _pass1 = value;
                },
              ),
              TextFormField(
                decoration: InputDecoration(hintText: 'Conform your password'),
                obscureText: true,
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter a password';
                  }
                  if (value != _pass1) {
                    return 'Passwords doesn\'t match';
                  }
                },
                onChanged: (value) {
                  _pass2 = value;
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
                    _loginWithEmail();
                  }
                },
                child: Text(
                  'Login in',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _loginWithEmail() async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: _emailId, password: _pass1);
      Navigator.popAndPushNamed(context, HomePage.id);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('please enter a strong password');
      }
      if (e.code == 'email-already-in-use') {
        print('User already exit');
      }
    } catch (e) {
      print(e);
    }
  }
}
