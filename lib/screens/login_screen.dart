import 'package:consig_now_app/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  // Tenta o login por biometria ao iniciar a tela
  @override
  void initState() {
    super.initState();
    _tryBiometricLogin();
  }

  // Se o login biométrico falhar ou não houver token, o usuário verá o login normal.
  Future<void> _tryBiometricLogin() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final isLoggedIn = await auth.loginWithBiometrics();

    if (isLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Senha'),
              obscureText: true,
            ),
            SizedBox(height: 16),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: () async {
                      setState(() => _isLoading = true);
                      try {
                        final success = await auth.login(
                          _emailController.text,
                          _passwordController.text,
                        );
                        setState(() => _isLoading = false);

                        if (success) {
                          // Pergunta se quer ativar a biometria
                          final enableBiometrics = await showDialog<bool>(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: Text('Ativar biometria?'),
                              content: Text(
                                'Deseja ativar login por biometria para facilitar o acesso?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: Text('Não'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: Text('Sim'),
                                ),
                              ],
                            ),
                          );

                          if (enableBiometrics == true) {
                            await auth
                                .enableBiometrics(); // você cria este método no provider
                          }

                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => HomeScreen()),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Erro ao fazer login')),
                          );
                        }
                      } catch (e) {
                        setState(() => _isLoading = false);
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text(e.toString())));
                      }
                    },
                    child: Text('Entrar'),
                  ),
          ],
        ),
      ),
    );
  }
}
