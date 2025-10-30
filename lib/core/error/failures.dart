import 'package:equatable/equatable.dart';

// Lớp trừu tượng cho tất cả các Failure.
// Failure đại diện cho một lỗi nghiệp vụ, ví dụ: không có kết nối mạng, server lỗi.
abstract class Failure extends Equatable {
  const Failure([List properties = const <dynamic>[]]);

  @override
  List<Object> get props => [];
}

// Các loại Failure cụ thể
class ServerFailure extends Failure {
  final String? message;
  const ServerFailure({this.message});
}

class CacheFailure extends Failure {
  final String? message;
  const CacheFailure({this.message});
}

class NetworkFailure extends Failure {}
