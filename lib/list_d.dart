import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import './system/common.dart';
import './detail_d.dart';

class DataModel {
  final int id;
  final String zip7;
  final String addr1;
  final String addr2;
  final String addr3;

  DataModel({
    required this.id,
    required this.zip7,
    required this.addr1,
    required this.addr2,
    required this.addr3,
  });

  factory DataModel.fromJson(Map<String, dynamic> json) {
    return DataModel(
      id: json['id'],
      zip7: json['zip7'],
      addr1: json['addr1'],
      addr2: json['addr2'],
      addr3: json['addr3'],
    );
  }
}

class MyTableView extends StatefulWidget {
  const MyTableView({super.key});

  @override
  State<MyTableView> createState() => _MyTableViewState();
}

const commonPadding = EdgeInsets.all(12.0);
const rightPadding08 = EdgeInsets.fromLTRB(0, 0, 8, 0);
const rightPadding12 = EdgeInsets.fromLTRB(0, 0, 12, 0);
const rightPadding16 = EdgeInsets.fromLTRB(0, 0, 16, 0);
const rightPadding24 = EdgeInsets.fromLTRB(0, 0, 24, 0);
const rightPadding32 = EdgeInsets.fromLTRB(0, 0, 32, 0);
const rightPadding64 = EdgeInsets.fromLTRB(0, 0, 64, 0);
const bottomPadding08 = EdgeInsets.fromLTRB(0, 0, 0, 8);
const bottomPadding12 = EdgeInsets.fromLTRB(0, 0, 0, 12);
const bottomPadding16 = EdgeInsets.fromLTRB(0, 0, 0, 16);
const bottomPadding24 = EdgeInsets.fromLTRB(0, 0, 0, 24);
const bottomPadding32 = EdgeInsets.fromLTRB(0, 0, 0, 32);
const bottomPadding64 = EdgeInsets.fromLTRB(0, 0, 0, 64);
const topPadding08 = EdgeInsets.fromLTRB(0, 8, 0, 0);
const topPadding12 = EdgeInsets.fromLTRB(0, 12, 0, 0);
const topPadding16 = EdgeInsets.fromLTRB(0, 16, 0, 0);
const topPadding24 = EdgeInsets.fromLTRB(0, 24, 0, 0);
const topPadding32 = EdgeInsets.fromLTRB(0, 32, 0, 0);
const topPadding64 = EdgeInsets.fromLTRB(0, 64, 0, 0);
const commonDecoration =
    BoxDecoration(border: Border(bottom: BorderSide(color: Colors.black)));

class _MyTableViewState extends State<MyTableView> {
  int _currentPage = 0;
  int _recsPerPage = 10;
  final List<int> _recsPerPageOptions = [10, 20, 50, 100];
  List<DataModel> _data = [];
  bool _isLoading = false;
  int _recFrom = 0;
  int _recTo = 0;
  int _recsAll = 0;
  bool _hasPrev = false;
  bool _hasNext = false;

  final TextEditingController _zipController = TextEditingController();
  final TextEditingController _addrController = TextEditingController();

  bool _mediaQueryResult() {
    return (MediaQuery.of(context).size.width > 540);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('郵便番号リスト'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: SizedBox(
                  width: double.infinity,
                  child: Column(children: [
                    _inputContainer(),
                    Table(children: _buildTableRows()),
                    _footer(),
                  ]))),
    );
  }

  List<TableRow> _buildTableRows() {
    List<TableRow> rows = [];
    rows.add(const TableRow(decoration: commonDecoration, children: [
      Padding(
        padding: commonPadding,
        child: Text('郵便番号', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      Padding(
        padding: commonPadding,
        child: Text('住所', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    ]));
    for (var item in _data) {
      rows.add(
        TableRow(
            key: ValueKey(item.id.toString()),
            decoration: commonDecoration,
            children: [
              TableRowInkWell(
                // onDoubleTap: () {
                //   _onRowEvent('onDoubleTap', item.id);
                // },
                //↑マルチプラットフォーム及びパフォーマンス対策のためダブルタップを無効化
                onTap: () {
                  _onRowEvent('onTap', item.id);
                },
                child: Padding(
                    padding: commonPadding,
                    child: Text(
                        '${item.zip7.substring(0, 3)}-${item.zip7.substring(3)}')),
              ),
              TableRowInkWell(
                // onDoubleTap: () {
                //   _onRowEvent('onDoubleTap', item.id);
                // },
                //↑マルチプラットフォーム及びパフォーマンス対策のためダブルタップを無効化
                onTap: () {
                  _onRowEvent('onTap', item.id);
                },
                child: Padding(
                  padding: commonPadding,
                  child: Text(item.addr1 + item.addr2 + item.addr3),
                ),
              ),
            ]),
      );
    }
    return rows;
  }

  //フッタ ( メディアクエリ版 )
  Padding _footer() {
    return Padding(
        padding: commonPadding,
        child: _mediaQueryResult() ? _footerRow() : _footerCol());
  }

  //フッタ ( 横並び版 )
  Row _footerRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        const Padding(padding: rightPadding16, child: Text('表示件数')),
        Padding(
            padding: rightPadding24,
            child: DropdownButton<int>(
              value: _recsPerPage,
              items: _recsPerPageOptions.map((int value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text('$value'),
                );
              }).toList(),
              onChanged: (int? newValue) {
                setState(() {
                  _currentPage = 0;
                  _recsPerPage = newValue!;
                  fetchData();
                });
              },
            )),
        Padding(
            padding: rightPadding24,
            child: Text('$_recFrom-$_recTo of $_recsAll')),
        Padding(
            padding: rightPadding08,
            child: ElevatedButton(
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0),
                ),
              ),
              onPressed: _hasPrev
                  ? () {
                      setState(() {
                        if (_currentPage >= _recsPerPage) {
                          _currentPage = _currentPage - _recsPerPage;
                          fetchData();
                        }
                      });
                    }
                  : null,
              child: const Text('<',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            )),
        Padding(
            padding: rightPadding16,
            child: ElevatedButton(
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0),
                ),
              ),
              onPressed: _hasNext
                  ? () {
                      setState(() {
                        _currentPage = _currentPage + _recsPerPage;
                        fetchData();
                      });
                    }
                  : null,
              child: const Text('>',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            )),
      ],
    );
  }

  //フッタ ( 縦並び版 )
  Column _footerCol() {
    return Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Padding(padding: rightPadding16, child: Text('表示件数')),
        Padding(
            padding: bottomPadding08,
            child: DropdownButton<int>(
              value: _recsPerPage,
              items: _recsPerPageOptions.map((int value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text('$value'),
                );
              }).toList(),
              onChanged: (int? newValue) {
                setState(() {
                  _currentPage = 0;
                  _recsPerPage = newValue!;
                  fetchData();
                });
              },
            )),
      ]),
      Padding(
          padding: bottomPadding16,
          child: Text('$_recFrom-$_recTo of $_recsAll')),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
              padding: rightPadding16,
              child: ElevatedButton(
                style: TextButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                ),
                onPressed: _hasPrev
                    ? () {
                        setState(() {
                          if (_currentPage >= _recsPerPage) {
                            _currentPage = _currentPage - _recsPerPage;
                            fetchData();
                          }
                        });
                      }
                    : null,
                child: const Text('<',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              )),
          Padding(
              padding: rightPadding16,
              child: ElevatedButton(
                style: TextButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                ),
                onPressed: _hasNext
                    ? () {
                        setState(() {
                          _currentPage = _currentPage + _recsPerPage;
                          fetchData();
                        });
                      }
                    : null,
                child: const Text('>',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              )),
        ],
      ),
    ]);
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
      fetchData(); //保存時は一覧リロード
    }
  }

  //初期ロード及びイベント追加
  @override
  void initState() {
    super.initState();
    fetchData();
    _zipController.addListener(_handleTextChanged);
    _addrController.addListener(_handleTextChanged);
  }

  //データ取得通信処理
  Future<void> fetchData() async {
    setState(() {
      _isLoading = true;
    });
    var session = Session();
    try {
      final dio = await session.getDio();
      var req = '${session.getBaseHost()}/list.php';
      var response = await dio.post(req, data: {
        "page": _currentPage.toString(),
        "rowsPerPage": _recsPerPage.toString(),
        "zip": _zipController.text,
        "addr": _addrController.text,
      });
      if (response.statusCode == 200) {
        _recFrom = response.data['from'] as int;
        _recTo = response.data['to'] as int;
        _hasPrev = response.data['hasPrev'] as bool;
        _hasNext = response.data['hasNext'] as bool;
        _recsAll = response.data['recs'];
        final dataList = response.data['list'] as List<dynamic>;
        final List<DataModel> newData =
            dataList.map((item) => DataModel.fromJson(item)).toList();

        setState(() {
          // _data.addAll(newData);
          _data = newData;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        throw Exception('Failed to fetch data');
      }
    } on DioException catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (e.response != null) {
        debugPrint('HTTP error ( with response )');
        debugPrint(e.message);
      } else {
        debugPrint('HTTP error ( no response )');
        if (e.message == null) {
          debugPrint(e.toString());
        } else {
          debugPrint(e.message);
        }
      }
    }
  }

  //検索項目入力エリア ( メディアクエリ版 )
  Container _inputContainer() {
    return Container(
      margin: const EdgeInsets.only(
          top: 0.0, bottom: 10.0, left: 20.0, right: 20.0),
      child: SizedBox(
          height: _mediaQueryResult() ? 76 : 180,
          child: _mediaQueryResult()
              ? _inputContainerRow()
              : _inputContainerCol()),
    );
  }

  //検索項目入力エリア ( 横並び版 )
  Row _inputContainerRow() {
    return Row(children: [
      _textInputZip(),
      const SizedBox(width: 10),
      _textInputAddr(),
      const SizedBox(width: 10),
      _buttonSearch(),
    ]);
  }

  //検索項目入力エリア ( 縦並び版 )
  Column _inputContainerCol() {
    return Column(children: [
      _textInputZip(),
      _textInputAddr(),
      Padding(padding: topPadding16, child: _buttonSearch()),
    ]);
  }

  //郵便番号入力エリア
  SizedBox _textInputZip() {
    return SizedBox(
        width: _mediaQueryResult() ? 120 : MediaQuery.of(context).size.width,
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
        ));
  }

  //住所入力エリア
  SizedBox _textInputAddr() {
    return SizedBox(
        width: _mediaQueryResult() ? 180 : MediaQuery.of(context).size.width,
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
        ));
  }

  //検索ボタン
  SizedBox _buttonSearch() {
    return SizedBox(
        width: 120,
        child: ElevatedButton(
          onPressed: () {
            _currentPage = 0;
            fetchData();
          },
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
        ));
  }

  //"TextEditingController" をキャストしたら同クラス内で必ず "dispose" しておくことで、
  //ウィジェットツリーから削除されたタイミングでクリアしメモリリークを回避する
  @override
  void dispose() {
    _zipController.dispose();
    _addrController.dispose();
    super.dispose();
  }

  void _handleTextChanged() {
    setState(() {});
  }
}
