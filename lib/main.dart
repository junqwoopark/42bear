import 'package:bear/screen_home.dart';
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
  String? token;
  String? login;

  void getData() async {
    try {
      final pref = await SharedPreferences.getInstance();
      setState(() {
        token = pref.getString('token');
        login = pref.getString('login');
      });
    } catch (e) {
      debugPrint('Foo');
    }
  }

  Future<void> _login() async {
    if (await canLaunchUrlString(authUrl)) {
      final result = await FlutterWebAuth.authenticate(
          url: authUrl, callbackUrlScheme: 'bear', preferEphemeral: true);
      final uri = Uri.parse(result);
      String? code = uri.queryParameters['code'];
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/api/login/?code=$code'),
      );
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final pref = await SharedPreferences.getInstance();
        setState(() {
          pref.setString('token', jsonResponse['token']);
          pref.setString('login', jsonResponse['login']);

          token = pref.getString('token');
          login = pref.getString('login');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    getData();
    if (token != null) {
      return MaterialApp(
        home: SecondScreen(),
      );
    }

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
                image: NetworkImage(
                    'http://127.0.0.1:8000/static/images/logo.png'),
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
                onPressed: () async {
                  await _login();
                  if (token != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SecondScreen()),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                    fixedSize: const Size(200, 75),
                    side: const BorderSide(),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    backgroundColor: Colors.black),
                child: const Text(
                  "Login",
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
