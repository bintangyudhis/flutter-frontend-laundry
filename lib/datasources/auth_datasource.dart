import 'package:frontend_dilaundry/config/app_constants.dart';
import 'package:frontend_dilaundry/config/app_request.dart';
import 'package:frontend_dilaundry/config/app_response.dart';
import 'package:frontend_dilaundry/config/app_session.dart';
import 'package:frontend_dilaundry/models/user_model.dart';
import 'package:http/http.dart' as http;

class AuthDatasource {
  static Future<UserModel> register(
    String username,
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('${AppConstants.baseUrl}/register'),
      headers: AppRequest.header(),
      body: {'username': username, 'email': email, 'password': password},
    );
    final responseBody = AppResponse.data(response);
    return UserModel.fromJson(responseBody['data']);
  }

  static Future<UserModel> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('${AppConstants.baseUrl}/login'),
      headers: AppRequest.header(),
      body: {'email': email, 'password': password},
    );
    final responseBody = AppResponse.data(response);
    final user = UserModel.fromJson(responseBody['data']);
    await AppSession.setUser(responseBody['data']);
    await AppSession.setBearerToken(responseBody['token']);
    return user;
  }

  static Future<void> logout() async {
    // Backend tidak menyediakan endpoint logout, jadi sesi cukup
    // dibersihkan dari perangkat.
    await AppSession.clear();
  }
}
