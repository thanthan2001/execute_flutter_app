import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:my_clean_app/core/error/failures.dart';
import '../../../../core/storage/user_pref.dart';
import '../../data/models/user_model.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/login_usecase.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUsecase loginUsecase;

  AuthBloc({required this.loginUsecase}) : super(AuthInitial()) {
    // Xử lý sự kiện LoginEvent
    on<LoginEvent>(_onLogin);

    // Xử lý sự kiện LogoutEvent
    on<LogoutEvent>((event, emit) async {
      await UserPref.clearUser();
      emit(AuthInitial());
    });
  }

  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    // 1. Phát ra state Loading để UI hiển thị vòng xoay
    emit(AuthLoading());

    // 2. Gọi use case để thực hiện logic đăng nhập
    final failureOrUser = await loginUsecase(
      LoginParams(email: event.email, password: event.password),
    );

    // 3. Xử lý kết quả trả về từ use case
    failureOrUser.fold(
      // 3.1. Nếu thất bại (Left), phát ra state Error
      (failure) {
        String message = 'An unexpected error occurred';
        if (failure is ServerFailure) {
          message = failure.message ?? 'Server Error';
        } else if (failure is NetworkFailure) {
          message = 'No internet connection';
        }
        emit(AuthError(message: message));
      },
      // 3.2. Nếu thành công (Right), phát ra state Authenticated
      (user) async {
        // ✅ Lưu user sau khi đăng nhập thành công
        final userModel = UserModel(
          id: user.id,
          name: user.name,
          email: user.email,
        );

        await UserPref.saveUser(userModel);

        emit(AuthAuthenticated(user: user));
      },
    );
  }
}
