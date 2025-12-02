import 'package:consig_now_app/models/conditional.dart';
import 'package:consig_now_app/screens/conditional_item_screen.dart';
import 'package:consig_now_app/services/conditional_service.dart';
import 'package:consig_now_app/widgets/generic_table.dart';
import 'package:consig_now_app/widgets/info_bar.dart';
import 'package:consig_now_app/widgets/table_container.dart';
import 'package:consig_now_app/widgets/table_header.dart';
import 'package:consig_now_app/widgets/ui_helpers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../colors/minhas_cores.dart';
import 'package:consig_now_app/screens/login_screen.dart';

import 'package:consig_now_app/screens/conditional_edit_screen.dart';

class ConditionalScreen extends StatefulWidget {
  const ConditionalScreen({super.key});

  @override
  State<ConditionalScreen> createState() => _ConditionalScreenState();
}

class _ConditionalScreenState extends State<ConditionalScreen> {
  // Controladores dos filtros
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _representanteController =
      TextEditingController();
  String? _selectedStatus;
  DateTimeRange? _dateEntregaRange;
  DateTimeRange? _dateRetornoRange;

  // Chave para forçar rebuild apenas da tabela
  Key _tableKey = UniqueKey();
  Map<String, dynamic>? _currentFilters;

  // Opções de status
  final List<String> _statusOptions = [
    'Todos',
    'aberta',
    'finalizada',
    'em_cobranca',
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _idController.dispose();
    _representanteController.dispose();
    super.dispose();
  }

  Future<List<Conditional>> _fetchConditionals({
    Map<String, dynamic>? filters,
  }) async {
    try {
      final service = ConditionalService();
      return await service.listConditionals(filters: filters);
    } on Exception catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(msg)));
      }
      throw Exception(msg);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  void _applyFilters() {
    // Monta os filtros para a API
    final Map<String, dynamic> filters = {};

    if (_idController.text.isNotEmpty) {
      filters['id'] = int.tryParse(_idController.text);
    }

    if (_representanteController.text.isNotEmpty) {
      filters['user_name'] = _representanteController.text;
    }

    if (_selectedStatus != null && _selectedStatus != 'Todos') {
      filters['status'] = _selectedStatus;
    }

    if (_dateEntregaRange != null) {
      filters['data_entrega_inicial'] = _formatDate(_dateEntregaRange!.start);
      filters['data_entrega_final'] = _formatDate(_dateEntregaRange!.end);
    }

    if (_dateRetornoRange != null) {
      filters['data_retorno_inicial'] = _formatDate(_dateRetornoRange!.start);
      filters['data_retorno_final'] = _formatDate(_dateRetornoRange!.end);
    }

    // Atualiza os filtros e força rebuild apenas da tabela
    setState(() {
      _currentFilters = filters;
      _tableKey = UniqueKey();
    });
  }

  void _clearFilters() {
    setState(() {
      _idController.clear();
      _representanteController.clear();
      _selectedStatus = null;
      _dateEntregaRange = null;
      _dateRetornoRange = null;
      _currentFilters = null;
      _tableKey = UniqueKey();
    });
  }

  Future<void> _selectDateRange(bool isEntrega) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange: isEntrega ? _dateEntregaRange : _dateRetornoRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.green.shade600,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isEntrega) {
          _dateEntregaRange = picked;
        } else {
          _dateRetornoRange = picked;
        }
      });
    }
  }

  Future<void> _editConditional(
    BuildContext context,
    Conditional conditional,
  ) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ConditionalEditScreen(conditional: conditional),
      ),
    );

    if (result == true) {
      setState(() {
        _tableKey = UniqueKey();
      });
    }
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
      try {
        final service = ConditionalService();
        await service.deleteConditional(conditional.id);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Condicional #${conditional.id} excluído')),
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
            const Text('Condicionais'),
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [MinhasCores.verdeTopo, MinhasCores.verdeBaixo],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            // Painel de filtros
            _buildFilterPanel(),

            // Tabela com FutureBuilder isolado
            Expanded(
              child: FutureBuilder<List<Conditional>>(
                key: _tableKey, // Força rebuild apenas aqui
                future: _fetchConditionals(filters: _currentFilters),
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
                          Text(
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

                  final conditionalList = snapshot.data ?? [];
                  return _buildTable(conditionalList);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterPanel() {
    final hasActiveFilters =
        _idController.text.isNotEmpty ||
        _representanteController.text.isNotEmpty ||
        (_selectedStatus != null && _selectedStatus != 'Todos') ||
        _dateEntregaRange != null ||
        _dateRetornoRange != null;

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: false,
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.filter_list,
              color: Colors.green.shade700,
              size: 22,
            ),
          ),
          title: Row(
            children: [
              Text(
                'Filtros de Pesquisa',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              if (hasActiveFilters) ...[
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Ativos',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                    ),
                  ),
                ),
              ],
            ],
          ),
          trailing: hasActiveFilters
              ? TextButton.icon(
                  onPressed: _clearFilters,
                  icon: const Icon(Icons.clear_all, size: 18),
                  label: const Text('Limpar'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red.shade600,
                  ),
                )
              : const Icon(Icons.expand_more),
          children: [
            const Divider(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                // ID
                SizedBox(
                  width: 150,
                  child: TextField(
                    controller: _idController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'ID',
                      hintText: 'Ex: 123',
                      prefixIcon: const Icon(Icons.tag),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),

                // Representante
                SizedBox(
                  width: 250,
                  child: TextField(
                    controller: _representanteController,
                    decoration: InputDecoration(
                      labelText: 'Representante',
                      hintText: 'Nome do usuário',
                      prefixIcon: const Icon(Icons.person),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),

                // Status
                SizedBox(
                  width: 200,
                  child: DropdownButtonFormField<String>(
                    value: _selectedStatus,
                    decoration: InputDecoration(
                      labelText: 'Status',
                      prefixIcon: const Icon(Icons.flag),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    items: _statusOptions.map((status) {
                      String displayText = status;
                      if (status == 'em_cobranca') {
                        displayText = 'Em Cobrança';
                      } else if (status != 'Todos') {
                        displayText = UiHelpers.capitalizeFirstLetter(status);
                      }
                      return DropdownMenuItem(
                        value: status,
                        child: Text(displayText),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedStatus = value;
                      });
                    },
                  ),
                ),

                // Data de Entrega
                _buildDateRangeButton(
                  'Período de Entrega',
                  _dateEntregaRange,
                  Icons.calendar_today,
                  Colors.orange,
                  () => _selectDateRange(true),
                  () {
                    setState(() {
                      _dateEntregaRange = null;
                    });
                  },
                ),

                // Data de Retorno
                _buildDateRangeButton(
                  'Período de Retorno',
                  _dateRetornoRange,
                  Icons.event_available,
                  Colors.purple,
                  () => _selectDateRange(false),
                  () {
                    setState(() {
                      _dateRetornoRange = null;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _applyFilters,
                icon: const Icon(Icons.search),
                label: const Text('Aplicar Filtros'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateRangeButton(
    String label,
    DateTimeRange? range,
    IconData icon,
    MaterialColor color,
    VoidCallback onTap,
    VoidCallback onClear,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(
            color: range != null ? color.shade300 : Colors.grey.shade400,
            width: range != null ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(10),
          color: range != null ? color.shade50 : Colors.white,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color.shade700, size: 20),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  range == null
                      ? 'Selecionar'
                      : '${range.start.day.toString().padLeft(2, '0')}/${range.start.month.toString().padLeft(2, '0')}/${range.start.year} - ${range.end.day.toString().padLeft(2, '0')}/${range.end.month.toString().padLeft(2, '0')}/${range.end.year}',
                  style: TextStyle(
                    fontSize: 13,
                    color: range != null
                        ? color.shade900
                        : Colors.grey.shade600,
                    fontWeight: range != null
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              ],
            ),
            if (range != null) ...[
              const SizedBox(width: 12),
              InkWell(
                onTap: onClear,
                child: Icon(Icons.close, size: 18, color: Colors.red.shade600),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTable(List<Conditional> conditionalList) {
    if (conditionalList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'Nenhum condicional encontrado',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tente ajustar os filtros',
              style: TextStyle(color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    // Calcular estatísticas
    final totalAbertas = conditionalList
        .where((c) => c.status.toLowerCase() == 'aberta')
        .length;
    final totalFinalizados = conditionalList
        .where((c) => c.status.toLowerCase() == 'finalizada')
        .length;
    final totalPendentes = conditionalList
        .where((c) => c.status.toLowerCase() == 'em_cobranca')
        .length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: TableContainer(
        header: const TableHeader(
          title: 'Lista de Condicionais',
          subtitle: 'Acompanhe a situaçao das suas condicionais',
          icon: Icons.inventory_2_outlined,
        ),
        infoBar: InfoBar(
          icon: Icons.bar_chart,
          iconColor: Colors.green.shade700,
          mainText: '${conditionalList.length} registros encontrados',
          backgroundColor: Colors.green.shade50,
          borderColor: Colors.green.shade100,
          chips: [
            UiHelpers.buildSummaryChip(
              'Abertas: $totalAbertas',
              Colors.blue,
              onTap: () {
                setState(() {
                  _selectedStatus = 'aberta';
                });
                _applyFilters();
              },
            ),
            UiHelpers.buildSummaryChip(
              'Finalizadas: $totalFinalizados',
              Colors.green,
              onTap: () {
                setState(() {
                  _selectedStatus = 'finalizada';
                });
                _applyFilters();
              },
            ),
            UiHelpers.buildSummaryChip(
              'Pendentes: $totalPendentes',
              Colors.orange,
              onTap: () {
                setState(() {
                  _selectedStatus = 'em_cobranca';
                });
                _applyFilters();
              },
            ),
          ],
        ),
        table: Expanded(
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
                color: MaterialStateProperty.resolveWith<Color?>((states) {
                  if (states.contains(MaterialState.hovered)) {
                    return Colors.green.shade50;
                  }
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
                            builder: (_) =>
                                ConditionalItemScreen(conditional: conditional),
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
                              '${conditional.id}',
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
                                ? conditional.user_name[0].toUpperCase()
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
                  DataCell(
                    _buildStatusChip(
                      conditional.status == 'em_cobranca'
                          ? 'em cobrança'
                          : conditional.status,
                    ),
                  ),
                  DataCell(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 20),
                          color: Colors.blue.shade600,
                          tooltip: 'Editar',
                          onPressed: () =>
                              _editConditional(context, conditional),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 20),
                          color: Colors.red.shade600,
                          tooltip: 'Excluir',
                          onPressed: () =>
                              _deleteConditional(context, conditional),
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
  }

  Widget _buildStatusChip(String status) {
    MaterialColor color;
    IconData icon;

    switch (status.toLowerCase()) {
      case 'aberta':
        color = Colors.blue;
        icon = Icons.play_circle_outline;
        break;
      case 'finalizada':
        color = Colors.green;
        icon = Icons.check_circle_outline;
        break;
      case 'em cobrança':
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
