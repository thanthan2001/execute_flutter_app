part of 'auth_bloc.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

// Trạng thái khởi tạo
class AuthInitial extends AuthState {}

// Trạng thái đang xử lý (ví dụ: đang gọi API)
class AuthLoading extends AuthState {}

// Trạng thái đã đăng nhập thành công
class AuthAuthenticated extends AuthState {
  final UserEntity user;

  const AuthAuthenticated({required this.user});

  @override
  List<Object> get props => [user];
}

// Trạng thái có lỗi xảy ra
class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object> get props => [message];
}
