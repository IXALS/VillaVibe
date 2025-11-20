import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:villavibe/features/auth/data/repositories/auth_repository.dart';
import 'package:villavibe/features/auth/presentation/widgets/login_step_view.dart';
import 'package:villavibe/features/auth/presentation/widgets/password_step_view.dart';
import 'package:villavibe/features/auth/presentation/widgets/signup_step_view.dart';

enum AuthStep { email, password, signup }

class LoginModal extends ConsumerStatefulWidget {
  const LoginModal({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const LoginModal(),
    );
  }

  @override
  ConsumerState<LoginModal> createState() => _LoginModalState();
}

class _LoginModalState extends ConsumerState<LoginModal> {
  AuthStep _currentStep = AuthStep.email;
  String _email = '';
  bool _isLoading = false;

  void _handleEmailContinue(String email) async {
    setState(() {
      _isLoading = true;
      _email = email;
    });

    try {
      final exists =
          await ref.read(authRepositoryProvider).checkUserExists(email);

      if (mounted) {
        setState(() {
          _isLoading = false;
          // If user exists -> Password step
          // If user does not exist -> Signup step
          _currentStep = exists ? AuthStep.password : AuthStep.signup;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  void _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(authRepositoryProvider).signInWithGoogle();
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _handleLogin(String password) async {
    setState(() => _isLoading = true);
    try {
      await ref
          .read(authRepositoryProvider)
          .signInWithEmailAndPassword(_email, password);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _handleSignup(
      String firstName, String lastName, DateTime dob, String password) async {
    setState(() => _isLoading = true);
    try {
      await ref.read(authRepositoryProvider).signUp(
            email: _email,
            password: password,
            displayName: '$firstName $lastName',
          );
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _goBack() {
    setState(() {
      _currentStep = AuthStep.email;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.9,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),

            Expanded(
              child: SingleChildScrollView(
                child: _buildStepContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case AuthStep.email:
        return LoginStepView(
          onContinue: _handleEmailContinue,
          onGoogleSignIn: _handleGoogleSignIn,
          isLoading: _isLoading,
        );
      case AuthStep.password:
        return PasswordStepView(
          email: _email,
          onLogin: _handleLogin,
          onBack: _goBack,
          isLoading: _isLoading,
        );
      case AuthStep.signup:
        return SignupStepView(
          email: _email,
          onSignup: _handleSignup,
          onBack: _goBack,
          isLoading: _isLoading,
        );
    }
  }
}
