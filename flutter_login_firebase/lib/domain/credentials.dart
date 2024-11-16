class LoginCredentials {
  final String email;
  final String password;

  LoginCredentials({
    required this.email,
    required this.password,
  });

  bool get isValid => email.isNotEmpty && password.isNotEmpty;
}
