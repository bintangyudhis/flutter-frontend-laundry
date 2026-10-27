import 'dart:convert';

import 'package:frontend_dilaundry/config/failure.dart';

/// Mengubah kegagalan dari lapisan data menjadi pesan Bahasa Indonesia
/// yang siap ditampilkan ke pengguna.
String appErrorMessage(Object error) {
  if (error is Failure) {
    final body = error.message;
    if (body != null) {
      try {
        final decoded = jsonDecode(body);
        if (decoded is Map && decoded['message'] is String) {
          return _translateBackendMessage(decoded['message'] as String);
        }
      } catch (_) {
        // Isi respons bukan JSON, lanjut ke pesan bawaan di bawah.
      }
    }
    if (error is UnauthorisedFailure) {
      return 'Sesi sudah berakhir. Silakan masuk lagi.';
    }
    if (error is NotFoundFailure) return 'Data tidak ditemukan.';
    if (error is ServerFailure) {
      return 'Server sedang bermasalah. Coba lagi nanti.';
    }
    return 'Terjadi kesalahan. Silakan coba lagi.';
  }
  return 'Tidak dapat terhubung ke server. Periksa koneksi internet dan alamat API.';
}

String _translateBackendMessage(String message) {
  switch (message) {
    case 'Unauthorized':
      return 'Email atau kata sandi salah.';
    case 'Not found':
      return 'Data tidak ditemukan. Periksa kembali isian kamu.';
    case 'Laundry has been claimed':
      return 'Pesanan ini sudah diklaim oleh pengguna lain.';
    case 'Can not be updated':
      return 'Pesanan gagal diklaim. Silakan coba lagi.';
    default:
      return message;
  }
}
