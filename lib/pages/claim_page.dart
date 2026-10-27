import 'package:flutter/material.dart';
import 'package:frontend_dilaundry/config/app_error.dart';
import 'package:frontend_dilaundry/config/app_response.dart';
import 'package:frontend_dilaundry/config/failure.dart';
import 'package:frontend_dilaundry/config/nav.dart';
import 'package:frontend_dilaundry/datasources/laundry_datasource.dart';
import 'package:frontend_dilaundry/models/user_model.dart';
import 'package:frontend_dilaundry/pages/my_orders_page.dart';

class ClaimPage extends StatefulWidget {
  final UserModel user;
  const ClaimPage({super.key, required this.user});

  @override
  State<ClaimPage> createState() => _ClaimPageState();
}

class _ClaimPageState extends State<ClaimPage> {
  final _idController = TextEditingController();
  final _codeController = TextEditingController();
  bool _isLoading = false;
  String? _errorText;
  bool _success = false;

  @override
  void dispose() {
    _idController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _claim() async {
    final id = int.tryParse(_idController.text.trim());
    final code = _codeController.text.trim();
    if (id == null) {
      setState(() => _errorText = 'ID pesanan harus berupa angka.');
      return;
    }
    if (code.isEmpty) {
      setState(() => _errorText = 'Kode klaim wajib diisi.');
      return;
    }
    setState(() {
      _isLoading = true;
      _errorText = null;
      _success = false;
    });
    try {
      await LaundryDatasource.claim(id, code, widget.user.id);
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _success = true;
      });
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
      appBar: AppBar(title: const Text('Klaim Laundry')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.qr_code_2, size: 56, color: Colors.green),
            const SizedBox(height: 12),
            const Text(
              'Punya cucian yang selesai di toko tetapi belum masuk ke akunmu? '
              'Klaim dengan ID pesanan dan kode klaim yang diberikan toko.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, height: 1.5),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _idController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'ID Pesanan',
                hintText: 'Contoh: 12',
                prefixIcon: Icon(Icons.numbers),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _codeController,
              decoration: const InputDecoration(
                labelText: 'Kode Klaim',
                hintText: 'Contoh: sakjhsaiu',
                prefixIcon: Icon(Icons.code),
                border: OutlineInputBorder(),
              ),
            ),
            if (_errorText != null) ...[
              const SizedBox(height: 12),
              Text(
                _errorText!,
                style: const TextStyle(color: Colors.red, fontSize: 13),
              ),
            ],
            if (_success) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Klaim berhasil. Pesanan sekarang terhubung ke akunmu.',
                  style: TextStyle(color: Colors.green),
                ),
              ),
            ],
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _claim,
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Klaim Sekarang'),
            ),
            if (_success) ...[
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () {
                  Nav.push(context, MyOrdersPage(user: widget.user));
                },
                child: const Text('Lihat Pesanan Saya'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
