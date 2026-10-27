import 'dart:convert';

import 'package:frontend_dilaundry/config/app_constants.dart';
import 'package:frontend_dilaundry/config/app_request.dart';
import 'package:frontend_dilaundry/config/app_response.dart';
import 'package:frontend_dilaundry/config/app_session.dart';
import 'package:frontend_dilaundry/config/failure.dart';
import 'package:frontend_dilaundry/models/laundry_model.dart';
import 'package:http/http.dart' as http;

class LaundryDatasource {
  static Future<List<LaundryModel>> readByUser(int userId) async {
    final token = await AppSession.getBearerToken();
    try {
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/laundry/user/$userId'),
        headers: AppRequest.header(token),
      );
      final responseBody = AppResponse.data(response);
      return (responseBody['data'] as List)
          .map((item) => LaundryModel.fromJson(item))
          .toList();
    } on NotFoundFailure catch (failure) {
      // Backend menjawab 404 bila pengguna belum memiliki pesanan,
      // padahal keadaan itu normal dan berarti daftar kosong.
      try {
        final decoded = jsonDecode(failure.message ?? '');
        if (decoded is Map && decoded['data'] is List) {
          return (decoded['data'] as List)
              .map((item) => LaundryModel.fromJson(item))
              .toList();
        }
      } catch (_) {
        // Abaikan, kembalikan daftar kosong di bawah.
      }
      return [];
    }
  }

  static Future<LaundryModel> create({
    required int shopId,
    required double weight,
    required bool withPickup,
    required bool withDelivery,
    required String pickupAddress,
    required String deliveryAddress,
    required double total,
    required String description,
  }) async {
    final token = await AppSession.getBearerToken();
    final response = await http.post(
      Uri.parse('${AppConstants.baseUrl}/laundry'),
      headers: AppRequest.header(token),
      body: {
        'shop_id': shopId.toString(),
        'weight': weight.toString(),
        'with_pickup': withPickup ? '1' : '0',
        'with_delivery': withDelivery ? '1' : '0',
        'pickup_address': pickupAddress,
        'delivery_address': deliveryAddress,
        'total': total.round().toString(),
        'description': description,
      },
    );
    final responseBody = AppResponse.data(response);
    return LaundryModel.fromJson(responseBody['data']);
  }

  static Future<bool> claim(int id, String claimCode, int userId) async {
    final token = await AppSession.getBearerToken();
    final response = await http.post(
      Uri.parse('${AppConstants.baseUrl}/laundry/claim'),
      headers: AppRequest.header(token),
      body: {
        'id': id.toString(),
        'claim_code': claimCode,
        'user_id': userId.toString(),
      },
    );
    // Respons sukses berisi data bernilai true.
    AppResponse.data(response);
    return true;
  }
}
