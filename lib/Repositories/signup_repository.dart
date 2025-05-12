import 'package:http/http.dart' as http;

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

  final BackendServiceAdapter _backendServiceAdapter =  BackendServiceAdapterImpl(baseUrl:  'http://34.60.49.32:8000', client: http.Client());

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