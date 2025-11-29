import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart'; // <--- Necessário para acessar o ViewModel
import '../../ui/view_models/auth_view_model.dart'; // <--- Importe o AuthViewModel

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();



  bool _isLogin = true;
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _submit() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {

      final authViewModel = context.read<AuthViewModel>();

      if (_isLogin) {
        await authViewModel.login(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
      } else {
        await authViewModel.cadastrar(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
      }



    } on FirebaseAuthException catch (e) {

      String msg = e.message ?? 'Ocorreu um erro desconhecido.';
      if (e.code == 'user-not-found') msg = 'E-mail não cadastrado.';
      if (e.code == 'wrong-password') msg = 'Senha incorreta.';
      if (e.code == 'email-already-in-use') msg = 'Este e-mail já está em uso.';
      if (e.code == 'weak-password') msg = 'A senha é muito fraca.';
      if (e.code == 'invalid-email') msg = 'Formato de e-mail inválido.';

      setState(() {
        _errorMessage = msg;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Ocorreu um erro: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.inventory_2, size: 80, color: Colors.blue),
              const SizedBox(height: 20),
              Text(
                _isLogin ? 'Bem-vindo de volta!' : 'Crie sua conta',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'E-mail',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Senha',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                obscureText: true,
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(child: Text(_errorMessage!, style: const TextStyle(color: Colors.red))),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),
              if (_isLoading)
                const CircularProgressIndicator()
              else
                ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(_isLogin ? 'ENTRAR' : 'CADASTRAR', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  setState(() {
                    _isLogin = !_isLogin;
                    _errorMessage = null;
                    _emailController.clear();
                    _passwordController.clear();
                  });
                },
                child: Text(_isLogin ? 'Não tem conta? Cadastre-se' : 'Já tem conta? Entre'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}