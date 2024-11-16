import 'package:flutter/material.dart';

import '../../config/routes/routes.dart';
import '../../data/firebase_auth_service.dart';
import '../../data/firebase_users_repository.dart';
import '../../domain/user.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  MyUser? _currentUser;

  @override
  void initState() {
    super.initState();

    // Get current user after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getCurrentUser();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: _currentUser == null
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Welcome, ${_currentUser!.name}'),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      await FirebaseAuthService().signOut();
                      Navigator.of(context).pushReplacementNamed(
                        LoginRoutes.signIn,
                      );
                    },
                    child: const Text('Sign Out'),
                  ),
                ],
              ),
            ),
    );
  }

  void _getCurrentUser() async {
    final currentUser = FirebaseAuthService().currentUser;
    if (currentUser != null) {
      final user = await FirebaseUsersRepository().getUser(currentUser.uid);
      setState(() {
        _currentUser = user;
      });
    }
  }
}
