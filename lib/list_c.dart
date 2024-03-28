// import 'dart:developer';
import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import '../../config/config.dart';
import './system/common.dart';

class DataModel {
  final String zip7;
  final String addr;

  DataModel({
    required this.zip7,
    required this.addr,
  });

  factory DataModel.fromJson(Map<String, dynamic> json) {
    return DataModel(
      zip7: json['zip7'],
      addr: json['addr1'] + json['addr2'] + json['addr3'],
    );
  }
}

class PaginatedDataTableProblem extends StatefulWidget {
  const PaginatedDataTableProblem({super.key});

  @override
  State<PaginatedDataTableProblem> createState() =>
      _PaginatedDataTableProblemState();
}

class _PaginatedDataTableProblemState extends State<PaginatedDataTableProblem> {
  int _currentPage = 0;
  int _pageSize = 10;
  // ignore: prefer_final_fields
  List<DataModel> _data = [];
  bool _isLoading = false;
  int allRecs = 0;
  // final key = GlobalKey<PaginatedDataTableState>();

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    setState(() {
      _isLoading = true;
    });
    // ignore: avoid_print
    print('_currentPage=$_currentPage, _pageSize=$_pageSize');
    var session = Session();
    final dio = await session.getDio();
    final response = await dio.post('http://192.168.1.199/list.php', data: {
      "page": _currentPage.toString(),
      "rowsPerPage": _pageSize.toString(),
      // "rowsPerPage": "100",
      "zip": '',
      "addr": '',
    });
    // final response = await http.get(Uri.parse(
    //     '${ApiEndpoint.users}?page=$_currentPage')); //&pageSize=$_pageSize
    if (response.statusCode == 200) {
      // final jsonData = json.decode(response.body);
      // inspect(jsonData);
      // final dataList = jsonData['data']['users'] as List<dynamic>;
      final dataList = response.data['list'] as List<dynamic>;
      final List<DataModel> newData =
          dataList.map((item) => DataModel.fromJson(item)).toList();
      // ignore: avoid_print
      // print(dataList);
      // ignore: avoid_print
      print('records = ${dataList.length}');
      allRecs = response.data['recs'];
      // key.currentState?.pageTo(_currentPage);
      setState(() {
        _data.addAll(newData);
        // _data = newData;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      throw Exception('Failed to fetch data');
    }
  }

  // ignore: unused_element
  void _loadMoreData() {
    if (!_isLoading) {
      setState(() {
        _currentPage++;
      });
      fetchData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Table'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: SizedBox(
                width: double.infinity,
                child: PaginatedDataTable(
                  // key: key,
                  header:
                      const Text('このUIコンポーネントは配列前提のため都度HTTPによる遷移ではうまく動作しない'),
                  rowsPerPage: _pageSize,
                  availableRowsPerPage: const [10, 25, 50],
                  onRowsPerPageChanged: (value) {
                    setState(() {
                      _pageSize = value!;
                      // ignore: avoid_print
                      // print('_currentPage=$_currentPage, _pageSize=$_pageSize');
                      fetchData();
                    });
                  },
                  onPageChanged: (int pageIndex) {
                    setState(() {
                      _currentPage = pageIndex;
                      // ignore: avoid_print
                      // print('_currentPage=$_currentPage, _pageSize=$_pageSize');
                      fetchData();
                    });
                  },
                  columns: const [
                    DataColumn(label: Text('ZIP7')),
                    DataColumn(label: Text('ADDR')),
                  ],
                  source: _DataSource(data: _data, rowCountParam: allRecs),
                ),
              ),
            ),
    );
  }
}

class _DataSource extends DataTableSource {
  final List<DataModel> data;
  final int rowCountParam;

  _DataSource({required this.data, this.rowCountParam = -1});

  // @override
  // DataRow? getRow(int index) {
  //   if (index >= data.length) {
  //     return null;
  //   }

  //   final item = data[index];

  //   return DataRow(cells: [
  //     DataCell(Text(item.zip7)),
  //     DataCell(Text(item.addr)),
  //   ]);
  // }
  @override
  DataRow? getRow(int index) {
    assert(index >= 0);
    if (index >= data.length) {
      return null;
    }
    // final _Row row = _data[index];
    final item = data[index];
    return DataRow.byIndex(
      index: index,
      cells: <DataCell>[
        DataCell(Text(item.zip7)),
        DataCell(Text(item.addr)),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  // @override
  // int get rowCount => data.length;
  @override
  int get rowCount => rowCountParam == -1 ? data.length : rowCountParam;

  @override
  int get selectedRowCount => 0;
}
