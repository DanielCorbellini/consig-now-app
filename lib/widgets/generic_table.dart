import 'package:flutter/material.dart';

class GenericTable<T> extends StatelessWidget {
  final List<T> data;
  final List<DataColumn> columns;
  final DataRow Function(T item, int index) rowBuilder;

  const GenericTable({
    super.key,
    required this.data,
    required this.columns,
    required this.rowBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: columns,
          rows: data
              .asMap()
              .entries
              .map((entry) => rowBuilder(entry.value, entry.key))
              .toList(),
        ),
      ),
    );
  }
}
