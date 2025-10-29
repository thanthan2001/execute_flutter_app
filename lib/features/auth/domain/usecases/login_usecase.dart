import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

// UseCase chứa logic nghiệp vụ cụ thể cho một hành động.
// Nó gọi đến Repository để lấy dữ liệu và xử lý.
class LoginUsecase implements UseCase<UserEntity, LoginParams> {
  final AuthRepository repository;

  LoginUsecase(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(LoginParams params) async {
    return await repository.login(params.email, params.password);
  }
}

// Lớp chứa các tham số cần thiết cho use case Login.
class LoginParams extends Equatable {
  final String email;
  final String password;

  const LoginParams({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}
