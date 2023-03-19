import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bear/screen_home.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:bear/main.dart';

class AchieveScreen extends StatefulWidget {
  const AchieveScreen({super.key});

  @override
  State<AchieveScreen> createState() => _AchieveScreenState();
}

class _AchieveScreenState extends State<AchieveScreen> {
  String? token;
  String? login;
  final baseUrl = 'http://10.18.235.221:8000';
  String pet = 'default';
  String avatar = 'polar';
  int target_time = 1;

  @override
  void initState() {
    super.initState();
    get_info();
  }

  Future<void> get_info() async {
    final pref = await SharedPreferences.getInstance();
    token = pref.getString('token');
    login = pref.getString('login') ?? 'anonymous';
    pet = pref.getString('pet') ?? 'default';
    avatar = pref.getString('avatar') ?? 'polar';
  }

  BorderSide get borderSideGun => BorderSide(
        color:
            avatar == 'gun' ? Color.fromARGB(255, 246, 195, 75) : Colors.white,
        width: avatar == 'gun' ? 5.0 : 1.0,
      );

  BorderSide get borderSideGon => BorderSide(
        color:
            avatar == 'gon' ? Color.fromARGB(255, 103, 157, 125) : Colors.white,
        width: avatar == 'gon' ? 5.0 : 1.0,
      );

  BorderSide get borderSideGam => BorderSide(
        color:
            avatar == 'gam' ? Color.fromARGB(255, 88, 130, 161) : Colors.white,
        width: avatar == 'gam' ? 5.0 : 1.0,
      );

  BorderSide get borderSideLee => BorderSide(
        color:
            avatar == 'lee' ? Color.fromARGB(255, 173, 74, 69) : Colors.white,
        width: avatar == 'lee' ? 5.0 : 1.0,
      );

  BorderSide get borderSideClassic => BorderSide(
        color: avatar == 'polar'
            ? Color.fromARGB(255, 181, 179, 179)
            : Colors.white,
        width: avatar == 'polar' ? 5.0 : 1.0,
      );

  void onPressedGun() {
    setState(() {
      avatar = 'gun';
    });
  }

  void onPressedGon() {
    setState(() {
      avatar = 'gon';
    });
  }

  void onPressedGam() {
    setState(() {
      avatar = 'gam';
    });
  }

  void onPressedLee() {
    setState(() {
      avatar = 'lee';
    });
  }

  void onPressedClassic() {
    setState(() {
      avatar = 'polar';
    });
  }

  Future<void> _updateUser(
      String login, int target_time, String avatar, String pet) async {
    final pref = await SharedPreferences.getInstance();
    token = pref.getString('token');
    login = pref.getString('login')!;
    target_time = pref.getInt('target_time') ?? 1;
    Map<String, dynamic> body = {
      'login': login,
      'target_time': target_time,
      'avatar': avatar,
      'pet': pet,
    };
    final response = await http.patch(
        Uri.parse(baseUrl + '/api/user/?token=$token'),
        body: jsonEncode(body));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "업적",
          style: TextStyle(
            fontFamily: 'dosgothic',
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.close_outlined,
            size: 30,
            color: Colors.black,
          ),
        ),
        actions: [
          OutlinedButton(
            style: ButtonStyle(
              overlayColor:
                  MaterialStateProperty.all(Color.fromARGB(255, 181, 179, 179)),
              side: MaterialStateProperty.all(
                BorderSide(
                  color: Colors.white,
                ),
              ),
            ),
            onPressed: () {
              _updateUser(login!, target_time!, avatar, pet);
              Navigator.pop(context, avatar);
            },
            child: Column(
              children: [
                const Text(
                  "선택",
                  style: TextStyle(
                    fontFamily: 'dosgothic',
                    fontSize: 20,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    height: 2,
                  ),
                ),
              ],
            ),
          ),
        ],
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  style: ButtonStyle(
                    overlayColor: MaterialStateProperty.all(
                        Color.fromARGB(255, 246, 195, 75)),
                    fixedSize: MaterialStatePropertyAll(Size(200, 220)),
                    side: MaterialStateProperty.all(borderSideGun),
                  ),
                  onPressed: onPressedGun,
                  child: Column(
                    children: [
                      SizedBox(
                        height: 20,
                      ),
                      Image.network(
                        baseUrl + '/static/images/gun.png',
                        width: 140,
                        height: 160,
                      ),
                      const Text(
                        "건곰",
                        style: TextStyle(
                          fontFamily: 'dosgothic',
                          fontSize: 30,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          height: 1,
                        ),
                      ),
                    ],
                  ),
                ),
                OutlinedButton(
                  style: ButtonStyle(
                    overlayColor: MaterialStateProperty.all(
                        Color.fromARGB(255, 103, 157, 125)),
                    fixedSize: MaterialStatePropertyAll(Size(200, 220)),
                    side: MaterialStateProperty.all(borderSideGon),
                  ),
                  onPressed: onPressedGon,
                  child: Column(
                    children: [
                      SizedBox(height: 20),
                      Image.network(
                        baseUrl + '/static/images/gon.png',
                        width: 140,
                        height: 160,
                      ),
                      const Text(
                        "곤곰",
                        style: TextStyle(
                          fontFamily: 'dosgothic',
                          fontSize: 30,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          height: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  style: ButtonStyle(
                    overlayColor: MaterialStateProperty.all(
                        Color.fromARGB(255, 88, 130, 161)),
                    fixedSize: MaterialStatePropertyAll(Size(200, 220)),
                    side: MaterialStateProperty.all(borderSideGam),
                  ),
                  onPressed: onPressedGam,
                  child: Column(
                    children: [
                      SizedBox(
                        height: 20,
                      ),
                      Image.network(
                        baseUrl + '/static/images/gam.png',
                        width: 140,
                        height: 160,
                      ),
                      const Text(
                        "감곰",
                        style: TextStyle(
                          fontFamily: 'dosgothic',
                          fontSize: 30,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          height: 1,
                        ),
                      ),
                    ],
                  ),
                ),
                OutlinedButton(
                  style: ButtonStyle(
                    overlayColor: MaterialStateProperty.all(
                        Color.fromARGB(255, 173, 74, 69)),
                    fixedSize: MaterialStatePropertyAll(Size(200, 220)),
                    side: MaterialStateProperty.all(borderSideLee),
                  ),
                  onPressed: onPressedLee,
                  child: Column(
                    children: [
                      SizedBox(
                        height: 20,
                      ),
                      Image.network(
                        baseUrl + '/static/images/lee.png',
                        width: 140,
                        height: 160,
                      ),
                      const Text(
                        "리곰",
                        style: TextStyle(
                          fontFamily: 'dosgothic',
                          fontSize: 30,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          height: 1,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  style: ButtonStyle(
                    overlayColor: MaterialStateProperty.all(
                        Color.fromARGB(255, 181, 179, 179)),
                    fixedSize: MaterialStatePropertyAll(Size(200, 220)),
                    side: MaterialStateProperty.all(borderSideClassic),
                  ),
                  onPressed: onPressedClassic,
                  child: Column(
                    children: [
                      SizedBox(
                        height: 20,
                      ),
                      Image.network(
                        baseUrl + '/static/images/polar.png',
                        width: 140,
                        height: 160,
                      ),
                      const Text(
                        "폴라",
                        style: TextStyle(
                          fontFamily: 'dosgothic',
                          fontSize: 30,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          height: 1,
                        ),
                      ),
                    ],
                  ),
                ),
                OutlinedButton(
                  style: ButtonStyle(
                    overlayColor: MaterialStateProperty.all(
                        Color.fromARGB(255, 181, 179, 179)),
                    fixedSize: MaterialStatePropertyAll(Size(200, 220)),
                    side: MaterialStatePropertyAll(
                      BorderSide(
                        color: Colors.white,
                        width: 1.0,
                      ),
                    ),
                  ),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (BuildContext context) {
                        return FractionallySizedBox(
                          heightFactor:
                              0.5, // Set the height as a fraction of the screen height
                          child: Align(
                            alignment: Alignment.center,
                            child: Container(
                              child: Column(
                                children: [
                                  ListTile(
                                    leading: Icon(Icons.pets_rounded),
                                    title: Text(
                                      'default',
                                      style: TextStyle(
                                        fontFamily: 'futura',
                                        fontSize: 20,
                                        color: Colors.black,
                                        height: 1.5,
                                      ),
                                    ),
                                    onTap: () {
                                      setState(
                                        () {
                                          pet = 'default';
                                        },
                                      );
                                      Navigator.pop(context);
                                    },
                                  ),
                                  ListTile(
                                    leading: Icon(Icons.pets_rounded),
                                    title: Text(
                                      'libft',
                                      style: TextStyle(
                                        fontFamily: 'futura',
                                        fontSize: 20,
                                        color: Colors.black,
                                        height: 1.5,
                                      ),
                                    ),
                                    onTap: () {
                                      setState(
                                        () {
                                          pet = 'libft';
                                        },
                                      );
                                      Navigator.pop(context);
                                    },
                                  ),
                                  ListTile(
                                    leading: Icon(Icons.pets_rounded),
                                    title: Text(
                                      'born2beroot',
                                      style: TextStyle(
                                        fontFamily: 'futura',
                                        fontSize: 20,
                                        color: Colors.black,
                                        height: 1.5,
                                      ),
                                    ),
                                    onTap: () {
                                      setState(
                                        () {
                                          pet = 'borntoberoot';
                                        },
                                      );
                                      Navigator.pop(context);
                                    },
                                  ),
                                  ListTile(
                                    leading: Icon(Icons.pets_rounded),
                                    title: Text(
                                      'pipex',
                                      style: TextStyle(
                                        fontFamily: 'futura',
                                        fontSize: 20,
                                        color: Colors.black,
                                        height: 1.5,
                                      ),
                                    ),
                                    onTap: () {
                                      setState(
                                        () {
                                          pet = 'pipex';
                                        },
                                      );
                                      Navigator.pop(context);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                  child: Column(
                    children: [
                      SizedBox(
                        height: 20,
                      ),
                      Image.network(
                        baseUrl + '/static/images/' + pet + '.png',
                        width: 180,
                        height: 180,
                      ),
                      const Text(
                        "펫",
                        style: TextStyle(
                          fontFamily: 'dosgothic',
                          fontSize: 30,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          height: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
