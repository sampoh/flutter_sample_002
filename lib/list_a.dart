import 'package:flutter/material.dart';
import './system/common.dart';
import './detail_d.dart';

class DataTableDemo extends StatefulWidget {
  const DataTableDemo({super.key});

  @override
  DataTableDemoState createState() => DataTableDemoState();
}

class DataTableDemoState extends State<DataTableDemo> {
  List<User> users = [];
  int currentPage = 0;
  int maxRecords = 0;
  var session = Session();
  bool autoScroll = false;

  final TextEditingController _zipController = TextEditingController();
  final TextEditingController _addrController = TextEditingController();

  String zipInput = '';
  String addrInput = '';
  Map<String, String> inputValue = {"zip": "", "addr": ""};

  late ScrollController _scrollController;
  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
      //※ 以下ディスカッションによると現在 ListView のスクロールパフォーマンスが低い問題を対応中とのこと
      //https://github.com/flutter/flutter/issues/52207
    }
  }

  void _search() {
    _scrollToTop(); //※ スクロールは遅いので注意
    //↓スクロールポジション更新中の影響で誤作動しないよう待機
    Future.delayed(const Duration(milliseconds: 250), () {
      inputValue['zip'] = _zipController.text;
      inputValue['addr'] = _addrController.text;
      users = [];
      currentPage = 1;
      _getMoreData(currentPage);
    });
  }

  @override
  void initState() {
    super.initState();
    _getMoreData(currentPage);
    _zipController.addListener(_handleTextChanged);
    _addrController.addListener(_handleTextChanged);
    _scrollController = ScrollController();
  }

  Future<void> _getMoreData(int page) async {
    var session = Session();
    final dio = await session.getDio();
    var req = '${session.getBaseUrl()}/list.php';
    var response = await dio.post(req, data: {
      "page": page.toString(),
      "zip": inputValue['zip'],
      "addr": inputValue['addr'],
    });
    var data = response.data['list'];
    maxRecords = response.data['recs'] as int;
    // ignore: avoid_print
    print("maxRecords = $maxRecords, page = $page");
    List<User> tempList = [];
    for (var i = 0; i < data.length; i++) {
      // tempList.add(User.fromJson(data[i]));
      // ignore: non_constant_identifier_names
      User one = User(
        id: data[i]['id'],
        zip7: data[i]['zip7'],
        addr1: data[i]['addr1'],
        addr2: data[i]['addr2'],
        addr3: data[i]['addr3'],
      );
      // ignore: avoid_print
      // print('${one.zip7},${one.addr1},${one.addr2},${one.addr3}');
      tempList.add(one);
    }
    setState(() {
      users.addAll(tempList);
      // currentPage++;
    });
  }

  var cellPadding =
      const EdgeInsets.only(top: 5.0, bottom: 5.0, left: 5.0, right: 5.0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Dynamic Pagination on Scroll'),
        ),
        body: Container(
            margin: const EdgeInsets.only(
                top: 10.0, bottom: 10.0, left: 10.0, right: 10.0),
            child: Column(children: [
              const SizedBox(
                  height: 18,
                  child: Text(
                    "※ WEBビルドでは動作が重くなりやすいので非実用的",
                    style: TextStyle(color: Color.fromARGB(255, 219, 20, 20)),
                  )),
              Container(
                margin: const EdgeInsets.only(
                    top: 0.0, bottom: 10.0, left: 0.0, right: 0.0),
                child: SizedBox(
                    height: 76,
                    child: Row(children: [
                      SizedBox(
                          width: 120,
                          child: TextField(
                            controller: _zipController,
                            // decoration: InputDecoration(
                            //   labelText: _zipController.text.isEmpty
                            //       ? '郵便番号'
                            //       : null, // ラベル
                            // ),
                            //↓labelTextを動的にすると日本語IMEが正常に動作しない不具合があるので修正
                            decoration: const InputDecoration(
                              labelText: '郵便番号', // ラベル
                            ),
                          )),
                      const SizedBox(width: 10),
                      SizedBox(
                          width: 180,
                          child: TextField(
                            controller: _addrController,
                            // decoration: InputDecoration(
                            //   labelText:
                            //       _addrController.text.isEmpty ? '住所' : null, // ラベル
                            // ),
                            //↓labelTextを動的にすると日本語IMEが正常に動作しない不具合があるので修正
                            decoration: const InputDecoration(
                              labelText: '住所', // ラベル
                            ),
                          )),
                      const SizedBox(width: 10),
                      SizedBox(
                          width: 120,
                          child: ElevatedButton(
                            onPressed: _search,
                            style: TextButton.styleFrom(
                              textStyle: const TextStyle(fontSize: 13),
                              foregroundColor: Colors.white, // foreground
                              backgroundColor: Colors.blue,
                              fixedSize: const Size(120, 42),
                              // alignment: Alignment.topCenter,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            child: const Text('検索'),
                          )),
                    ])),
              ),

              Table(border: TableBorder.all(color: Colors.black), children: [
                TableRow(
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(
                          255, 178, 209, 234), // Set your desired color here.
                    ),
                    children: [
                      TableCell(
                          child: Container(
                        color: const Color.fromARGB(255, 178, 209, 234),
                        padding: cellPadding,
                        child: const Text(' '),
                      )),
                      TableCell(
                          child: Container(
                        color: const Color.fromARGB(255, 178, 209, 234),
                        padding: cellPadding,
                        child: const Text('郵便番号'),
                      )),
                      TableCell(
                          child: Container(
                        color: const Color.fromARGB(255, 178, 209, 234),
                        padding: cellPadding,
                        child: const Text('住所 1'),
                      )),
                      TableCell(
                          child: Container(
                        color: const Color.fromARGB(255, 178, 209, 234),
                        padding: cellPadding,
                        child: const Text('住所 2'),
                      )),
                      TableCell(
                          child: Container(
                        color: const Color.fromARGB(255, 178, 209, 234),
                        padding: cellPadding,
                        child: const Text('住所 3'),
                      )),
                    ]),
              ]),
              //高さが動的な場合は Flexible または Expanded でラップしないとエラーになる
              Flexible(
                  child: ListView.builder(
                controller: _scrollController,
                itemCount: users.length,
                itemBuilder: (context, index) {
                  if (index == users.length - 1) {
                    if (users.length < maxRecords) {
                      currentPage++;
                      _getMoreData(currentPage);
                    }
                  }
                  return Table(
                      border: TableBorder.all(color: Colors.black),
                      children: [
                        TableRow(children: [
                          TableRowInkWell(
                              onTap: () {
                                _onRowEvent('onTap', users[index].id);
                              },
                              child: TableCell(
                                  child: Container(
                                padding: cellPadding,
                                child: Text('${users[index].id}'),
                              ))),
                          TableRowInkWell(
                              onTap: () {
                                _onRowEvent('onTap', users[index].id);
                              },
                              child: TableCell(
                                  child: Container(
                                padding: cellPadding,
                                child: Text(
                                    '${users[index].zip7.substring(0, 3)}-${users[index].zip7.substring(3)}'),
                              ))),
                          TableRowInkWell(
                              onTap: () {
                                _onRowEvent('onTap', users[index].id);
                              },
                              child: TableCell(
                                  child: Container(
                                padding: cellPadding,
                                child: Text(users[index].addr1),
                              ))),
                          TableRowInkWell(
                              onTap: () {
                                _onRowEvent('onTap', users[index].id);
                              },
                              child: TableCell(
                                  child: Container(
                                padding: cellPadding,
                                child: Text(users[index].addr2),
                              ))),
                          TableRowInkWell(
                              onTap: () {
                                _onRowEvent('onTap', users[index].id);
                              },
                              child: TableCell(
                                  child: Container(
                                padding: cellPadding,
                                child: Text(users[index].addr3),
                              ))),
                        ]),
                      ]);
                },
              )),
            ])));
  }

  //詳細画面への遷移および戻った際のリロード
  _onRowEvent(String event, int rowId) async {
    final mode = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return MyDetailView(targetId: rowId);
        },
      ),
    );
    if (mode == 'save') {
      _search();
    }
  }

  @override
  void dispose() {
    _zipController.dispose();
    _addrController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleTextChanged() {
    setState(() {});
  }
}

class User {
  int id;
  String zip7;
  String addr1;
  String addr2;
  String addr3;

  User({
    required this.id,
    required this.zip7,
    required this.addr1,
    required this.addr2,
    required this.addr3,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    // ignore: avoid_print
    print(json);
    return User(
      id: json['id'],
      zip7: json['zip7'],
      addr1: json['addr1'],
      addr2: json['addr2'],
      addr3: json['addr3'],
    );
  }
}
