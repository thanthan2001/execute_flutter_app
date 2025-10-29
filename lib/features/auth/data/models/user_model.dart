import '../../domain/entities/user_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart'; // File này sẽ được generate tự động

// Model là một lớp con của Entity, nó có thêm các phương thức để xử lý dữ liệu
// từ nguồn bên ngoài (ví dụ: fromJson, toJson).
@JsonSerializable()
class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}
