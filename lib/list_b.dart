import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import './system/common.dart';

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

class PaginatedDataTableView extends StatefulWidget {
  const PaginatedDataTableView({super.key});

  @override
  State<PaginatedDataTableView> createState() => _PaginatedDataTableViewState();
}

class _PaginatedDataTableViewState extends State<PaginatedDataTableView> {
  int _currentPage = 0;
  int _pageSize = 10;
  // ignore: prefer_final_fields
  List<DataModel> _data = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    setState(() {
      _isLoading = true;
    });
    var session = Session();
    try {
      final dio = await session.getDio();
      var req = '${session.getBaseUrl()}/list.php';
      var response =
          await dio.post(req, data: {"page": _currentPage.toString()});
      if (response.statusCode == 200) {
        final dataList = response.data['list'] as List<dynamic>;
        final List<DataModel> newData =
            dataList.map((item) => DataModel.fromJson(item)).toList();

        setState(() {
          _data.addAll(newData);
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        throw Exception('Failed to fetch data');
      }
    } on DioException catch (e) {
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
                  header: const Text(
                      '表示後はHTTP通信せず配列にあるものを表示するだけのサンプル。詳細画面への遷移なし(このUIでは煩雑になる)'),
                  rowsPerPage: _pageSize,
                  availableRowsPerPage: const [10, 25, 50],
                  onRowsPerPageChanged: (value) {
                    setState(() {
                      _pageSize = value!;
                    });
                  },
                  columns: const [
                    DataColumn(label: Text('郵便番号')),
                    DataColumn(label: Text('住所 1')),
                    DataColumn(label: Text('住所 2')),
                    DataColumn(label: Text('住所 3')),
                  ],
                  source: _DataSource(data: _data, context: context),
                ),
              ),
            ),
    );
  }
}

class _DataSource extends DataTableSource {
  final List<DataModel> data;
  final dynamic context;

  _DataSource({required this.data, required this.context});

  @override
  DataRow? getRow(int index) {
    if (index >= data.length) {
      return null;
    }

    final item = data[index];

    return DataRow(cells: [
      DataCell(Text('${item.zip7.substring(0, 3)}-${item.zip7.substring(3)}')),
      DataCell(Text(item.addr1)),
      DataCell(Text(item.addr2)),
      DataCell(Text(item.addr3)),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => data.length;

  @override
  int get selectedRowCount => 0;
}
