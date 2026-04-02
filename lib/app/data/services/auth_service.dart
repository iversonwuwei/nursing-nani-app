import 'package:get/get.dart';
import 'package:nursing_nani_app/app/data/models/nani_models.dart';
import 'package:nursing_nani_app/app/data/services/mock_nani_service.dart';

class AuthService extends GetxService {
  AuthService(this._mockService);

  final MockNaniService _mockService;
  final Rxn<NaniUser> currentUser = Rxn<NaniUser>();

  bool get isAuthenticated => currentUser.value != null;

  Future<bool> signIn({
    required String username,
    required String password,
  }) async {
    final trimmedUsername = username.trim();
    final trimmedPassword = password.trim();
    if (trimmedUsername.isEmpty || trimmedPassword.isEmpty) {
      return false;
    }

    currentUser.value = _mockService.defaultUser;
    return true;
  }

  void signOut() {
    currentUser.value = null;
  }
}