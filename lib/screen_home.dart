import 'package:flutter/material.dart';
import 'package:bear/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:percent_indicator/percent_indicator.dart';

class SecondScreen extends StatefulWidget {
  @override
  SecondScreenState createState() => SecondScreenState();
}

class SecondScreenState extends State<SecondScreen> {
  String? token = null;
  String? login = null;

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

  static void removeData() async {
    final pref = await SharedPreferences.getInstance();
    pref.remove('token');
    pref.remove('login');
  }

  @override
  Widget build(BuildContext context) {
    // 기기의 상태 정보 확인
    Size screenSize = MediaQuery.of(context).size;
    double width = screenSize.width;
    double height = screenSize.height;
    var time = '10h 42m';
    getData();

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Center(
              child: Image.asset(
                'assets/images/logo.png',
                width: width * 0.8,
              ),
            ),
            Text(time,
                style: TextStyle(
                  fontSize: 50,
                  fontFamily: 'dosgothic',
                  color: Colors.black,
                ),
                textAlign: TextAlign.center),
            SizedBox(height: height * 0.01),
            LinearPercentIndicator(
              padding: EdgeInsets.only(left: width * 0.2, right: width * 0.2),
              backgroundColor: Colors.grey,
              progressColor: Colors.black,
              percent: 0.5,
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
