import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:bear/main.dart';
import 'package:flutter_material_pickers/flutter_material_pickers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:percent_indicator/percent_indicator.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher_string.dart';

class SecondScreen extends StatefulWidget {
  @override
  SecondScreenState createState() => SecondScreenState();
}

class SecondScreenState extends State<SecondScreen> {
  String? token;
  String? login;
  String? intra_time;
  double? intra_percent;
  int? target_time;
  int? avatar;
  int? pet;

  @override
  void initState() {
    super.initState();
    _getData();
  }

  final String base_url = 'http://10.18.235.221:8000/api/';

  Future<void> _getData() async {
    final pref = await SharedPreferences.getInstance();

    setState(() {
      token = pref.getString('token');
      login = pref.getString('login');
      intra_time = pref.getString('time');
      target_time = pref.getInt('target_time');
      avatar = pref.getInt('avatar');
      pet = pref.getInt('pet');
      intra_percent = pref.getDouble('intra_percent');
    });
  }

  Future<void> _updateUser(
      String login, int target_time, int avatar, int pet) async {
    final pref = await SharedPreferences.getInstance();
    token = pref.getString('token');
    Map<String, dynamic> body = {
      'login': login,
      'target_time': target_time,
      'avatar': avatar,
      'pet': pet,
    };
    final response = await http.patch(
        Uri.parse(base_url + 'user/?token=$token'),
        body: jsonEncode(body));
  }

  Future<void> _get_time() async {
    final pref = await SharedPreferences.getInstance();
    token = pref.getString('token');
    final response = await http.get(
      Uri.parse(base_url + 'user/time/?token=$token'),
    );
    if (response.statusCode == 200) {
      intra_time = jsonDecode(response.body)['time'].split('.')[0];
      var intra_sec = jsonDecode(response.body)['second'];
      double intra_sec_double = intra_sec.toDouble();
      setState(() {
        if (target_time == 0 || target_time == null)
          pref.setDouble('intra_percent', 1.0);
        else if ((intra_sec_double) >= (target_time! * 3600)) {
          pref.setDouble('intra_percent', 1.0);
        } else
          pref.setDouble(
              'intra_percent', (intra_sec_double) / (target_time! * 3600));
        intra_percent = pref.getDouble('intra_percent');
        pref.setString('time', intra_time!);
      });
      debugPrint('Request succeeded!');
    } else {
      debugPrint('Request failed with status: ${response.statusCode}.');
    }
  }

  Future<void> _get_user() async {
    final pref = await SharedPreferences.getInstance();
    token = pref.getString('token');
    final response = await http.get(
      Uri.parse(base_url + 'user/?token=$token'),
    );
    if (response.statusCode == 200) {
      setState(() {
        pref.setInt('avatar', jsonDecode(response.body)['avatar']);
        pref.setInt('pet', jsonDecode(response.body)['pet']);
        pref.setInt('target_time', jsonDecode(response.body)['target_time']);
        avatar = pref.getInt('avatar');
        pet = pref.getInt('pet');
        target_time = pref.getInt('target_time');
      });
      debugPrint('Request succeeded!');
    } else {
      debugPrint('Request failed with status: ${response.statusCode}.');
    }
  }

  static void removeData() async {
    final pref = await SharedPreferences.getInstance();
    pref.remove('token');
    pref.remove('login');
  }

  @override
  Widget build(BuildContext context) {
    // 기기의 상태 정보 확인
    final Size screenSize = MediaQuery.of(context).size;
    final double width = screenSize.width;
    final double height = screenSize.height;

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            InkWell(
              onTap: () {
                _get_time();
                _get_user();
              },
              child: Image.asset('assets/images/logo.png'),
            ),
            ElevatedButton(
              onPressed: () {
                showMaterialNumberPicker(
                    context: context,
                    minNumber: 1,
                    maxNumber: 24,
                    title: '목표 시간 설정',
                    selectedNumber: target_time ?? 1,
                    onChanged: (value) => setState(() {
                          target_time = value;
                          _updateUser(login!, target_time!, avatar!, pet!);
                        }));
              },
              style: ElevatedButton.styleFrom(
                textStyle: TextStyle(
                  fontSize: 60,
                  fontFamily: 'dosgothic',
                ),
                elevation: 0,
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.black,
              ),
              child: Text(intra_time ?? '0'),
            ),
            SizedBox(height: height * 0.01),
            LinearPercentIndicator(
              padding: EdgeInsets.only(left: width * 0.2, right: width * 0.2),
              backgroundColor: Colors.grey,
              progressColor: Colors.black,
              percent: intra_percent ?? 1,
              lineHeight: 15,
            ),
            SizedBox(height: height * 0.03),
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      Image.asset(
                        'assets/images/bear.png',
                        width: width * 0.6,
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      SizedBox(height: height * 0.2),
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/images/borntoberoot.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: height * 0.02),
            Text(
              login ?? 'anonymous',
              style: TextStyle(
                  fontSize: 20,
                  fontFamily: 'futura',
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(height: height * 0.05),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) =>
                          get_help_dialog(context),
                    );
                  },
                  child: Image.asset('assets/images/help.png'),
                ),
                SizedBox(width: width * 0.1),
                InkWell(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) =>
                          get_help_dialog(context),
                    );
                  },
                  child: Image.asset('assets/images/achievements.png'),
                ),
                SizedBox(width: width * 0.1),
                InkWell(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) =>
                          get_setting_dialog(context),
                    );
                  },
                  child: Image.asset('assets/images/setting.png'),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget get_help_dialog(BuildContext context) {
    return AlertDialog(
      title: const Text('Help🐻‍❄️'),
      backgroundColor: Colors.black,
      titleTextStyle:
          TextStyle(color: Colors.white, fontSize: 25, fontFamily: 'futura'),
      contentTextStyle: TextStyle(
          color: Colors.white,
          fontFamily: 'dosgothic',
          fontWeight: FontWeight.bold),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
              '여러분들의 폴라ㅂ... 아니 곰을 키워보세요!\n42bear는 여러분들의 인트라 접속 시간에 따라 곰을 성장시킬 수 있습니다.\n곰을 키우면서 여러분들의 인트라 접속 시간을 늘려보세요!\n\n다양한 어플 내 업적을 통해 곰의 아바타를 변경할 수 있습니다.\n또한 본인의 과제 업적에 따라 원하는 펫을 장착할 수 있습니다.'),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget get_setting_dialog(BuildContext context) {
    return AlertDialog(
      title: const Text('Setting🐻‍❄️'),
      backgroundColor: Colors.black,
      titleTextStyle:
          TextStyle(color: Colors.white, fontSize: 25, fontFamily: 'futura'),
      contentTextStyle: TextStyle(
          color: Colors.white,
          fontFamily: 'dosgothic',
          fontWeight: FontWeight.bold),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text('42bear v1 2023\n다음 업데이트를 기대해주세요!\n에러 문의는 ... [더보기]\n'),
          TextButton(
            onPressed: () {
              removeData();
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => FirstScreen()));
            },
            style: TextButton.styleFrom(backgroundColor: Colors.white),
            // ignore: prefer_const_constructors
            child: Text('Logout', style: TextStyle(color: Colors.black)),
          ),
          Text('\n제작 : junkpark, hujeong, subcho'),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Close'),
        ),
      ],
    );
  }
}
