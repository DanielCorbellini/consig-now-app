import 'package:flutter/material.dart';
import '../models/conditional.dart';
import '../models/conditional_item.dart';
import '../services/conditional_item_service.dart';
import '../widgets/generic_table.dart';

class ConditionalItemScreen extends StatelessWidget {
  final Conditional conditional;

  const ConditionalItemScreen({super.key, required this.conditional});

  Future<List<ConditionalItem>> _fetchItems() async {
    final service = ConditionalItemService();
    return await service.listItemConditional(conditional.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Itens da Condicional #${conditional.id}')),
      body: FutureBuilder<List<ConditionalItem>>(
        future: _fetchItems(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Nenhum item encontrado.'));
          }

          final items = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  // Header da tabela
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.green.shade600, Colors.green.shade400],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.shopping_basket_outlined,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Itens do Condicional',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Produtos entregues e devoluções',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Info bar com totais
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      border: Border(
                        bottom: BorderSide(color: Colors.blue.shade100),
                      ),
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 18,
                            color: Colors.blue.shade700,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${items.length} itens registrados',
                            style: TextStyle(
                              color: Colors.blue.shade900,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(width: 16),
                          _buildSummaryChip(
                            'Entregue: ${items.fold<int>(0, (sum, item) => sum + item.quantidadeEntregue)}',
                            Colors.orange,
                          ),
                          const SizedBox(width: 8),
                          _buildSummaryChip(
                            'Devolvido: ${items.fold<int>(0, (sum, item) => sum + item.quantidadeDevolvida)}',
                            Colors.purple,
                          ),
                          const SizedBox(width: 8),
                          _buildSummaryChip(
                            'Vendido: ${items.fold<int>(0, (sum, item) => sum + item.quantidadeVendida)}',
                            Colors.green,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Tabela
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: GenericTable<ConditionalItem>(
                      data: items,
                      columns: const [
                        DataColumn(
                          label: Text(
                            'ID',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Código',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Produto',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Entregue',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                          numeric: true,
                        ),
                        DataColumn(
                          label: Text(
                            'Devolvido',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                          numeric: true,
                        ),
                        DataColumn(
                          label: Text(
                            'Vendido',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                          numeric: true,
                        ),
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
                            DataCell(
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '#${item.id}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.blue.shade900,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                            DataCell(
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  item.produtoId.toString(),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade700,
                                    fontFamily: 'monospace',
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            DataCell(
                              Row(
                                children: [
                                  Icon(
                                    Icons.label_outline,
                                    size: 16,
                                    color: Colors.grey.shade600,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    item.produtoDescricao,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            DataCell(
                              _buildQuantityBadge(
                                item.quantidadeEntregue,
                                Colors.orange,
                                Icons.output_outlined,
                              ),
                            ),
                            DataCell(
                              _buildQuantityBadge(
                                item.quantidadeDevolvida,
                                Colors.purple,
                                Icons.keyboard_return,
                              ),
                            ),
                            DataCell(
                              _buildQuantityBadge(
                                item.quantidadeVendida,
                                Colors.green,
                                Icons.shopping_cart_outlined,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildQuantityBadge(int quantity, MaterialColor color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color.shade700),
          const SizedBox(width: 6),
          Text(
            quantity.toString(),
            style: TextStyle(
              fontSize: 14,
              color: color.shade900,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
