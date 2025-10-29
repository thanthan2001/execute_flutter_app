import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';

// Đây là một "Contract" (hợp đồng) định nghĩa các chức năng mà tầng Data phải thực hiện.
// Tầng Domain không quan tâm việc implement chi tiết như thế nào (gọi API hay local DB),
// nó chỉ cần biết có một hàm login trả về UserEntity hoặc một Failure.
abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> login(String email, String password);
}
