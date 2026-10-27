import 'package:frontend_dilaundry/config/app_constants.dart';
import 'package:frontend_dilaundry/config/app_request.dart';
import 'package:frontend_dilaundry/config/app_response.dart';
import 'package:frontend_dilaundry/config/app_session.dart';
import 'package:frontend_dilaundry/models/promo_model.dart';
import 'package:http/http.dart' as http;

class PromoDatasource {
  static Future<List<PromoModel>> readAll() async {
    final response = await http.get(
      Uri.parse('${AppConstants.baseUrl}/promo'),
      headers: AppRequest.header(),
    );
    final responseBody = AppResponse.data(response);
    return (responseBody['data'] as List)
        .map((item) => PromoModel.fromJson(item))
        .toList();
  }

  static Future<List<PromoModel>> readLimit() async {
    final token = await AppSession.getBearerToken();
    final response = await http.get(
      Uri.parse('${AppConstants.baseUrl}/promo/limit'),
      headers: AppRequest.header(token),
    );
    final responseBody = AppResponse.data(response);
    return (responseBody['data'] as List)
        .map((item) => PromoModel.fromJson(item))
        .toList();
  }
}
