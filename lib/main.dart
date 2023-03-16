import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher_string.dart';

void main() {
  runApp(
    const MaterialApp(home: FirstScreen()),
  );
}

class FirstScreen extends StatefulWidget {
  const FirstScreen({super.key});

  @override
  State<FirstScreen> createState() => _FirstState();
}

class _FirstState extends State<FirstScreen> {
  final String authUrl =
      'https://api.intra.42.fr/oauth/authorize?client_id=u-s4t2ud-68cf21898612ee91cdf50db3608567d352f3098108ac6b9fc6029df42e192831&redirect_uri=bear%3A%2F%2Fcallback&response_type=code';

  Future<void> _login() async {
    if (await canLaunchUrlString(authUrl)) {
      final result = await FlutterWebAuth.authenticate(
          url: authUrl, callbackUrlScheme: 'bear');
      final uri = Uri.parse(result);
      String? code = uri.queryParameters['code'];
      final response = await http.get(
        Uri.parse('http://10.18.235.221:8000/api/login/?code=$code'),
      );
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final token = jsonResponse['token'];
        final login = jsonResponse['login'];
        final SharedPreferences pref = await SharedPreferences.getInstance();
        pref.setString('token', token);
        pref.setString('login', login);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 300,
            height: 150,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/logo.png'),
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _login,
                style: ElevatedButton.styleFrom(
                    fixedSize: const Size(200, 75),
                    side: const BorderSide(),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    backgroundColor: Colors.black),
                child: const Text(
                  "sign up",
                  style: TextStyle(
                    fontFamily: 'futura',
                    fontSize: 30,
                    color: Colors.white,
                    height: 0.9,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class login extends StatelessWidget {
  const login({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}
