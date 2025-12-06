import 'package:consig_now_app/models/sale.dart';
import 'package:consig_now_app/services/sale_service.dart';
import 'package:consig_now_app/widgets/generic_table.dart';
import 'package:consig_now_app/widgets/table_header.dart';
import 'package:consig_now_app/widgets/info_bar.dart';
import 'package:consig_now_app/widgets/table_container.dart';
import 'package:consig_now_app/widgets/ui_helpers.dart';
import 'package:flutter/material.dart';
import 'package:consig_now_app/screens/sales_edit_screen.dart';
import 'package:consig_now_app/screens/sales_item_screen.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../colors/minhas_cores.dart';
import 'login_screen.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  final SaleService _service = SaleService();
  late Future<List<Sale>> _salesFuture;
  Key _tableKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    _refreshSales();
  }

  void _refreshSales() {
    setState(() {
      _salesFuture = _service.listSales();
      _tableKey = UniqueKey();
    });
  }

  Future<void> _deleteSale(Sale sale) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text('Deseja realmente excluir a venda #${sale.id}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _service.deleteSale(sale.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Venda excluída com sucesso')),
          );
          _refreshSales();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Erro ao excluir: $e')));
        }
      }
    }
  }

  Future<void> _editSale(Sale sale) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SalesEditScreen(sale: sale)),
    );

    if (result == true) {
      _refreshSales();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('assets/logo.png', height: 32),
            const SizedBox(width: 8),
            const Text('Vendas Realizadas'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final auth = Provider.of<AuthProvider>(context, listen: false);
              await auth.logout();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [MinhasCores.verdeTopo, MinhasCores.verdeBaixo],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: FutureBuilder<List<Sale>>(
          future: _salesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Erro: ${snapshot.error}'));
            }

            final salesList = snapshot.data ?? [];
            final totalSales = salesList.length;
            final totalValue = salesList.fold<double>(
              0,
              (sum, s) => sum + (s.valorTotal ?? 0),
            );

            return SizedBox.expand(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TableContainer(
                  header: const TableHeader(
                    title: 'Histórico de Vendas',
                    subtitle: 'Gerencie as vendas realizadas',
                    icon: Icons.point_of_sale,
                  ),
                  infoBar: InfoBar(
                    icon: Icons.attach_money,
                    iconColor: Colors.green.shade700,
                    mainText: '$totalSales vendas registradas',
                    backgroundColor: Colors.green.shade50,
                    borderColor: Colors.green.shade100,
                    chips: [
                      UiHelpers.buildSummaryChip(
                        'Total: R\$ ${totalValue.toStringAsFixed(2)}',
                        Colors.green,
                      ),
                    ],
                  ),
                  table: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: GenericTable<Sale>(
                      key: _tableKey,
                      data: salesList,
                      columns: const [
                        DataColumn(label: Text('ID')),
                        DataColumn(label: Text('Data')),
                        DataColumn(label: Text('Representante')),
                        DataColumn(label: Text('Valor Total')),
                        DataColumn(label: Text('Pagamento')),
                        DataColumn(label: Text('Status')),
                        DataColumn(label: Text('Ações')),
                      ],
                      rowBuilder: (sale, index) {
                        final isEven = index % 2 == 0;
                        return DataRow(
                          color: MaterialStateProperty.resolveWith<Color?>((
                            states,
                          ) {
                            if (states.contains(MaterialState.hovered)) {
                              return Colors.green.shade50;
                            }
                            return isEven ? Colors.white : Colors.grey.shade50;
                          }),
                          cells: [
                            DataCell(
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          SalesItemScreen(sale: sale),
                                    ),
                                  );
                                },
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '#${sale.id}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue.shade900,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            DataCell(Text(sale.dataVenda ?? '-')),
                            DataCell(
                              Text(sale.representante?.user?.name ?? '-'),
                            ),
                            DataCell(
                              Text(
                                'R\$ ${sale.valorTotal?.toStringAsFixed(2) ?? '0.00'}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ),
                            DataCell(Text(sale.formaPagamento ?? '-')),
                            DataCell(
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: sale.status == 'finalizada'
                                      ? Colors.green.shade100
                                      : Colors.orange.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  sale.status ?? '-',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: sale.status == 'finalizada'
                                        ? Colors.green.shade800
                                        : Colors.orange.shade800,
                                  ),
                                ),
                              ),
                            ),
                            DataCell(
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit_outlined,
                                      size: 20,
                                    ),
                                    color: Colors.blue.shade600,
                                    onPressed: () => _editSale(sale),
                                    tooltip: 'Editar Pagamento',
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      size: 20,
                                    ),
                                    onPressed: () => _deleteSale(sale),
                                    color: Colors.red.shade600,
                                    tooltip: 'Excluir Venda',
                                  ),
                                ],
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
