import 'package:consig_now_app/models/conditional.dart';
import 'package:consig_now_app/screens/conditional_item_screen.dart';
import 'package:consig_now_app/services/conditional_service.dart';
import 'package:consig_now_app/widgets/generic_table.dart';
import 'package:consig_now_app/widgets/ui_helpers.dart';
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

  Future<void> _editConditional(
    BuildContext context,
    Conditional conditional,
  ) async {
    // TODO: Implementar edição
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Editar condicional #${conditional.id}')),
    );
  }

  Future<void> _deleteConditional(
    BuildContext context,
    Conditional conditional,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text(
          'Deseja realmente excluir o condicional #${conditional.id}?',
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
      // TODO: Implementar exclusão
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Condicional #${conditional.id} excluído')),
      );
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
        child: FutureBuilder<List<Conditional>>(
          future: _fetchConditionals(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Erro: ${snapshot.error}'));
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Text('Nenhum condicional encontrado.'),
              );
            }

            final conditionalList = snapshot.data!;

            // Calcular estatísticas
            final totalAtivos = conditionalList
                .where((c) => c.status.toLowerCase() == 'ativo')
                .length;
            final totalFinalizados = conditionalList
                .where((c) => c.status.toLowerCase() == 'finalizada')
                .length;
            final totalPendentes = conditionalList
                .where((c) => c.status.toLowerCase() == 'pendente')
                .length;

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
                          colors: [
                            Colors.green.shade600,
                            Colors.green.shade400,
                          ],
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
                              Icons.inventory_2_outlined,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Lista de Condicionais',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Gerencie suas entregas condicionais',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
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
                        color: Colors.green.shade50,
                        border: Border(
                          bottom: BorderSide(color: Colors.green.shade100),
                        ),
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            Icon(
                              Icons.bar_chart,
                              size: 18,
                              color: Colors.green.shade700,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${conditionalList.length} registros encontrados',
                              style: TextStyle(
                                color: Colors.green.shade900,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(width: 16),
                            UiHelpers.buildSummaryChip(
                              'Ativos: $totalAtivos',
                              Colors.blue,
                            ),
                            const SizedBox(width: 8),
                            UiHelpers.buildSummaryChip(
                              'Finalizados: $totalFinalizados',
                              Colors.green,
                            ),
                            const SizedBox(width: 8),
                            UiHelpers.buildSummaryChip(
                              'Pendentes: $totalPendentes',
                              Colors.orange,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Tabela
                    Expanded(
                      child: GenericTable<Conditional>(
                        data: conditionalList,
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
                              'Representante',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Data de Entrega',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Previsão Retorno',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Status',
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
                        rowBuilder: (conditional, index) {
                          final isEven = index % 2 == 0;
                          return DataRow(
                            color: MaterialStateProperty.resolveWith<Color?>((
                              states,
                            ) {
                              if (states.contains(MaterialState.hovered)) {
                                return Colors.green.shade50;
                              }
                              return isEven
                                  ? Colors.white
                                  : Colors.grey.shade50;
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
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.tag,
                                          size: 14,
                                          color: Colors.green.shade700,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          '#${conditional.id}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green.shade900,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              DataCell(
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 18,
                                      backgroundColor: Colors.blue.shade100,
                                      child: Text(
                                        conditional.user_name.isNotEmpty
                                            ? conditional.user_name[0]
                                                  .toUpperCase()
                                            : '?',
                                        style: TextStyle(
                                          color: Colors.blue.shade900,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      conditional.user_name,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              DataCell(
                                UiHelpers.buildDateChip(
                                  conditional.data_entrega ?? 'N/A',
                                  Icons.calendar_today,
                                  Colors.orange,
                                ),
                              ),
                              DataCell(
                                UiHelpers.buildDateChip(
                                  conditional.data_prevista_retorno,
                                  Icons.event_available,
                                  Colors.purple,
                                ),
                              ),
                              DataCell(_buildStatusChip(conditional.status)),
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
                                      onPressed: () => _editConditional(
                                        context,
                                        conditional,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        size: 20,
                                      ),
                                      color: Colors.red.shade600,
                                      tooltip: 'Excluir',
                                      onPressed: () => _deleteConditional(
                                        context,
                                        conditional,
                                      ),
                                    ),
                                  ],
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
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    MaterialColor color;
    IconData icon;

    switch (status.toLowerCase()) {
      case 'ativo':
        color = Colors.blue;
        icon = Icons.play_circle_outline;
        break;
      case 'finalizada':
      case 'entregue':
        color = Colors.green;
        icon = Icons.check_circle_outline;
        break;
      case 'pendente':
        color = Colors.orange;
        icon = Icons.pending_outlined;
        break;
      case 'cancelado':
        color = Colors.red;
        icon = Icons.cancel_outlined;
        break;
      default:
        color = Colors.grey;
        icon = Icons.info_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [color.shade100, color.shade50]),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.shade300, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color.shade700),
          const SizedBox(width: 6),
          Text(
            UiHelpers.capitalizeFirstLetter(status),
            style: TextStyle(
              fontSize: 13,
              color: color.shade900,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
