import '../ServiceAdapters/backend_service_adapter.dart';

abstract class SignUpRepository {
  Future<String> signUp(
      String name,
      String email,
      String password,
      String address,
      String birthday,
      );
}

class SignUpRepositoryImpl implements SignUpRepository {

  final BackendServiceAdapter _backendServiceAdapter =  BackendServiceAdapterImpl();

  @override
  Future<String> signUp(
      String name,
      String email,
      String password,
      String address,
      String birthday,
      ) async {
    try {
      final result = await _backendServiceAdapter.signUp(
        name,
        email,
        password,
        address,
        birthday,
      );
      return result;
    } catch (e) {
      return e.toString();
    }
  }
}