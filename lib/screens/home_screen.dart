import 'package:consig_now_app/screens/login_screen.dart';
import 'package:consig_now_app/screens/product_screen.dart';
import 'package:consig_now_app/screens/conditional_screen.dart';
import 'package:consig_now_app/screens/sales_screen.dart';
import 'package:consig_now_app/screens/pos_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../colors/minhas_cores.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('assets/logo.png', height: 32),
            const SizedBox(width: 8),
            const Text('BN Moda Fitness'),
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
        child: Column(
          children: [
            const SizedBox(height: 16),
            Text(
              'Bem-vindo, ${auth.user?.email ?? ''}',
              style: const TextStyle(fontSize: 18, color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Divider(
              color: Colors.white,
              thickness: 1,
              indent: 16,
              endIndent: 16,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Botão 1 - Produtos
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProductScreen(),
                        ),
                      );
                    },
                    onLongPress: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text(
                            'Este botão acessa a tela de consulta de produtos',
                            style: TextStyle(color: MinhasCores.verdeBaixo),
                          ),
                          duration: const Duration(seconds: 2),
                          backgroundColor:
                              MinhasCores.verdeTopoGradiente.shade900,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MinhasCores.verdeTopo,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 10,
                      ),
                    ),
                    child: const Text('Consultar Produtos'),
                  ),
                  const SizedBox(height: 16),
                  // Botão 2 - Condicionais
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ConditionalScreen(),
                        ),
                      );
                    },
                    onLongPress: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text(
                            'Este botão acessa a tela de consulta de condicionais',
                            style: TextStyle(color: MinhasCores.verdeBaixo),
                          ),
                          duration: const Duration(seconds: 2),
                          backgroundColor:
                              MinhasCores.verdeTopoGradiente.shade900,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MinhasCores.verdeTopo,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 10,
                      ),
                    ),
                    child: const Text('Condicionais'),
                  ),
                  const SizedBox(height: 16),
                  // Botão 3 - Vendas
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SalesScreen(),
                        ),
                      );
                    },
                    onLongPress: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text(
                            'Este botão acessa a tela de vendas',
                            style: TextStyle(color: MinhasCores.verdeBaixo),
                          ),
                          duration: const Duration(seconds: 2),
                          backgroundColor:
                              MinhasCores.verdeTopoGradiente.shade900,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MinhasCores.verdeTopo,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 10,
                      ),
                    ),
                    child: const Text('Vendas'),
                  ),
                  const SizedBox(height: 16),
                  // Botão 4 - Placeholder
                  ElevatedButton(
                    onPressed: () {
                      //tem que aplicar aqui a tela para passar vendas
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PosScreen(),
                        ),
                      );
                    },
                    onLongPress: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text(
                            'Este botão ainda não tem função definida',
                            style: TextStyle(color: MinhasCores.verdeBaixo),
                          ),
                          duration: const Duration(seconds: 2),
                          backgroundColor:
                              MinhasCores.verdeTopoGradiente.shade900,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MinhasCores.verdeTopo,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 10,
                      ),
                    ),
                    child: const Text('Ponto de venda'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
