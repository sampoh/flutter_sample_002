import 'package:flutter/material.dart';
import './main.dart';
import './system/common.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isObscure = true;
  bool _isChecked = false;

  final FocusNode _focusNode = FocusNode();

  final TextEditingController _accountController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _login() async {
    if (_accountController.text == '' || _passwordController.text == '') {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account and password are required.')),
      );
    } else {
      var session = Session();
      dynamic response = await session.login(
          _accountController.text, _passwordController.text, _isChecked);
      if (response['statusCode'] == 200) {
        if (response['data']['success'] &&
            (response['data']['sessionId'] != null)) {
          // ignore: use_build_context_synchronously
          Navigator.pushReplacement(
            // ignore: use_build_context_synchronously
            context,
            MaterialPageRoute(builder: (context) => const MainPage()),
          );
        } else {
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Login failed.')),
          );
        }
      } else {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'An error occurred. Http code is ${response['errMsg']}.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Login'),
          backgroundColor: Colors.blue,
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const SizedBox(height: 10),
                  Center(
                      child: SizedBox(
                    width: 480,
                    height: 76,
                    child: TextFormField(
                        controller: _accountController,
                        focusNode: _focusNode,
                        decoration: const InputDecoration(
                          labelText: 'Account',
                        ),
                        onFieldSubmitted: (String? value) {
                          _login();
                        }),
                  )),
                  Center(
                      child: SizedBox(
                    width: 480,
                    height: 76,
                    child: TextFormField(
                        controller: _passwordController,
                        obscureText: _isObscure,
                        decoration: InputDecoration(
                            labelText: 'Password',
                            suffixIcon: IconButton(
                                icon: Icon(_isObscure
                                    ? Icons.visibility_off
                                    : Icons.visibility),
                                onPressed: () {
                                  setState(() {
                                    _isObscure = !_isObscure;
                                  });
                                })),
                        onFieldSubmitted: (String? value) {
                          _login();
                        }),
                  )),
                  const SizedBox(height: 10),
                  Center(
                      child: SizedBox(
                          // height: 200,
                          width: (!kIsWeb &&
                                  (Platform.isAndroid || Platform.isIOS))
                              ? 200
                              : 170,
                          child: CheckboxListTile(
                            title: const Text("Remember"),
                            activeColor: Colors.blue,
                            checkColor: Colors.white,
                            value: _isChecked,
                            onChanged: (newValue) {
                              setState(() {
                                _isChecked = newValue!;
                              });
                            },
                            controlAffinity: ListTileControlAffinity
                                .leading, //  <-- leading Checkbox
                          ))),
                  const SizedBox(height: 24),
                  Center(
                    child: ElevatedButton(
                      onPressed: _login,
                      style: TextButton.styleFrom(
                        textStyle: const TextStyle(fontSize: 20),
                        foregroundColor: Colors.white, // foreground
                        backgroundColor: Colors.blue,
                        fixedSize: const Size(160, 56),
                        // alignment: Alignment.topCenter,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: const Text('LOGIN'),
                    ),
                  ),
                  //↓デモ版なので登録ボタンを隠す
                  // const SizedBox(height: 24),
                  // Center(
                  //   child: ElevatedButton(
                  //     onPressed: () {
                  //       debugPrint('TESTING');
                  //     },
                  //     style: TextButton.styleFrom(
                  //       textStyle: const TextStyle(fontSize: 20),
                  //       foregroundColor: Colors.white, // foreground
                  //       backgroundColor: Colors.blue,
                  //       fixedSize: const Size(160, 56),
                  //       // alignment: Alignment.topCenter,
                  //       shape: RoundedRectangleBorder(
                  //         borderRadius: BorderRadius.circular(10.0),
                  //       ),
                  //     ),
                  //     child: const Text('Register'),
                  //   ),
                  // ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ));
  }

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }
}
