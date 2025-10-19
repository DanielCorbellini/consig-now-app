import 'package:consig_now_app/models/conditional.dart';
import 'package:consig_now_app/screens/conditional_item_screen.dart';
import 'package:consig_now_app/services/conditional_service.dart';
import 'package:consig_now_app/widgets/generic_table.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../colors/minhas_cores.dart';
import 'package:consig_now_app/screens/login_screen.dart';

class ConditionalScreen extends StatelessWidget {
  const ConditionalScreen({super.key});

  Future<List<Conditional>> _fetchConditionals() async {
    final service = ConditionalService();
    return await service.listConditionals();
  }

  // Será implementado
  Future
  /**<List<Product>>*/
  _editConditional(p) async {
    return;
  }

  // Será implementado
  Future
  /**<List<Product>>*/
  _deleteConditional(p) async {
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
            const Text('Condicionais'),
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
        child: FutureBuilder(
          future: _fetchConditionals(),
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

            final conditionalList = snapshot.data!;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              scrollDirection: Axis.vertical,
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    // Cabeçalho customizado
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.green.shade600,
                            Colors.green.shade400,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: const Text(
                        'Lista de Condicionais',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // Tabela com scroll horizontal
                    GenericTable<Conditional>(
                      data: conditionalList,
                      columns: const [
                        DataColumn(label: Text('ID')),
                        DataColumn(label: Text('Representante')),
                        DataColumn(label: Text('Data de entrega')),
                        DataColumn(label: Text('Data Prevista')),
                        DataColumn(label: Text('Status')),
                        DataColumn(label: Text('Ações')),
                      ],
                      rowBuilder: (conditional, index) {
                        final isEven = index % 2 == 0;

                        return DataRow(
                          color: MaterialStateProperty.resolveWith<Color?>((
                            states,
                          ) {
                            if (states.contains(MaterialState.hovered))
                              return Colors.green.shade50;
                            return isEven ? Colors.white : Colors.grey.shade50;
                          }),
                          cells: [
                            DataCell(
                              InkWell(
                                borderRadius: BorderRadius.circular(8),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ConditionalItemScreen(
                                        conditional: conditional,
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '#${conditional.id}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.green.shade900,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            DataCell(
                              Text(
                                conditional.user_name,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                            DataCell(
                              Text(
                                conditional.data_entrega ?? '',
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                            DataCell(
                              Text(
                                conditional.data_prevista_retorno,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ),
                            DataCell(
                              Text(
                                conditional.status,
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
                                    onPressed: () async =>
                                        _editConditional(conditional),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      size: 18,
                                      color: Colors.red,
                                    ),
                                    onPressed: () async =>
                                        _deleteConditional(conditional),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
