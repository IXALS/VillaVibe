import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class PasswordStepView extends StatefulWidget {
  final String email;
  final Function(String password) onLogin;
  final bool isLoading;
  final VoidCallback onBack;

  const PasswordStepView({
    super.key,
    required this.email,
    required this.onLogin,
    required this.onBack,
    this.isLoading = false,
  });

  @override
  State<PasswordStepView> createState() => _PasswordStepViewState();
}

class _PasswordStepViewState extends State<PasswordStepView> {
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _showPassword = false;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      widget.onLogin(_passwordController.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: widget.onBack,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              Expanded(
                child: Text(
                  'Log in',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 24), // Balance back button
            ],
          ),
          const SizedBox(height: 40),

          // Logo/Welcome
          const Icon(Icons.home_filled, size: 48, color: Color(0xFFE31C5F)),
          const SizedBox(height: 16),
          Text(
            'Welcome to VillaVibe',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 40),

          // Password
          TextFormField(
            controller: _passwordController,
            obscureText: !_showPassword,
            decoration: InputDecoration(
              labelText: 'Password',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              suffixIcon: TextButton(
                onPressed: () {
                  setState(() {
                    _showPassword = !_showPassword;
                  });
                },
                child: Text(
                  _showPassword ? 'Hide' : 'Show',
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password';
              }
              return null;
            },
            onFieldSubmitted: (_) => _submit(),
          ),

          const SizedBox(height: 32),

          ElevatedButton(
            onPressed: widget.isLoading ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE31C5F),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: widget.isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'Continue',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
          ),

          const SizedBox(height: 24),

          Center(
            child: TextButton(
              onPressed: () {
                // TODO: Implement forgot password
              },
              child: const Text(
                'Forgot password?',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
        ],
      ).animate().fadeIn().slideX(begin: 0.1, end: 0),
    );
  }
}
