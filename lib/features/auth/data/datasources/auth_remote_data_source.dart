import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/error/exceptions.dart';
import '../models/user_model.dart';

// Lớp trừu tượng cho Data Source, định nghĩa các phương thức lấy dữ liệu từ xa.
abstract class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final http.Client client;

  AuthRemoteDataSourceImpl({required this.client});

  @override
  Future<UserModel> login(String email, String password) async {
    // --- Đây là phần giả lập gọi API ---
    print('Calling mock API to login with $email');
    await Future.delayed(const Duration(seconds: 2)); // Giả lập độ trễ mạng

    if (email == 'test@example.com' && password == '123456') {
      // Giả lập API trả về thành công
      final mockJsonResponse = {
        'id': '1',
        'name': 'Flutter Junior',
        'email': 'test@example.com',
      };
      return UserModel.fromJson(mockJsonResponse);
    } else {
      // Giả lập API trả về lỗi
      throw ServerException();
    }
  }
}
