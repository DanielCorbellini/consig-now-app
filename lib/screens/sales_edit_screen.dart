import 'package:flutter/material.dart';

import '../models/sale.dart';
import '../services/sale_service.dart';
import '../colors/minhas_cores.dart';

class SalesEditScreen extends StatefulWidget {
  final Sale sale;

  const SalesEditScreen({super.key, required this.sale});

  @override
  State<SalesEditScreen> createState() => _SalesEditScreenState();
}

class _SalesEditScreenState extends State<SalesEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = SaleService();

  late TextEditingController _dateController;
  late TextEditingController _paymentController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _dateController = TextEditingController(text: widget.sale.dataVenda);
    _paymentController = TextEditingController(
      text: widget.sale.formaPagamento,
    );
  }

  @override
  void dispose() {
    _dateController.dispose();
    _paymentController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _service.updateSale(widget.sale.id, {
        'data_venda': _dateController.text,
        'forma_pagamento': _paymentController.text,
        // Mantemos os outros campos inalterados ou enviamos apenas o que mudou
        // A API valida 'sometimes', então podemos enviar apenas o necessário
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Venda atualizada com sucesso!')),
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
        title: Text('Editar Venda #${widget.sale.id}'),
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
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Dados da Venda',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: MinhasCores.verdeTopo,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),

                      // Data da Venda
                      TextFormField(
                        controller: _dateController,
                        decoration: const InputDecoration(
                          labelText: 'Data da Venda (YYYY-MM-DD)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Informe a data';
                          }
                          // Validação simples de formato
                          if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value)) {
                            return 'Formato inválido (YYYY-MM-DD)';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Forma de Pagamento
                      DropdownButtonFormField<String>(
                        value:
                            [
                              'dinheiro',
                              'cartao',
                              'pix',
                              'outro',
                            ].contains(_paymentController.text)
                            ? _paymentController.text
                            : null,
                        decoration: const InputDecoration(
                          labelText: 'Forma de Pagamento',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.payment),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'dinheiro',
                            child: Text('Dinheiro'),
                          ),
                          DropdownMenuItem(
                            value: 'cartao',
                            child: Text('Cartão'),
                          ),
                          DropdownMenuItem(value: 'pix', child: Text('Pix')),
                          DropdownMenuItem(
                            value: 'outro',
                            child: Text('Outro'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            _paymentController.text = value;
                          }
                        },
                        validator: (value) =>
                            value == null ? 'Selecione uma opção' : null,
                      ),
                      const SizedBox(height: 24),

                      // Botão Salvar
                      ElevatedButton(
                        onPressed: _isLoading ? null : _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: MinhasCores.verdeTopo,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                'Salvar Alterações',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
