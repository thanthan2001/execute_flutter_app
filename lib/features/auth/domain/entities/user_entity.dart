import 'package:equatable/equatable.dart';

// Entity là một đối tượng nghiệp vụ cốt lõi, không phụ thuộc vào bất kỳ framework nào.
// Nó đại diện cho User trong toàn bộ ứng dụng.
class UserEntity extends Equatable {
  final String id;
  final String name;
  final String email;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
  });

  @override
  List<Object?> get props => [id, name, email];
}
