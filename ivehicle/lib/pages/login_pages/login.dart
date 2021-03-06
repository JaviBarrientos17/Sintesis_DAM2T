import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:ivehicle/pages/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'admin.dart';
import 'register.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController username = new TextEditingController();
  TextEditingController password = new TextEditingController();
  final _key = GlobalKey<FormState>();
  void saveSession(Map user, int s) async {
    SharedPreferences p = await SharedPreferences.getInstance();
    p.setString("user", json.encode(user));
    p.setInt("statut", s);
    p.commit();
  }

  int statut = 0;
  Map user;
  void getSession() async {
    SharedPreferences p = await SharedPreferences.getInstance();
    if (p.getInt("statut") == 1) {
      setState(() {
        statut = 1;
        user = json.decode(p.getString("user"));
      });
    } else {
      setState(() {
        statut = 0;
      });
    }
  }

  void login() async {
    if (_key.currentState.validate()) {
      if (_key.currentState.validate()) {
        var uri =
            Uri.parse("https://ivehicleproject.000webhostapp.com/file.php");
        final response = await http.post(uri,
            body: {"user": username.text, "type": '2', "pass": password.text});

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['val'] == 1) {
            message(data['statut']);
            print(data['info']);
            saveSession(data['info'], 1);
            getSession();
          } else {
            message(data['statut']);
            print(data['user']);
          }
        }
      }
    }
  }

  logOut() async {
    SharedPreferences p = await SharedPreferences.getInstance();
    setState(() {
      p.setString("user", null);
      p.setInt("statut", null);
      statut = 0;
      p.commit();
    });
  }

  @override
  void initState() {
    super.initState();
    getSession();
  }

  @override
  Widget build(BuildContext context) {
    switch (statut) {
      case 1:
        return Admin(user: user, signOut: logOut);
        break;
      case 0:
        return Scaffold(
          backgroundColor: Color.fromRGBO(44, 44, 44, 0.6),
          body: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Form(
                  key: _key,
                  child: Column(
                    children: <Widget>[
                      Image.network(
                        "https://ivehicleproject.000webhostapp.com/imgs/logo_Alex.png",
                        height: 250,
                      ),
                      Card(
                        child: TextFormField(
                          controller: username,
                          validator: (e) =>
                              e.isEmpty ? "You must write something!" : null,
                          style: TextStyle(fontSize: 20),
                          decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(20),
                              prefixIcon: Padding(
                                padding: EdgeInsets.only(left: 20, right: 15),
                                child: Icon(
                                  Icons.person,
                                  size: 30,
                                ),
                              ),
                              labelText: "Username"),
                          keyboardType: TextInputType.text,
                        ),
                      ),
                      Card(
                        child: TextFormField(
                          controller: password,
                          validator: (e) =>
                              e.isEmpty ? "You must write something!" : null,
                          style: TextStyle(fontSize: 20),
                          obscureText: true,
                          decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(20),
                              prefixIcon: Padding(
                                padding: EdgeInsets.only(left: 20, right: 15),
                                child: Icon(
                                  Icons.lock,
                                  size: 30,
                                ),
                              ),
                              labelText: "Password"),
                          keyboardType: TextInputType.text,
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      SizedBox(
                        height: 44,
                        // ignore: deprecated_member_use
                        child: RaisedButton(
                          onPressed: () {
                            login();
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => HomePage()));
                          },
                          //onPressed: login,
                          color: Colors.lightBlueAccent,
                          child: Text(
                            "Login",
                            style: TextStyle(fontSize: 19, color: Colors.white),
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            "You don't have an account? ",
                            style: TextStyle(color: Colors.white),
                          ),
                          // ignore: deprecated_member_use
                          FlatButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Register()));
                            },
                            child: Text(
                              "Sign up",
                              style: TextStyle(
                                  color: Colors.lightBlueAccent,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      default:
    }
  }
}
