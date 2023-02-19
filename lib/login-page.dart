import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:presensi/home-page.dart';
import 'package:http/http.dart' as myHttp;
import 'package:presensi/models/login-response.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  late Future<String> _name, _token;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _token = _prefs.then((SharedPreferences prefs) {
      return prefs.getString("token") ?? "";
    });

    _name = _prefs.then((SharedPreferences prefs) {
      return prefs.getString("name") ?? "";
    });
  }

  Future login(email, password) async {
    LoginResponseModel? loginResponseModel;
    Map<String, String> body = {"email": email, "password": password};
    final headers = {'Content-Type': 'application/x-www-form-urlencoded'};
    var response = await myHttp.post(
        Uri.parse('http://192.168.200.18:8000/api/login'),
        body: body,
        headers: headers);
    if (response.statusCode == 401) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Email atau Password Salah!")));
    } else {
      loginResponseModel =
          LoginResponseModel.fromJson(json.decode(response.body));
      saveUser(loginResponseModel.data.token, loginResponseModel.data.name);
    }
  }

  Future saveUser(token, name) async {
    final SharedPreferences pref = await _prefs;
    pref.setString("name", name);
    pref.setString("token", token);
    print("Lewat SNI");

    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => HomePage()))
        .then((value) => (value));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(child: Text("LOGIN")),
            SizedBox(height: 20),
            Text("Email"),
            TextField(
              controller: emailController,
            ),
            SizedBox(height: 20),
            Text("Password"),
            TextField(
              controller: passwordController,
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
                onPressed: () {
                  login(emailController.text, passwordController.text);
                },
                child: Text("Masuk"))
          ],
        ),
      ),
    )));
  }
}
