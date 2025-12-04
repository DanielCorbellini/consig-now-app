import 'package:consig_now_app/widgets/ui_helpers.dart';
import 'package:flutter/material.dart';
import '../models/sale.dart';
import '../models/sale_item.dart';
import '../services/sale_service.dart';
import '../widgets/generic_table.dart';
import '../widgets/table_container.dart';
import '../widgets/table_header.dart';
import '../widgets/info_bar.dart';
import '../colors/minhas_cores.dart';

class SalesItemScreen extends StatefulWidget {
  final Sale sale;

  const SalesItemScreen({super.key, required this.sale});

  @override
  State<SalesItemScreen> createState() => _SalesItemScreenState();
}

class _SalesItemScreenState extends State<SalesItemScreen> {
  late Future<List<SaleItem>> _itemsFuture;
  final _service = SaleService();

  @override
  void initState() {
    super.initState();
    _refreshItems();
  }

  void _refreshItems() {
    setState(() {
      _itemsFuture = _service.listSaleItems(widget.sale.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Itens da Venda #${widget.sale.id}'),
        backgroundColor: MinhasCores.verdeTopo,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [MinhasCores.verdeTopo, MinhasCores.verdeBaixo],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: FutureBuilder<List<SaleItem>>(
          future: _itemsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Erro: ${snapshot.error}'));
            }

            final items = snapshot.data ?? [];
            final totalItems = items.length;
            final totalQuantity = items.fold<int>(
              0,
              (sum, item) => sum + item.quantidade,
            );
            final totalValue = items.fold<double>(
              0,
              (sum, item) => sum + (item.quantidade * item.precoUnitario),
            );

            return SizedBox.expand(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TableContainer(
                  header: const TableHeader(
                    title: 'Itens Vendidos',
                    subtitle: 'Detalhes dos produtos nesta venda',
                    icon: Icons.shopping_bag_outlined,
                  ),
                  infoBar: InfoBar(
                    icon: Icons.list_alt,
                    iconColor: Colors.blue.shade700,
                    mainText: '$totalItems itens distintos',
                    backgroundColor: Colors.blue.shade50,
                    borderColor: Colors.blue.shade100,
                    chips: [
                      UiHelpers.buildSummaryChip(
                        'Qtd Total: $totalQuantity',
                        Colors.orange,
                      ),
                      UiHelpers.buildSummaryChip(
                        'Valor Total: R\$ ${totalValue.toStringAsFixed(2)}',
                        Colors.green,
                      ),
                    ],
                  ),
                  table: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: GenericTable<SaleItem>(
                      data: items,
                      columns: const [
                        DataColumn(label: Text('ID')),
                        DataColumn(label: Text('Produto')),
                        DataColumn(label: Text('Qtd'), numeric: true),
                        DataColumn(label: Text('Preço Unit.'), numeric: true),
                        DataColumn(label: Text('Subtotal'), numeric: true),
                      ],
                      rowBuilder: (item, index) {
                        final isEven = index % 2 == 0;
                        return DataRow(
                          color: MaterialStateProperty.resolveWith<Color?>((
                            states,
                          ) {
                            if (states.contains(MaterialState.hovered)) {
                              return Colors.blue.shade50;
                            }
                            return isEven ? Colors.white : Colors.grey.shade50;
                          }),
                          cells: [
                            DataCell(Text('#${item.id}')),
                            DataCell(Text(item.produtoDescricao)),
                            DataCell(Text(item.quantidade.toString())),
                            DataCell(
                              Text(
                                'R\$ ${item.precoUnitario.toStringAsFixed(2)}',
                              ),
                            ),
                            DataCell(
                              Text(
                                'R\$ ${(item.quantidade * item.precoUnitario).toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
