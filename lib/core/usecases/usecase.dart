import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../error/failures.dart';

// Lớp trừu tượng cho tất cả các UseCase.
// Định nghĩa một quy tắc chung: mỗi use case có một hàm call nhận vào Params
// và trả về một Future chứa Either<Failure, Type>.
// - Type: Kiểu dữ liệu trả về khi thành công.
// - Params: Tham số đầu vào cho use case.
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

// Lớp này được sử dụng khi use case không cần tham số đầu vào.
class NoParams extends Equatable {
  @override
  List<Object> get props => [];
}
