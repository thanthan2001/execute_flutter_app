import 'backup_metadata.dart';

class BackupFileEntity {
  final BackupMetadata metadata;
  final Map<String, dynamic> data;

  const BackupFileEntity({
    required this.metadata,
    required this.data,
  });

  factory BackupFileEntity.fromJson(Map<String, dynamic> json) {
    return BackupFileEntity(
      metadata: BackupMetadata.fromJson(
        json['metadata'] as Map<String, dynamic>,
      ),
      data: json['data'] as Map<String, dynamic>,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'metadata': metadata.toJson(),
      'data': data,
    };
  }
}
