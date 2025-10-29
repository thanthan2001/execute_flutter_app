import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

// Đây là nơi hiện thực (implement) AuthRepository từ tầng Domain.
// Nó chịu trách nhiệm điều phối dữ liệu từ các nguồn (remote, local).
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, UserEntity>> login(
      String email, String password) async {
    // 1. Kiểm tra kết nối mạng
    if (await networkInfo.isConnected) {
      try {
        // 2. Nếu có mạng, gọi API từ remote data source
        final remoteUser = await remoteDataSource.login(email, password);
        // 3. Trả về UserModel (là một UserEntity) nếu thành công
        return Right(remoteUser);
      } on ServerException {
        // 4. Nếu API báo lỗi, trả về ServerFailure
        return Left(ServerFailure(message: 'Invalid credentials'));
      }
    } else {
      // 5. Nếu không có mạng, trả về NetworkFailure
      return Left(NetworkFailure());
    }
  }
}
