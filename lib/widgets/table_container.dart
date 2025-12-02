import 'package:flutter/material.dart';

/// Widget reutilizável que envolve tabelas com estilo consistente
class TableContainer extends StatelessWidget {
  final Widget header;
  final Widget? infoBar;
  final Widget table;

  const TableContainer({
    super.key,
    required this.header,
    this.infoBar,
    required this.table,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Column(children: [header, if (infoBar != null) infoBar!, table]),
    );
  }
}
