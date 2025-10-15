import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../colors/minhas_cores.dart';
import 'package:consig_now_app/screens/login_screen.dart';

class PosScreen extends StatefulWidget {
  const PosScreen({super.key});

  @override
  State<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends State<PosScreen> {
  String? clienteSelecionado;
  final List<Map<String, dynamic>> produtos = [
    {'nome': 'Produto A', 'preco': 50.0},
    {'nome': 'Produto B', 'preco': 75.0},
    {'nome': 'Produto C', 'preco': 100.0},
  ];

  final List<Map<String, dynamic>> carrinho = [];

  void adicionarAoCarrinho(Map<String, dynamic> produto) {
    setState(() {
      final existente = carrinho.firstWhere(
        (item) => item['nome'] == produto['nome'],
        orElse: () => {},
      );

      if (existente.isNotEmpty) {
        existente['quantidade'] += 1;
      } else {
        carrinho.add({
          'nome': produto['nome'],
          'preco': produto['preco'],
          'quantidade': 1,
        });
      }
    });
  }

  void removerDoCarrinho(Map<String, dynamic> produto) {
    setState(() {
      carrinho.removeWhere((item) => item['nome'] == produto['nome']);
    });
  }

  double get total => carrinho.fold(
    0,
    (soma, item) => soma + (item['preco'] * item['quantidade']),
  );

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('assets/logo.png', height: 32),
            const SizedBox(width: 8),
            const Text('Ponto de Venda'),
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
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Seleção de cliente
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Selecione o Cliente',
                border: OutlineInputBorder(),
              ),
              value: clienteSelecionado,
              items: const [
                DropdownMenuItem(value: 'Cliente A', child: Text('Cliente A')),
                DropdownMenuItem(value: 'Cliente B', child: Text('Cliente B')),
              ],
              onChanged: (valor) {
                setState(() => clienteSelecionado = valor);
              },
            ),
            const SizedBox(height: 16),

            // Lista de produtos
            Expanded(
              child: ListView.builder(
                itemCount: produtos.length,
                itemBuilder: (context, index) {
                  final produto = produtos[index];
                  return Card(
                    child: ListTile(
                      title: Text(produto['nome']),
                      subtitle: Text(
                        'R\$ ${produto['preco'].toStringAsFixed(2)}',
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.add_shopping_cart),
                        onPressed: () => adicionarAoCarrinho(produto),
                      ),
                    ),
                  );
                },
              ),
            ),

            const Divider(),

            // Resumo do carrinho
            Expanded(
              child: ListView.builder(
                itemCount: carrinho.length,
                itemBuilder: (context, index) {
                  final item = carrinho[index];
                  return ListTile(
                    title: Text('${item['nome']} x${item['quantidade']}'),
                    subtitle: Text(
                      'R\$ ${(item['preco'] * item['quantidade']).toStringAsFixed(2)}',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => removerDoCarrinho(item),
                    ),
                  );
                },
              ),
            ),

            // Total e botão de finalização
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total: R\$ ${total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.check),
                  label: const Text('Finalizar Venda'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MinhasCores.verdeBaixo,
                  ),
                  onPressed: clienteSelecionado == null || carrinho.isEmpty
                      ? null
                      : () {
                          // Aqui você pode integrar com Firebase ou API
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Venda finalizada com sucesso!'),
                            ),
                          );
                          setState(() {
                            carrinho.clear();
                            clienteSelecionado = null;
                          });
                        },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
