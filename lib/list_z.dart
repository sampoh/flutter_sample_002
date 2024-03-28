import 'package:flutter/material.dart';
import './system/common.dart';

class DataModel {
  final String zip7;
  final String addr1;
  final String addr2;
  final String addr3;

  DataModel({
    required this.zip7,
    required this.addr1,
    required this.addr2,
    required this.addr3,
  });

  factory DataModel.fromJson(Map<String, dynamic> json) {
    return DataModel(
      zip7: json['zip7'],
      addr1: json['addr1'],
      addr2: json['addr2'],
      addr3: json['addr3'],
    );
  }
}

class MyDataTable extends StatefulWidget {
  const MyDataTable({super.key});

  @override
  MyDataTableState createState() => MyDataTableState();
}

class MyDataTableState extends State<MyDataTable> {
  int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;
  int? _sortColumnIndex;
  bool _sortAscending = true;
  int _pageIndex = 0;
  bool _isLoading = false;
  var session = Session();
  // ignore: prefer_final_fields
  List<DataModel> _data = [];

  // @override
  // void initState() {
  //   super.initState();
  //   // _fetchData();
  // }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            child: PaginatedDataTable(
            header: const Text('My DataTable'),
            rowsPerPage: _rowsPerPage,
            onRowsPerPageChanged: (value) {
              setState(() {
                _rowsPerPage = value ?? PaginatedDataTable.defaultRowsPerPage;
              });
              _fetchData();
            },
            sortColumnIndex: _sortColumnIndex,
            sortAscending: _sortAscending,
            onPageChanged: (pageIndex) {
              setState(() {
                _pageIndex = pageIndex;
              });
              _fetchData();
            },
            columns: <DataColumn>[
              DataColumn(
                label: const Text('郵便番号'),
                onSort: (columnIndex, ascending) {
                  setState(() {
                    _sortColumnIndex = columnIndex;
                    _sortAscending = ascending;
                  });
                  // Handle sorting here
                },
              ),
              const DataColumn(label: Text('住所 1')),
              const DataColumn(label: Text('住所 2')),
              const DataColumn(label: Text('住所 3')),
            ],
            source: MyDataSource(data: _data),
          ));
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
    });
    final dio = await session.getDio();
    // ignore: avoid_print
    print('page=$_pageIndex');
    var req = '${session.getBaseUrl()}/list.php';
    var response = await dio.post(req, data: {
      "page": _pageIndex.toString(),
      "rowsPerPage": _rowsPerPage.toString(),
      "zip": '',
      "addr": '',
    });
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
      throw Exception('Failed to load data');
    }
  }
}

class MyDataSource extends DataTableSource {
  final List<DataModel> data;

  MyDataSource({required this.data});

  @override
  // DataRow getRow(int index) {
  //   // Replace with your own logic
  //   return DataRow.byIndex(
  //     index: index,
  //     cells: <DataCell>[
  //       DataCell(Text('Placeholder $index')),
  //       DataCell(Text('Placeholder $index')),
  //     ],
  //   );
  // }
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
  int get rowCount => 100; // Replace with your own row count

  @override
  int get selectedRowCount => 0;
}
