import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginStepView extends ConsumerStatefulWidget {
  final Function(String email) onContinue;
  final VoidCallback onGoogleSignIn;
  final bool isLoading;

  const LoginStepView({
    super.key,
    required this.onContinue,
    required this.onGoogleSignIn,
    this.isLoading = false,
  });

  @override
  ConsumerState<LoginStepView> createState() => _LoginStepViewState();
}

class _LoginStepViewState extends ConsumerState<LoginStepView> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isPhoneAuth =
      false; // Default to Email as per user request flow implication, or maybe Phone? User said "remove input box email, just add normal continue with email button... then when clicked... change into only input email box". So starts with Phone (implied by "change into only input email"). Let's stick to the plan: Start with Phone.
  // Wait, user said: "I want it to remove the input box email, just add the normal continue with email button".
  // Current code has BOTH.
  // User wants: Start with Phone input. Email input is HIDDEN. "Continue with email" button is VISIBLE.
  // Click "Continue with email" -> Phone input HIDDEN. Email input VISIBLE. "Continue with Phone" button VISIBLE.

  @override
  void initState() {
    super.initState();
    _isPhoneAuth = true; // Start with Phone
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      widget.onContinue(_emailController.text.trim());
    }
  }

  void _toggleAuthMode() {
    setState(() {
      _isPhoneAuth = !_isPhoneAuth;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Log in or sign up',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Main Input Area
          if (_isPhoneAuth) ...[
            // Country/Region selector placeholder
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[400]!),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(8)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Country/Region',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                      const Text(
                        'Indonesia (+62)',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  const Icon(Icons.keyboard_arrow_down),
                ],
              ),
            ),
            // Phone number placeholder
            Container(
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(color: Colors.grey[400]!),
                  right: BorderSide(color: Colors.grey[400]!),
                  bottom: BorderSide(color: Colors.grey[400]!),
                ),
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(8)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: TextFormField(
                decoration: const InputDecoration(
                  hintText: 'Phone number',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 16),
                ),
                keyboardType: TextInputType.phone,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'We\'ll call or text to confirm your number. Standard message and data rates apply.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // TODO: Implement phone auth
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE31C5F),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Continue',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ] else ...[
            // Email Input Section
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.email_outlined),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                if (!value.contains('@')) {
                  return 'Please enter a valid email';
                }
                return null;
              },
              onFieldSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: widget.isLoading ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE31C5F),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: widget.isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Text(
                      'Continue',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
            ),
          ],

          const SizedBox(height: 24),
          Row(
            children: [
              const Expanded(child: Divider()),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text('or', style: TextStyle(color: Colors.grey[600])),
              ),
              const Expanded(child: Divider()),
            ],
          ),
          const SizedBox(height: 24),

          // Toggle Button (Email <-> Phone)
          if (_isPhoneAuth)
            _buildSocialButton(
              icon: Icons.email_outlined,
              label: 'Continue with email',
              onTap: _toggleAuthMode,
            )
          else
            _buildSocialButton(
              icon: Icons.phone_android,
              label: 'Continue with Phone',
              onTap: _toggleAuthMode,
            ),

          const SizedBox(height: 16),
          _buildSocialButton(
            icon: Icons.apple,
            label: 'Continue with Apple',
            onTap: () {},
          ),
          const SizedBox(height: 16),
          _buildSocialButton(
            icon: Icons.g_mobiledata,
            label: 'Continue with Google',
            onTap: widget.onGoogleSignIn,
            customIcon: const Icon(Icons.g_mobiledata, size: 28),
          ),
          const SizedBox(height: 16),
          _buildSocialButton(
            icon: Icons.facebook,
            label: 'Continue with Facebook',
            onTap: () {},
          ),
        ],
      ).animate().fadeIn(),
    );
  }

  Widget _buildSocialButton({
    IconData? icon,
    required String label,
    required VoidCallback onTap,
    Widget? customIcon,
  }) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        side: const BorderSide(color: Colors.black87),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        foregroundColor: Colors.black87,
      ),
      child: Row(
        children: [
          const SizedBox(width: 20),
          customIcon ?? Icon(icon, size: 24),
          Expanded(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 44), // Balance the icon width
        ],
      ),
    );
  }
}
