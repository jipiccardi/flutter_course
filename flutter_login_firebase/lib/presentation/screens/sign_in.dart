import 'package:flutter/material.dart';

import '../../data/firebase_auth_service.dart';
import '../../domain/credentials.dart';
import '../../config/routes/routes.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  bool _isLoading = false;

  final _formKey = GlobalKey<FormState>();

  final authService = FirebaseAuthService();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (authService.currentUser != null) {
        Navigator.pushReplacementNamed(context, MainRoutes.home);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();

    _emailController.dispose();
    _passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const FlutterLogo(
                    size: 200,
                    style: FlutterLogoStyle.stacked,
                  ),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Email',
                      hintText: 'Enter valid email as abc@gmail.com',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    autocorrect: false,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: 'Password',
                      hintText: 'Enter your secure password',
                      suffixIcon: IconButton(
                        onPressed: _togglePasswordVisibility,
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                  ),
                  TextButton(
                    onPressed: _onForgotPassButtonPressed,
                    child: Text(
                      'Forgot Password?',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _onSignUpButtonPressed,
                    child: Text(
                      'Don\'t have an account? Sign up!',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    height: 50,
                    width: 250,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: TextButton(
                      onPressed: _onLoginButtonPressed,
                      child: const Text(
                        'Login',
                        style: TextStyle(color: Colors.white, fontSize: 25),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Show a loading indicator if the state is loading
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  void _onForgotPassButtonPressed() {
    // Hide the keyboard and navigate
    FocusManager.instance.primaryFocus?.unfocus();
    Navigator.pushNamed(context, LoginRoutes.forgotPassword);
  }

  void _onSignUpButtonPressed() {
    // Hide the keyboard and navigate
    FocusManager.instance.primaryFocus?.unfocus();
    Navigator.pushNamed(context, LoginRoutes.signUp);
  }

  void _onLoginButtonPressed() async {
    // Hide the keyboard
    FocusManager.instance.primaryFocus?.unfocus();

    // Run the validations inside the Form-type widgets
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final credentials = LoginCredentials(
      email: _emailController.text,
      password: _passwordController.text,
    );
    if (!credentials.isValid) {
      _showSnackBar('Invalid credentials');
      return;
    }

    // Show a loading indicator
    setState(() {
      _isLoading = true;
    });

    try {
      // Sign in with email and password using FirebaseAuthService
      final user = await authService.signInWithEmailAndPassword(
        credentials.email,
        credentials.password,
      );

      //if (user.emailVerified && context.mounted) {
      if (context.mounted) {
        // Navigate to the home page
        Navigator.pushReplacementNamed(context, MainRoutes.home);
      } else {
        _showSnackBar('Please verify your email');
      }
    } catch (e) {
      _showSnackBar(e.toString());
    } finally {
      // Hide the loading indicator
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
