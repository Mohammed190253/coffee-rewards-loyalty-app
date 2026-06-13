import '../../data/models/registration_request.dart';

abstract class IAuthRepository {
  Future<RegistrationResult> registerCustomer(RegistrationRequest request);
}
