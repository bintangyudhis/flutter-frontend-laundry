import 'package:frontend_dilaundry/config/app_constants.dart';
import 'package:frontend_dilaundry/config/app_request.dart';
import 'package:frontend_dilaundry/config/app_response.dart';
import 'package:frontend_dilaundry/config/app_session.dart';
import 'package:frontend_dilaundry/models/shop_model.dart';
import 'package:http/http.dart' as http;

class ShopDatasource {
  static Future<List<ShopModel>> readAll() async {
    final response = await http.get(
      Uri.parse('${AppConstants.baseUrl}/shop'),
      headers: AppRequest.header(),
    );
    final responseBody = AppResponse.data(response);
    return (responseBody['data'] as List)
        .map((item) => ShopModel.fromJson(item))
        .toList();
  }

  static Future<List<ShopModel>> readRecommendation() async {
    final token = await AppSession.getBearerToken();
    final response = await http.get(
      Uri.parse('${AppConstants.baseUrl}/shop/recommendation/limit'),
      headers: AppRequest.header(token),
    );
    final responseBody = AppResponse.data(response);
    return (responseBody['data'] as List)
        .map((item) => ShopModel.fromJson(item))
        .toList();
  }

  static Future<List<ShopModel>> searchByCity(String city) async {
    final token = await AppSession.getBearerToken();
    final response = await http.get(
      Uri.parse(
        '${AppConstants.baseUrl}/shop/search/city/${Uri.encodeComponent(city)}',
      ),
      headers: AppRequest.header(token),
    );
    final responseBody = AppResponse.data(response);
    return (responseBody['data'] as List)
        .map((item) => ShopModel.fromJson(item))
        .toList();
  }
}
