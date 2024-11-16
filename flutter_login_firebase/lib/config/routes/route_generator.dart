import 'package:flutter/material.dart';

import '../../presentation/screens/forgot_password.dart';
import '../../presentation/screens/home.dart';
import '../../presentation/screens/sign_in.dart';
import '../../presentation/screens/sign_up.dart';
import 'routes.dart';

class RouteGenerator {
  static String initialRoute = LoginRoutes.signIn;

  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case LoginRoutes.signIn:
        return _buildRoute(const SignInPage());
      case LoginRoutes.signUp:
        return _buildRoute(const SignUpPage());
      case LoginRoutes.forgotPassword:
        return _buildRoute(const ForgotPasswordPage());
      case MainRoutes.home:
        return _buildRoute(const HomePage());
      default:
        return _errorRoute(settings.name);
    }
  }

  static Route<dynamic> _buildRoute(Widget page) {
    return MaterialPageRoute(
      builder: (builderContext) => page,
    );
  }

  static Route<dynamic> _errorRoute(String? route) {
    return MaterialPageRoute(
      builder: (builderContext) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Error'),
          ),
          body: Center(
            child: Text('ERROR - No route defined for this route ($route).'),
          ),
        );
      },
    );
  }
}
