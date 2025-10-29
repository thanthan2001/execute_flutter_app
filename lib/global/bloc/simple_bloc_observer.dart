import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';

// Lớp này giúp theo dõi (log) tất cả các thay đổi của BLoC trong ứng dụng.
// Rất hữu ích cho việc debug.
class SimpleBlocObserver extends BlocObserver {
  final Logger logger = Logger();

  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    logger.i('onEvent -- ${bloc.runtimeType}, $event');
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    logger.e('onError -- ${bloc.runtimeType}',
        error: error, stackTrace: stackTrace);
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    logger.d('onChange -- ${bloc.runtimeType}, $change');
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    logger.d('onTransition -- ${bloc.runtimeType}, $transition');
  }
}
