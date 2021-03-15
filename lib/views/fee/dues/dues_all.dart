import 'package:flutter/material.dart';

class ModelAllDues {

  final String stuClass;
  final String stuSection;
  final String stuName;
  final String fee;
  final String transport;
  final String total;

  ModelAllDues(this.stuClass, this.stuSection, this.stuName, this.fee,
      this.transport, this.total);

}

class DessertDataSource extends DataTableSource {
  final List<ModelAllDues> _desserts = <ModelAllDues>[
    ModelAllDues("1st", "A", "Aadarsh Kumar", "345", "5435", "43243"),
    ModelAllDues("1st", "A", "Aadarsh Kumar", "345", "5435", "43243"),
    ModelAllDues("1st", "A", "Aadarsh Kumar", "345", "5435", "43243"),
    ModelAllDues("1st", "A", "Aadarsh Kumar", "345", "5435", "43243"),
    ModelAllDues("1st", "A", "Aadarsh Kumar", "345", "5435", "43243"),
    ModelAllDues("1st", "A", "Aadarsh Kumar", "345", "5435", "43243"),
    ModelAllDues("1st", "A", "Aadarsh Kumar", "345", "5435", "43243"),
    ModelAllDues("1st", "A", "Aadarsh Kumar", "345", "5435", "43243"),
    ModelAllDues("1st", "A", "Aadarsh Kumar", "345", "5435", "43243"),
    ModelAllDues("1st", "A", "Aadarsh Kumar", "345", "5435", "43243"),
    ModelAllDues("1st", "A", "Aadarsh Kumar", "345", "5435", "43243"),
    ModelAllDues("1st", "A", "Aadarsh Kumar", "345", "5435", "43243"),
    ModelAllDues("1st", "A", "Aadarsh Kumar", "345", "5435", "43243"),
    ModelAllDues("1st", "A", "Aadarsh Kumar", "345", "5435", "43243"),
    ModelAllDues("1st", "A", "Aadarsh Kumar", "345", "5435", "43243"),
    ModelAllDues("1st", "A", "Aadarsh Kumar", "345", "5435", "43243"),
    ModelAllDues("1st", "A", "Aadarsh Kumar", "345", "5435", "43243"),
    ModelAllDues("1st", "A", "Aadarsh Kumar", "345", "5435", "43243"),
    ModelAllDues("1st", "A", "Aadarsh Kumar", "345", "5435", "43243"),
    ModelAllDues("1st", "A", "Aadarsh Kumar", "345", "5435", "43243")
  ];


  int _selectedCount = 0;

  @override
  DataRow getRow(int index) {
    assert(index >= 0);
    if (index >= _desserts.length) return null;
    final ModelAllDues dessert = _desserts[index];
    return DataRow.byIndex(
      index: index,
      cells: <DataCell>[
        DataCell(Text('${dessert.stuClass}'),),
        DataCell(Text('${dessert.stuSection}')),
        DataCell(Text('${dessert.stuName}')),
        DataCell(Text('${dessert.fee}')),
        DataCell(Text('${dessert.transport}')),
        DataCell(Text('${dessert.total}')),
      ],
    );
  }

  @override
  int get rowCount => _desserts.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => _selectedCount;
}

class DuesAll extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return StateDuesAll();
  }
}

class StateDuesAll extends State<DuesAll> {
  DateTime dateFrom = DateTime.now();
  DateTime dateTo = DateTime.now();
  int _rowsPerPage = 20;
  final DessertDataSource _dessertsDataSource = DessertDataSource();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade200,
      child: SingleChildScrollView(
        child: PaginatedDataTable(
          header: const Text('Dues'),
          rowsPerPage: _rowsPerPage,
          onRowsPerPageChanged: (int value) {
            setState(() {
              _rowsPerPage = value;
            });
          },
          columns: <DataColumn>[
            DataColumn(
              label: const Text('Class'),
            ),
            DataColumn(
              label: const Text('Section'),
            ),
            DataColumn(
              label: const Text('Student'),
            ),
            DataColumn(
              label: const Text('Fee'),
            ),
            DataColumn(
              label: const Text('Transport'),
            ),
            DataColumn(
              label: const Text('Total'),
            ),
          ],
          source: _dessertsDataSource,
        ),
      ),
    );
  }
}
