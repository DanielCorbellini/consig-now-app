import 'package:consig_now_app/models/conditional.dart';
import 'package:consig_now_app/services/conditional_service.dart';
import 'package:consig_now_app/widgets/ui_helpers.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ConditionalEditScreen extends StatefulWidget {
  final Conditional conditional;

  const ConditionalEditScreen({super.key, required this.conditional});

  @override
  State<ConditionalEditScreen> createState() => _ConditionalEditScreenState();
}

class _ConditionalEditScreenState extends State<ConditionalEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _dataEntregaController;
  late TextEditingController _dataRetornoController;
  late String _status;
  bool _isLoading = false;

  final List<String> _statusOptions = ['aberta', 'finalizada', 'em_cobranca'];

  @override
  void initState() {
    super.initState();
    _status = widget.conditional.status;
    _dataEntregaController = TextEditingController(
      text: widget.conditional.data_entrega,
    );
    _dataRetornoController = TextEditingController(
      text: widget.conditional.data_prevista_retorno,
    );
  }

  @override
  void dispose() {
    _dataEntregaController.dispose();
    _dataRetornoController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        controller.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final service = ConditionalService();
      await service.updateConditional(widget.conditional.id, {
        'status': _status,
        'data_entrega': _dataEntregaController.text,
        'previsao_retorno': _dataRetornoController.text,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Condicional atualizada com sucesso!')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao atualizar: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Condicional #${widget.conditional.id}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Status'),
              DropdownButtonFormField<String>(
                value: _status,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.flag),
                ),
                items: _statusOptions.map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Text(UiHelpers.capitalizeFirstLetter(status)),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _status = value);
                },
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('Datas'),
              TextFormField(
                controller: _dataEntregaController,
                decoration: const InputDecoration(
                  labelText: 'Data de Entrega',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: () => _selectDate(_dataEntregaController),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Informe a data de entrega';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _dataRetornoController,
                decoration: const InputDecoration(
                  labelText: 'Previsão de Retorno',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.event),
                ),
                readOnly: true,
                onTap: () => _selectDate(_dataRetornoController),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Informe a previsão de retorno';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Salvar Alterações'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }
}
