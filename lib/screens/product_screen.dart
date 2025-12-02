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
import 'product_add_screen.dart';
import 'product_edit_screen.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  Key _tableKey = UniqueKey();

  Future<List<Product>> _fetchProducts() async {
    final service = ProductService();
    return await service.listProducts();
  }

  Future<void> _addProduct() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProductAddScreen()),
    );

    if (result == true) {
      setState(() {
        _tableKey = UniqueKey();
      });
    }
  }

  Future<void> _editProduct(BuildContext context, Product product) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ProductEditScreen(product: product)),
    );

    if (result == true) {
      setState(() {
        _tableKey = UniqueKey();
      });
    }
  }

  Future<void> _deleteProduct(BuildContext context, Product product) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text(
          'Deseja realmente excluir o produto "${product.descricao}"?',
        ),
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
        final service = ProductService();
        await service.deleteProduct(product.id);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Produto "${product.descricao}" excluído')),
          );
          setState(() {
            _tableKey = UniqueKey();
          });
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
            icon: const Icon(Icons.refresh),
            tooltip: 'Atualizar',
            onPressed: () {
              setState(() {
                _tableKey = UniqueKey();
              });
            },
          ),
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
      floatingActionButton: FloatingActionButton(
        onPressed: _addProduct,
        backgroundColor: Colors.green,
        child: const Icon(Icons.add, color: Colors.white),
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
          key: _tableKey,
          future: _fetchProducts(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red.shade300,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Erro ao carregar dados',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${snapshot.error}',
                      style: const TextStyle(color: Colors.black),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.inbox_outlined,
                      size: 80,
                      color: Colors.grey.shade300,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Nenhum produto encontrado',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Adicione seu primeiro produto',
                      style: TextStyle(color: Colors.grey.shade500),
                    ),
                  ],
                ),
              );
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
                          'Descrição',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Categoria',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Preço Custo',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Preço Venda',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Ações',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      ),
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
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.green.shade100,
                                    Colors.green.shade50,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.green.shade200,
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                '#${p.id}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade900,
                                  fontSize: 13,
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
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit_outlined,
                                    size: 20,
                                  ),
                                  color: Colors.blue.shade600,
                                  tooltip: 'Editar',
                                  onPressed: () => _editProduct(context, p),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    size: 20,
                                  ),
                                  color: Colors.red.shade600,
                                  tooltip: 'Excluir',
                                  onPressed: () => _deleteProduct(context, p),
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
