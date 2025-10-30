import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSourceImpl({required this.dio});

  @override
  Future<UserModel> login(String email, String password) async {
    try {
      final response = await dio.post(
        '/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      // Kiểm tra status code
      if (response.statusCode == 200 || response.statusCode == 201) {
        return UserModel.fromJson(response.data);
      } else {
        throw ServerException(
          message: 'Server returned ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      // Xử lý lỗi Dio chi tiết hơn
      if (e.type == DioExceptionType.connectionTimeout) {
        throw ServerException(message: 'Connection timeout');
      } else if (e.response?.statusCode == 401) {
        throw ServerException(message: 'Invalid credentials');
      } else {
        throw ServerException(message: e.message);
      }
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
