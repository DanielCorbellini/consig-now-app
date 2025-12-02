import 'package:consig_now_app/widgets/generic_table.dart';
import 'package:consig_now_app/widgets/table_header.dart';
import 'package:consig_now_app/widgets/info_bar.dart';
import 'package:consig_now_app/widgets/table_container.dart';
import 'package:consig_now_app/widgets/ui_helpers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../services/product_service.dart';
import '../providers/auth_provider.dart';
import '../colors/minhas_cores.dart';
import 'login_screen.dart';

class ProductScreen extends StatelessWidget {
  const ProductScreen({super.key});

  Future<List<Product>> _fetchProducts() async {
    final service = ProductService();
    return await service.listProducts();
  }

  // Será implementado
  Future
  /**<List<Product>>*/
  _editProduct(p) async {
    return;
  }

  // Será implementado
  Future
  /**<List<Product>>*/
  _deleteProduct(p) async {
    return;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('assets/logo.png', height: 32),
            const SizedBox(width: 8),
            const Text('Saldos de Produtos'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final auth = Provider.of<AuthProvider>(context, listen: false);
              await auth.logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
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
        child: FutureBuilder<List<Product>>(
          future: _fetchProducts(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Erro: ${snapshot.error}'));
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('Nenhum produto encontrado.'));
            }

            final productList = snapshot.data!;

            // Calcular estatísticas
            final totalProducts = productList.length;
            final categories = productList
                .map((p) => p.categoria_descricao ?? 'Sem categoria')
                .toSet()
                .length;
            final totalValue = productList.fold<double>(
              0,
              (sum, p) => sum + (p.preco_venda ?? 0),
            );

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              scrollDirection: Axis.vertical,
              child: TableContainer(
                header: const TableHeader(
                  title: 'Lista de Produtos',
                  subtitle: 'Catálogo completo de produtos',
                  icon: Icons.inventory_2_outlined,
                ),
                infoBar: InfoBar(
                  icon: Icons.bar_chart,
                  iconColor: Colors.green.shade700,
                  mainText: '$totalProducts produtos cadastrados',
                  backgroundColor: Colors.green.shade50,
                  borderColor: Colors.green.shade100,
                  chips: [
                    UiHelpers.buildSummaryChip(
                      'Categorias: $categories',
                      Colors.blue,
                    ),
                    UiHelpers.buildSummaryChip(
                      'Valor Total: R\$ ${totalValue.toStringAsFixed(2)}',
                      Colors.green,
                    ),
                  ],
                ),
                table: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: GenericTable<Product>(
                    data: productList,
                    columns: const [
                      DataColumn(label: Text('ID')),
                      DataColumn(label: Text('Descrição')),
                      DataColumn(label: Text('Categoria')),
                      DataColumn(label: Text('Preço Custo')),
                      DataColumn(label: Text('Preço Venda')),
                      DataColumn(label: Text('Ações')),
                    ],
                    rowBuilder: (p, index) {
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
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '#${p.id}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.green.shade900,
                                ),
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              p.descricao ?? '',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.blue.shade200,
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                p.categoria_descricao ?? '',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.blue.shade900,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              'R\$ ${p.preco_custo?.toStringAsFixed(2) ?? '0.00'}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              'R\$ ${p.preco_venda?.toStringAsFixed(2) ?? '0.00'}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          DataCell(
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, size: 18),
                                  onPressed: () async => _editProduct(p),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    size: 18,
                                    color: Colors.red,
                                  ),
                                  onPressed: () async => _deleteProduct(p),
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
            );
          },
        ),
      ),
    );
  }
}
