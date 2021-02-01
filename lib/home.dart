import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:todo_app_tom/sigin_page.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

CollectionReference todo = FirebaseFirestore.instance
    .collection('Todo')
    .doc(FirebaseAuth.instance.currentUser.email)
    .collection('todo');

User _user;

class HomePage extends StatefulWidget {
  static String id = 'home_page';
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  static List<Widget> _tabs = <Widget>[
    TodoList(),
    QuotePage(),
  ];
  String _todoItem;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
    todo = FirebaseFirestore.instance
        .collection('Todo')
        .doc(FirebaseAuth.instance.currentUser.email)
        .collection('todo');
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Todo App'),
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                child: Text('log out'),
                value: 'logout',
              )
            ],
            onSelected: (value) async {
              if (value == 'logout') {
                await FirebaseAuth.instance.signOut();
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                } else {
                  Navigator.popAndPushNamed(context, SigninScreen.id);
                }
              }
            },
          ),
        ],
      ),
      body: _tabs.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'todo'),
          BottomNavigationBarItem(
              icon: Icon(Icons.format_quote), label: 'Quote of day'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              backgroundColor: Colors.amber[800],
              child: Icon(Icons.add),
              onPressed: () {
                showModalBottomSheet(
                    context: context,
                    builder: (BuildContext context) {
                      return Container(
                        padding: EdgeInsets.fromLTRB(10, 20, 10, 0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              TextFormField(
                                onChanged: (value) {
                                  _todoItem = value;
                                },
                                autofocus: true,
                                decoration: InputDecoration(
                                    hintText: 'Enter todo item '),
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return "Please enter todo item";
                                  }
                                },
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              FlatButton(
                                color: Colors.blueAccent,
                                onPressed: () {
                                  if (_formKey.currentState.validate()) {
                                    _addToTodoList();
                                  }
                                },
                                child: Text(
                                  'Add',
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    });
              },
            )
          : null,
    );
  }

  void _addToTodoList() async {
    Map data = <String, dynamic>{
      'item': _todoItem,
    };
    await todo.add(data);
  }
}

class TodoList extends StatefulWidget {
  @override
  _TodoListState createState() => _TodoListState();
}

class _TodoListState extends State<TodoList> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: StreamBuilder(
        stream: todo.snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Error Loading data');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text('loading..');
          }
          return ListView(
            children: snapshot.data.docs.map((DocumentSnapshot document) {
              return ListTile(
                leading: Text(document.data()['item']),
                trailing: IconButton(
                  icon: Icon(
                    Icons.delete,
                    color: Colors.red,
                  ),
                  onPressed: () {
                    todo.doc(document.id).delete();
                  },
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

class QuotePage extends StatefulWidget {
  @override
  _QuotePageState createState() => _QuotePageState();
}

class _QuotePageState extends State<QuotePage> {
  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Icon(
            Icons.format_quote,
            size: 100,
            color: Colors.orangeAccent,
          ),
        ),
        FutureBuilder(
          future: _fetchQuote(),
          builder: (BuildContext context, snaphot) {
            if (snaphot.hasError) {
              return Text(snaphot.error.toString());
            }
            if (snaphot.connectionState == ConnectionState.done) {
              return Text(
                snaphot.data,
              );
            }
            return Text('loading..');
          },
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Icon(
            Icons.format_quote,
            size: 100,
            color: Colors.orangeAccent,
          ),
        ),
      ],
    ));
  }

  Future _fetchQuote() async {
    final response = await http.get('https://quotes.rest/qod');

    if (response.statusCode == 200) {
      print(jsonDecode(response.body)['contents']['quotes'][0]['quote']);
      return jsonDecode(response.body)['contents']['quotes'][0]['quote'];
    } else {
      print(response.statusCode);
      if (response.statusCode == 429) {
        return 'Retry after sometime . too many requests';
      } else
        return 'Falied to load data';
    }
  }
}
