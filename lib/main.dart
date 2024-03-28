import 'dart:convert';
import 'package:flutter/material.dart';
import './login.dart';
import './system/common.dart';
import 'system/drawer.dart';

// void main() async {
//   runApp(const MaterialApp(home: ContentDetection()));
// }

void main() {
  runApp(
    RestartWidget(
      child: const MaterialApp(home: ContentDetection()),
    ),
  );
}

//メイン
class MainPage extends StatelessWidget {
  const MainPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('DEMO Application')),
      body: const Center(
          child: Text(
        'Welcome!',
        style: TextStyle(
          fontSize: 33,
        ),
      )),
      drawer: const MyDrawer(),
    );
  }
}

//メイン画面かログイン画面の振り分け
class ContentDetection extends StatelessWidget {
  const ContentDetection({super.key});

  Future<bool> fetchSession() async {
    var session = Session();
    dynamic response = await session.checkSession('check');
    bool hasSession = false;
    if (response['statusCode'] == 200) {
      hasSession = response['data']['hasSession'];
      debugPrint(jsonEncode(response['data']));
    }
    debugPrint('http code:${response['statusCode']}');
    return hasSession;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: fetchSession(),
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          // ignore: curly_braces_in_flow_control_structures
          return (snapshot.data as bool ? const MainPage() : const LoginPage());
        }
      },
    );
  }
}
