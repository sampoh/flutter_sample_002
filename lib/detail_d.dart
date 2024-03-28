import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import './system/common.dart';

const commonPadding = EdgeInsets.all(16.0);
const rightPadding00 = EdgeInsets.fromLTRB(0, 0, 0, 0);
const rightPadding08 = EdgeInsets.fromLTRB(0, 0, 8, 0);
const rightPadding12 = EdgeInsets.fromLTRB(0, 0, 12, 0);
const rightPadding16 = EdgeInsets.fromLTRB(0, 0, 16, 0);
const rightPadding24 = EdgeInsets.fromLTRB(0, 0, 24, 0);
const rightPadding32 = EdgeInsets.fromLTRB(0, 0, 32, 0);
const rightPadding64 = EdgeInsets.fromLTRB(0, 0, 64, 0);

class MyDetailView extends StatefulWidget {
  const MyDetailView({super.key, required this.targetId});
  final int targetId;
  @override
  State<MyDetailView> createState() => _MyDetailViewState();
}

class _MyDetailViewState extends State<MyDetailView> {
  final TextEditingController _noteController = TextEditingController();
  bool _isOnline = false;
  dynamic _detail;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('郵便番号データ詳細'),
        ),
        body: _isOnline
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: SizedBox(
                    width: double.infinity,
                    child: Padding(
                        padding: commonPadding,
                        child: Column(children: [
                          const Text(' '),
                          TextField(
                              readOnly: true,
                              enabled: false,
                              controller: TextEditingController(
                                  text: widget.targetId.toString()),
                              decoration: const InputDecoration(
                                labelText: 'ID',
                                border: OutlineInputBorder(),
                              )),
                          const Text(' '),
                          TextField(
                              readOnly: true,
                              enabled: false,
                              controller: TextEditingController(
                                  text: (_detail['zip7'] != null)
                                      ? '${_detail['zip7'].toString().substring(0, 3)}-${_detail['zip7'].toString().substring(3)}'
                                      : ''),
                              decoration: const InputDecoration(
                                labelText: '郵便番号',
                                border: OutlineInputBorder(),
                              )),
                          const Text(' '),
                          TextField(
                              readOnly: true,
                              enabled: false,
                              controller: TextEditingController(
                                  text: (_detail['addr1'] != null)
                                      ? _detail['addr1']
                                      : ''),
                              decoration: const InputDecoration(
                                labelText: '都道府県',
                                border: OutlineInputBorder(),
                              )),
                          const Text(' '),
                          TextField(
                              readOnly: true,
                              enabled: false,
                              controller: TextEditingController(
                                  text: ((_detail['addr2'] != null) &&
                                          (_detail['addr3'] != null))
                                      ? _detail['addr2'] + _detail['addr3']
                                      : ''),
                              decoration: const InputDecoration(
                                labelText: '住所',
                                border: OutlineInputBorder(),
                              )),
                          const Text(' '),
                          TextField(
                              keyboardType: TextInputType.multiline,
                              maxLines: null,
                              controller: _noteController,
                              decoration: const InputDecoration(
                                labelText: 'メモ',
                                border: OutlineInputBorder(),
                              )),
                          const Text(' '),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Padding(
                                  padding: rightPadding16,
                                  child: ElevatedButton(
                                    style: TextButton.styleFrom(
                                      textStyle: const TextStyle(fontSize: 16),
                                      foregroundColor:
                                          Colors.white, // foreground
                                      backgroundColor: Colors.blue,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(5.0),
                                      ),
                                      fixedSize: const Size.fromHeight(40),
                                    ),
                                    child: const Text('SAVE',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    onPressed: () {
                                      setState(() {
                                        putData(false);
                                      });
                                    },
                                  )),
                              Padding(
                                  padding: rightPadding16,
                                  child: ElevatedButton(
                                    style: TextButton.styleFrom(
                                      textStyle: const TextStyle(fontSize: 16),
                                      foregroundColor:
                                          Colors.white, // foreground
                                      backgroundColor: Colors.blue,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(5.0),
                                      ),
                                      fixedSize: const Size.fromHeight(40),
                                    ),
                                    child: const Text('SAVE and CLOSE',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    onPressed: () {
                                      setState(() {
                                        putData(true);
                                      });
                                    },
                                  )),
                              Padding(
                                  padding: rightPadding00,
                                  child: ElevatedButton(
                                    style: TextButton.styleFrom(
                                      textStyle: const TextStyle(fontSize: 16),
                                      foregroundColor: const Color.fromARGB(
                                          255, 0, 0, 0), // foreground
                                      backgroundColor: const Color.fromARGB(
                                          255, 210, 210, 210),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(5.0),
                                      ),
                                      fixedSize: const Size.fromHeight(40),
                                    ),
                                    child: const Text('CLOSE',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    onPressed: () {
                                      setState(() {
                                        Navigator.pop(context, 'close');
                                      });
                                    },
                                  )),
                            ],
                          ),
                        ])))));
  }

  @override
  void initState() {
    super.initState();
    fetchData();
    _noteController.addListener(_handleTextChanged);
  }

  Future<void> fetchData() async {
    setState(() {
      _isOnline = true;
    });
    var session = Session();
    try {
      final dio = await session.getDio();
      var req = '${session.getBaseHost()}/detail.php';
      var response = await dio.post(req, data: {
        "id": widget.targetId,
      });
      if (response.statusCode == 200) {
        setState(() {
          _detail = response.data['detail'];
          _noteController.text =
              (_detail['note'] != null) ? _detail['note'].toString() : '';
          _isOnline = false;
        });
      } else {
        setState(() {
          _isOnline = false;
        });
        throw Exception('Failed to fetch data');
      }
    } on DioException catch (e) {
      setState(() {
        _isOnline = false;
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

  Future<void> putData(bool close) async {
    setState(() {
      _isOnline = true;
    });
    var session = Session();
    try {
      final dio = await session.getDio();
      var req = '${session.getBaseHost()}/detailsave.php';
      var response = await dio.post(req,
          data: {"id": widget.targetId, "note": _noteController.text});
      if (response.statusCode == 200) {
        setState(() {
          _isOnline = false;
          if (close) {
            Navigator.pop(context, 'save');
          }
        });
      } else {
        setState(() {
          _isOnline = false;
        });
        throw Exception('Failed to put data');
      }
    } on DioException catch (e) {
      setState(() {
        _isOnline = false;
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

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _handleTextChanged() {
    setState(() {});
  }
}
