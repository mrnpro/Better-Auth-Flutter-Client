import 'dart:developer';

import 'package:example/auth_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:better_auth_client/better_auth_client.dart';
import 'forgot_password.dart';
import 'home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await BetterAuthClient.create(
    baseUrl: 'http://10.184.221.99:4000', // Your host machine's IP address
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Better Auth Example',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0A0A0A),
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFF0066FF),
          secondary: Colors.white,
          surface: const Color(0xFF1A1A1A),
          error: Colors.red.shade400,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF1A1A1A),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF0066FF), width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.red.shade400),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.red.shade400, width: 2),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0066FF),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            side: const BorderSide(color: Color(0xFF2A2A2A)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ),
      home: const AuthWrapperWidget(
        onAuthenticatedChild: HomeScreen(),
        onAuthorizedChild: AuthScreen(),
      ),
    );
  }
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _twoFactorController = TextEditingController();
  final _phoneController = TextEditingController();
  final _phoneOtpController = TextEditingController();
  bool _isLoading = false;
  bool _rememberMe = true;
  bool _requiresTwoFactor = false;
  bool _isPhoneAuth = false;
  bool _phoneOtpSent = false;
  String? _error;
  late TabController _tabController;
  bool _isSignIn = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _twoFactorController.dispose();
    _phoneController.dispose();
    _phoneOtpController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    final auth = BetterAuthClient.instance;
    final res = await auth.signIn.email(
      email: _emailController.text,
      password: _passwordController.text,
      onSuccess: (ctx) {
        log("Success ${ctx.toString()}");
      },
      onError: (error) {
        setState(() => _error = error.message);
      },
    );
    if (res.error != null) {
      setState(() => _error = res.error!.message);
      return;
    }

    // Check if 2FA is required
    if (res.requiresTwoFactor == true) {
      setState(() => _requiresTwoFactor = true);
      return;
    }

    // Normal sign-in completed
    log("Sign in successful: ${res.user?.email}");
  }

  Future<void> _signUp() async {
    final auth = BetterAuthClient.instance;
    try {
      final res = await auth.signUp.email(
        email: _emailController.text,
        password: _passwordController.text,
        name: _nameController.text,
        data: {},
        onSuccess: (ctx) {
          log("Success ${ctx.toString()}");
        },
        onError: (error) {
          log("Sign up error: ${error.message}");
          setState(() => _error = error.message);
        },
      );
      if (res.error != null) {
        log("Sign up result error: ${res.error!.message}");
        setState(() => _error = res.error!.message);
      } else {
        log("Sign up successful: ${res.user?.email}");
      }
    } catch (e) {
      log("Sign up exception: $e");
      setState(() => _error = 'Exception: $e');
    }
  }

  Future<void> _signInAnonymously() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final auth = BetterAuthClient.instance;
      final res = await auth.signIn.anonymous(
        onSuccess: (user) {
          log("Anonymous sign-in success: ${user.id}");
        },
        onError: (error) {
          log("Anonymous sign-in error: ${error.message}");
          setState(() => _error = error.message);
        },
      );

      if (res.error != null) {
        log("Anonymous sign-in result error: ${res.error!.message}");
        setState(() => _error = res.error!.message);
      } else {
        log("Anonymous sign-in successful: ${res.user?.id}");
      }
    } catch (e) {
      log("Anonymous sign-in exception: $e");
      setState(() => _error = 'Exception: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _submit() async {
    if (_requiresTwoFactor) {
      // Handle 2FA verification
      if (_twoFactorController.text.isEmpty) {
        setState(() => _error = 'Please enter your 2FA code');
        return;
      }
      await _verifyTwoFactor();
      return;
    }

    // Handle anonymous/guest sign-in
    if (_tabController.index == 3) {
      await _signInAnonymously();
      return;
    }

    if (_isPhoneAuth) {
      if (_phoneOtpSent) {
        if (_phoneOtpController.text.isEmpty) {
          setState(() => _error = 'Please enter the OTP code');
          return;
        }
        await _verifyPhoneOtp();
      } else {
        if (_phoneController.text.isEmpty) {
          setState(() => _error = 'Please enter your phone number');
          return;
        }
        await _sendPhoneOtp();
      }
      return;
    }

    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() => _error = 'Please fill in all fields');
      return;
    }

    if (!_isSignIn && _nameController.text.isEmpty) {
      setState(() => _error = 'Please enter your name');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });
    if (_isSignIn) {
      await _signIn();
    } else {
      await _signUp();
    }
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _verifyTwoFactor() async {
    if (_twoFactorController.text.isEmpty) {
      setState(() => _error = 'Please enter your 2FA code');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final auth = BetterAuthClient.instance;
      final res = await auth.signIn.twoFactor(
        code: _twoFactorController.text,
        onSuccess: (ctx) {
          log("2FA verification success ${ctx.toString()}");
        },
        onError: (error) {
          setState(() => _error = error.message);
        },
      );

      if (res.error != null) {
        setState(() => _error = res.error!.message);
      } else {
        log("2FA sign in successful: ${res.user?.email}");
        setState(() => _requiresTwoFactor = false);
      }
    } catch (e) {
      log("2FA verification exception: $e");
      setState(() => _error = 'Exception: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _signInWithSocial(String provider) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await BetterAuthClient.instance.signIn.social(
        provider: Providers.gitlab,
        onSuccess: (context) {
          log("Success");
        },
        onError: (context) {
          setState(() => _error = context.message);
        },
      );
      if (result.error != null) {
        setState(() => _error = result.error!.message);
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _sendPhoneOtp() async {
    if (_phoneController.text.isEmpty) {
      setState(() => _error = 'Please enter your phone number');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await BetterAuthClient.instance.phoneNumber.sendOtp(
        phone: _phoneController.text,
        onSuccess: (response) {
          log("OTP sent successfully: $response");
          setState(() => _phoneOtpSent = true);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('OTP sent to your phone!')),
            );
          }
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

  Future<void> _verifyPhoneOtp() async {
    if (_phoneController.text.isEmpty || _phoneOtpController.text.isEmpty) {
      setState(() => _error = 'Please enter phone number and OTP');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await BetterAuthClient.instance.phoneNumber.verify(
        phone: _phoneController.text,
        otp: _phoneOtpController.text,
        onSuccess: (response) {
          log("Phone verification successful: $response");
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Phone verified successfully!')),
            );
          }
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
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Image.asset(
                            'assets/images/better-auth-logo-dark.9517453b.png',
                            width: 24,
                            height: 24,
                          ),
                          const SizedBox(width: 2),
                          const Text(
                            'BETTER-AUTH',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                      const Text(
                        '.',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0066FF),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF2A2A2A)),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    onTap: (index) {
                      setState(() {
                        _isSignIn = index == 0;
                        _isPhoneAuth = index == 2;
                        if (index != 2) {
                          _phoneOtpSent = false;
                          _phoneController.clear();
                          _phoneOtpController.clear();
                        }
                        _error = null;
                      });
                    },
                    tabs: const [
                      Tab(text: 'Sign In'),
                      Tab(text: 'Sign Up'),
                      Tab(text: 'Phone'),
                      Tab(text: 'Guest'),
                    ],
                    labelColor: const Color(0xFF0066FF),
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: const Color(0xFF0066FF),
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                  ),
                ),
                const SizedBox(height: 24),
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
                const SizedBox(height: 24),
                if (_tabController.index == 3) ...[
                  // Anonymous/Guest Authentication
                  Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.person_outline,
                          size: 80,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Sign in as Guest',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Continue without creating an account.\nYou can create an account later.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else if (_isPhoneAuth) ...[
                  // Phone Authentication Fields
                  const Text(
                    'Phone Number',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      hintText: '+1234567890',
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                    keyboardType: TextInputType.phone,
                    enabled: !_isLoading && !_phoneOtpSent,
                  ),
                  const SizedBox(height: 16),
                  if (_phoneOtpSent) ...[
                    const Text(
                      'OTP Code',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _phoneOtpController,
                      decoration: const InputDecoration(
                        hintText: 'Enter 6-digit OTP',
                        prefixIcon: Icon(Icons.security),
                      ),
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      enabled: !_isLoading,
                    ),
                    const SizedBox(height: 16),
                  ],
                ] else ...[
                  // Email Authentication Fields
                  if (!_isSignIn) ...[
                    const Text(
                      'Name',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        hintText: 'Enter your name',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      enabled: !_isLoading,
                    ),
                    const SizedBox(height: 16),
                  ],
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
                  const SizedBox(height: 16),
                  const Text(
                    'Password',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      hintText: 'Enter your password',
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                    obscureText: true,
                    enabled: !_isLoading,
                  ),
                  const SizedBox(height: 16),
                  if (_requiresTwoFactor) ...[
                    const Text(
                      'Two-Factor Authentication',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _twoFactorController,
                      decoration: const InputDecoration(
                        hintText: 'Enter 6-digit code',
                        prefixIcon: Icon(Icons.security),
                      ),
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      enabled: !_isLoading,
                    ),
                    const SizedBox(height: 16),
                  ],
                ],
                Row(
                  children: [
                    Checkbox(
                      value: _rememberMe,
                      onChanged: (value) {
                        setState(() {
                          _rememberMe = value ?? false;
                        });
                      },
                      fillColor: WidgetStateProperty.resolveWith((states) {
                        if (states.contains(WidgetState.selected)) {
                          return const Color(0xFF0066FF);
                        }
                        return const Color(0xFF2A2A2A);
                      }),
                    ),
                    const Text('Remember me'),
                    const Spacer(),
                    TextButton(
                      onPressed: _isLoading
                          ? null
                          : () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const ForgotPasswordScreen(),
                                ),
                              ),
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                if (_requiresTwoFactor) ...[
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton(
                      onPressed: _isLoading
                          ? null
                          : () {
                              setState(() {
                                _requiresTwoFactor = false;
                                _twoFactorController.clear();
                                _error = null;
                              });
                            },
                      child: const Text('Back to Sign In'),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            _requiresTwoFactor
                                ? 'Verify 2FA'
                                : _tabController.index == 3
                                    ? 'Continue as Guest'
                                    : _isPhoneAuth
                                        ? (_phoneOtpSent
                                            ? 'Verify OTP'
                                            : 'Send OTP')
                                        : (_isSignIn ? 'Sign In' : 'Sign Up'),
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 1,
                        color: const Color(0xFF2A2A2A),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'or',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 1,
                        color: const Color(0xFF2A2A2A),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton.icon(
                    onPressed:
                        _isLoading ? null : () => _signInWithSocial('github'),
                    icon: const Icon(Icons.code),
                    label: const Text(
                      'Continue with GitHub',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Center(
                  child: Text(
                    'Powered by better-auth',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
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
