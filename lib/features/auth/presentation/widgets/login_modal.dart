import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

import 'package:villavibe/features/auth/data/repositories/auth_repository.dart';
import 'package:villavibe/features/auth/presentation/widgets/login_step_view.dart';
import 'package:villavibe/features/auth/presentation/widgets/password_step_view.dart';
import 'package:villavibe/features/auth/presentation/widgets/signup_step_view.dart';

enum AuthStep { email, password, signup }

void showLoginModal(BuildContext context) {
  WoltModalSheet.show(
    context: context,
    pageListBuilder: (context) {
      return [
        WoltModalSheetPage(
          hasSabGradient: false,
          topBarTitle: const Text('Log in or sign up',
              style: TextStyle(fontWeight: FontWeight.bold)),
          isTopBarLayerAlwaysVisible: true,
          child: const _LoginFlowContent(),
        ),
      ];
    },
  );
}

class _LoginFlowContent extends ConsumerStatefulWidget {
  const _LoginFlowContent();

  @override
  ConsumerState<_LoginFlowContent> createState() => _LoginFlowContentState();
}

class _LoginFlowContentState extends ConsumerState<_LoginFlowContent> {
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
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: _buildStepContent(),
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
