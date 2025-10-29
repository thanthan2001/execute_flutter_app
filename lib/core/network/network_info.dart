import 'package:connectivity_plus/connectivity_plus.dart';

// Lớp trừu tượng để kiểm tra kết nối mạng.
// Giúp dễ dàng mock trong unit test và không phụ thuộc trực tiếp vào thư viện.
abstract class NetworkInfo {
  Future<bool> get isConnected;
}

class NetworkInfoImpl implements NetworkInfo {
  final Connectivity connectivity;

  NetworkInfoImpl(this.connectivity);

  @override
  Future<bool> get isConnected async {
    final result = await connectivity.checkConnectivity();
    if (result == ConnectivityResult.none) {
      return false;
    }
    return true;
  }
}
