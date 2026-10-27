import 'package:flutter/material.dart';
import 'package:frontend_dilaundry/config/app_constants.dart';
import 'package:frontend_dilaundry/config/app_error.dart';
import 'package:frontend_dilaundry/config/app_response.dart';
import 'package:frontend_dilaundry/config/failure.dart';
import 'package:frontend_dilaundry/datasources/auth_datasource.dart';
import 'package:frontend_dilaundry/pages/dashboard_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorText;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (username.length < 4) {
      setState(
        () => _errorText = 'Nama pengguna minimal 4 karakter.',
      );
      return;
    }
    if (email.isEmpty || !email.contains('@')) {
      setState(() => _errorText = 'Isi email yang valid.');
      return;
    }
    if (password.length < 8) {
      setState(() => _errorText = 'Kata sandi minimal 8 karakter.');
      return;
    }
    if (password != _confirmController.text) {
      setState(() => _errorText = 'Ulangi kata sandi yang sama.');
      return;
    }
    setState(() {
      _isLoading = true;
      _errorText = null;
    });
    try {
      await AuthDatasource.register(username, email, password);
      // Registrasi backend tidak mengembalikan token, jadi masuk
      // otomatis memakai akun yang baru dibuat.
      final user = await AuthDatasource.login(email, password);
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => DashboardPage(user: user)),
        (route) => false,
      );
    } on InvalidInputFailure catch (failure) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      AppResponse.invalidInput(context, failure.message ?? '');
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorText = appErrorMessage(error);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Akun')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Buat akun ${AppConstants.appname}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            const Text(
              'Satu akun untuk memesan, melacak, dan mengklaim laundry.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Nama Pengguna',
                prefixIcon: Icon(Icons.person_outline),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email_outlined),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'Kata Sandi',
                prefixIcon: const Icon(Icons.lock_outline),
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                  onPressed: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                ),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _confirmController,
              obscureText: _obscurePassword,
              decoration: const InputDecoration(
                labelText: 'Ulangi Kata Sandi',
                prefixIcon: Icon(Icons.lock_outline),
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _register(),
            ),
            if (_errorText != null) ...[
              const SizedBox(height: 12),
              Text(
                _errorText!,
                style: const TextStyle(color: Colors.red, fontSize: 13),
              ),
            ],
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _register,
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Daftar'),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Sudah punya akun?'),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Masuk'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
