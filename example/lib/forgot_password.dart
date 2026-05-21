import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:better_auth_client/better_auth_client.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;
  String? _error;
  String? _success;

  Future<void> _resetPassword() async {
    if (_emailController.text.isEmpty) {
      setState(() => _error = 'Please enter your email');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
      _success = null;
    });

    try {
      await BetterAuthClient.instance.forgetPassword(
        email: _emailController.text,
        onSuccess: (ctx) {
          setState(() {
            _success = 'Password reset instructions sent to your email';
          });
          log("Success ${ctx.toString()}");
        },
        onError: (error) {
          setState(() => _error = error.message);
        },
      );
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back),
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFF1A1A1A),
                    padding: const EdgeInsets.all(12),
                  ),
                ),
                const SizedBox(height: 40),
                const Text(
                  'Reset Password',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter your email address and we\'ll send you instructions to reset your password.',
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),
                if (_error != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade900.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade400),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red.shade400),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _error!,
                            style: TextStyle(color: Colors.red.shade400),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (_success != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade900.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.shade400),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle_outline,
                            color: Colors.green.shade400),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _success!,
                            style: TextStyle(color: Colors.green.shade400),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 24),
                const Text(
                  'Email',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    hintText: 'Enter your email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  enabled: !_isLoading,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _resetPassword,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Send Reset Instructions',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 24),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Back to Sign In',
                      style: TextStyle(
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
