import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; //ローカルストレージ
import 'package:dio/dio.dart'; //HTTPクライアント ( 標準httpクライアントだとhttpヘッダをカスタマイズできないためdioを使用 )
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'package:intl/intl.dart';

class Session {
  //サーバ基本情報
  static Map<String, dynamic> info = {
    // 'protocol': 'https',
    'protocol': 'http',
    // 'domain': 'local.rna.co.jp',
    'domain': '192.168.1.199',
    // 'directory': 'flutter',
    'directory': '',
    'api': {
      'session': 'session.php',
      'login': 'login.php',
      'logout': 'logout.php'
    },
    'sessionName': 'fltappid',
    'sessionLimit': 6, //limit hours if not remember and no access
    'userAgent': 'sample-app',
    'header': {
      'Client-Version': '0.001a',
      'Client-Uuid': 'f9e894ba-7451-42ed-8106-32127bdc5e76',
    }
  };

  //設定値返却
  Map<String, dynamic> getInfo() {
    return info;
  }

  //"<protocol>://<domain>" 部分のみ文字列で取得
  String getBaseHost() {
    return info['protocol'] + '://' + info['domain'];
  }

  //プラットフォーム特定
  String detectPlatform() {
    if (kIsWeb) {
      return 'WEB';
    } else if (Platform.isAndroid) {
      return 'Android';
    } else if (Platform.isIOS) {
      return 'iOS';
    } else if (Platform.isLinux) {
      return 'Linux';
    } else if (Platform.isMacOS) {
      return 'macOS';
    } else if (Platform.isWindows) {
      return 'Windows';
    } else if (Platform.isFuchsia) {
      return 'Fuchsia';
    } else {
      return 'UNKNOWN';
    }
  }

  //ベースURL
  String getBaseUrl() {
    return '${info['protocol']}://${info['domain']}/${info['directory']}${(info['directory'].toString() == '') ? '' : '/'}';
  }

  //セッション関連URL
  String getSessionUrl() {
    return '${getBaseUrl()}${info['api']['session']}';
  }

  //ログインURL
  String getLoginUrl() {
    return '${getBaseUrl()}${info['api']['login']}';
  }

  //ログアウトURL
  String getLogoutUrl() {
    return '${getBaseUrl()}${info['api']['logout']}';
  }

  //セッション期限日時文字列取得 "YYYY-MM-DD hh:mm:ss"
  String getLimit() {
    var datetime = DateTime.now();
    var datetimeAdd = datetime.add(Duration(hours: info['sessionLimit']));
    final formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    return formatter.format(datetimeAdd);
  }

  //リクエストヘッダを付与した dio オブジェクトを返却
  Future<Dio> getDio([bool? isLogin = false]) async {
    final prefs = await SharedPreferences.getInstance();
    isLogin ??= false;
    var dio = Dio();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          options.headers['Client-Version'] =
              info['header']['Client-Version'].toString();
          options.headers['Client-Uuid'] =
              info['header']['Client-Uuid'].toString();
          options.headers['Client-Platform'] = detectPlatform();
          if (isLogin == false) {
            options.headers['Client-Session'] =
                prefs.getString(info['sessionName'].toString()) ?? '';
          }
          if (!kIsWeb) {
            //WEBアプリはUser-Agent変更非対応
            options.headers['User-Agent'] = info['userAgent'];
          }
          return handler.next(options);
        },
      ),
    );
    return dio;
  }

  //ローカルストレージからセッションID取得
  Future<String> getSessionId() async {
    final prefs = await SharedPreferences.getInstance();
    String name = info['sessionName'].toString();
    if (prefs.getString(name) == null) {
      prefs.setString(name, '');
    }
    String expire = '';
    String sessionId = prefs.getString(name) ?? '';
    if (sessionId != '') {
      if (prefs.getString('sessionLimit') == null) {
        prefs.setString(name, '');
        sessionId = '';
      } else {
        expire = prefs.getString('sessionLimit') as String;
        final formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
        String nowDT = formatter.format(DateTime.now());
        if (DateTime.parse(nowDT).isBefore(DateTime.parse(expire))) {
          //Not expired
        } else {
          //Expired
          prefs.setString(name, '');
          prefs.setString('sessionLimit', '');
          sessionId = '';
        }
      }
    }
    return sessionId;
  }

  //サーバ上のセッションをチェック
  Future<dynamic> checkSession(String mode) async {
    if ((mode != 'check') && (mode != 'update')) {
      mode = 'check';
    }
    String url = getSessionUrl();
    final dio = await getDio();
    dynamic response = {'statusCode': 0, 'data': {}, 'errMsg': ''}; //戻り値デフォルト値
    Response pre; //dio戻り値
    try {
      pre = await dio.post(url);
      response['statusCode'] = pre.statusCode;
      response['data'] = pre.data;
      if (response['statusCode'] == 200) {
        if (mode == 'update') {
          if (response['data']['hasSession']) {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            if (prefs.getString('sessionLimit') != null) {
              String limitStr = prefs.getString('sessionLimit') as String;
              if (limitStr != 'forever') {
                String expire = getLimit();
                prefs.setString('sessionLimit', expire);
              }
            }
          }
        } else if (mode == 'check') {
          if (!response['data']['hasSession']) {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.setString(info['sessionName'].toString(), '');
            prefs.setString('sessionLimit', '');
          }
        }
      }
    } on DioException catch (e) {
      if (e.response != null) {
        response['statusCode'] = e.response?.statusCode;
        response['data'] = e.response?.data;
        response['errMsg'] = e.message;
        debugPrint('HTTP error ( with response )');
        debugPrint(e.message);
      } else {
        response['statusCode'] = 404; //404とは限らないがCORS制限により概ね同等
        response['errMsg'] = e.message;
        debugPrint('HTTP error ( no response )');
        debugPrint(e.message);
      }
    }
    return response;
  }

  //ログイン
  Future<dynamic> login(String account, String password, bool remember) async {
    String url = getLoginUrl();
    final dio = await getDio(true);
    dynamic response = {'statusCode': 0, 'data': {}, 'errMsg': ''}; //戻り値デフォルト値
    Response pre; //dio戻り値
    try {
      pre = await dio.post(url, data: {
        'account': account,
        'password': password,
        'remember': remember
      });
      response['statusCode'] = pre.statusCode;
      response['data'] = pre.data;
      if (response['statusCode'] == 200) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString(info['sessionName'].toString(),
            response['data']['sessionId'].toString());
        String expire = '';
        if (remember) {
          expire = 'forever';
        } else {
          expire = getLimit();
        }
        prefs.setString('sessionLimit', expire);
      }
    } on DioException catch (e) {
      if (e.response != null) {
        response['statusCode'] = e.response?.statusCode as int;
        response['data'] = e.response?.data;
        response['errMsg'] = e.message;
        debugPrint('HTTP error ( with response )');
        debugPrint(e.message);
      } else {
        response['statusCode'] = 404; //404とは限らないがCORS制限により概ね同等
        response['errMsg'] = e.message;
        debugPrint('HTTP error ( no response )');
        debugPrint(e.message);
      }
    }
    return response;
  }

  //ログアウト
  Future<void> logout() async {
    String url = getLogoutUrl();
    final dio = await getDio();
    try {
      await dio.post(url);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString(info['sessionName'].toString(), '');
    } on DioException catch (e) {
      //ログアウトはエラーを無視する
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString(info['sessionName'].toString(), '');
      if (e.response != null) {
        debugPrint('HTTP error ( with response )');
        debugPrint(e.message);
      } else {
        debugPrint('HTTP error ( no response )');
        debugPrint(e.message);
      }
    }
  }
}

//アプリリロード
class RestartWidget extends StatefulWidget {
  // ignore: prefer_const_constructors_in_immutables, use_key_in_widget_constructors
  RestartWidget({required this.child});

  final Widget child;

  static void restartApp(BuildContext context) {
    context.findAncestorStateOfType<_RestartWidgetState>()?.restartApp();
  }

  @override
  // ignore: library_private_types_in_public_api
  _RestartWidgetState createState() => _RestartWidgetState();
}

class _RestartWidgetState extends State<RestartWidget> {
  Key key = UniqueKey();

  void restartApp() {
    setState(() {
      key = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: key,
      child: widget.child,
    );
  }
}
