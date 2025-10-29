// Exception được throw từ Data layer khi có lỗi xảy ra (ví dụ: API trả về 404).
// Sau đó sẽ được map thành Failure ở Repository.
class ServerException implements Exception {}

class CacheException implements Exception {}
