import 'package:flutter/material.dart';

import '../../config/routes/routes.dart';
import '../../data/firebase_auth_service.dart';
import '../../data/firebase_users_repository.dart';
import '../../domain/credentials.dart';
import '../../domain/user.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _repeatPasswordController =
      TextEditingController();
  bool _isPasswordVisible = false;
  bool _isRepeatPasswordVisible = false;

  bool _isLoading = false;

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    super.dispose();

    _emailController.dispose();
    _passwordController.dispose();
    _repeatPasswordController.dispose();
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
                  const SizedBox(height: 30),
                  TextFormField(
                    controller: _repeatPasswordController,
                    obscureText: !_isRepeatPasswordVisible,
                    autocorrect: false,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: 'Repeat Password',
                      hintText: 'Repeat your secure password',
                      suffixIcon: IconButton(
                        onPressed: _toggleRepeatPasswordVisibility,
                        icon: Icon(
                          _isRepeatPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please repeat your password';
                      }
                      if (value != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  TextButton(
                    onPressed: _onSignInButtonPressed,
                    child: Text(
                      'Already have an account? Sign in!',
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
                      onPressed: _onRegisterButtonPressed,
                      child: const Text(
                        'Register',
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

  void _toggleRepeatPasswordVisibility() {
    setState(() {
      _isRepeatPasswordVisible = !_isRepeatPasswordVisible;
    });
  }

  void _onSignInButtonPressed() {
    // Hide the keyboard and navigate
    FocusManager.instance.primaryFocus?.unfocus();
    Navigator.pushReplacementNamed(context, LoginRoutes.signIn);
  }

  void _onRegisterButtonPressed() async {
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
      final authService = FirebaseAuthService();
      final usersRepository = FirebaseUsersRepository();
      final user = await authService.registerWithEmailAndPassword(
        credentials.email,
        credentials.password,
      );

      if (user.uid.isNotEmpty && context.mounted) {
        final newUser = MyUser(
          id: user.uid,
          email: user.email ?? credentials.email,
          name: user.displayName ?? 'John Doe',
          photoUrl: '',
        );
        await usersRepository.createUser(newUser);
        // Navigate to the home page
        if (context.mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            MainRoutes.home,
            (_) => false,
          );
        }
      } else {
        _showSnackBar('Please verify your email');
      }
    } catch (e) {
      _showSnackBar(e.toString());

      // TODO - Agregar logica condicional en funcion de la excepcion.
      // Por ejemplo, si ocurrio una excepcion de Firestore y no se pudo crear el doc,
      // se podria eliminar el usuario de FirebaseAuth.
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
