import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:better_auth_client/better_auth_client.dart';
import 'package:qr_flutter/qr_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = false;
  String? _error;
  User? _currentUser;
  bool _is2FAEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _check2FAStatus();
  }

  Future<void> _loadUser() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final user = await BetterAuthClient.instance.getCurrentUser();
      setState(() {
        _currentUser = user;
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _check2FAStatus() async {
    try {
      final result = await BetterAuthClient.instance.twoFactor.status();
      if (result.error == null) {
        setState(() => _is2FAEnabled = result.enabled ?? false);
      }
    } catch (e) {
      log('Error checking 2FA status: $e');
    }
  }

  Future<void> _enable2FA() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // First generate the 2FA setup data
      final generateResult =
          await BetterAuthClient.instance.twoFactor.generate();
      if (generateResult.error != null) {
        setState(() => _error = generateResult.error!.message);
        return;
      }

      if (generateResult.data == null) {
        setState(() => _error = 'No 2FA setup data received from server');
        return;
      }

      final setupData = generateResult.data!;
      if (setupData.secret.isEmpty ||
          setupData.qrCodeUrl.isEmpty ||
          setupData.backupCodes.isEmpty) {
        setState(() => _error = 'Invalid 2FA setup data received from server');
        return;
      }
      // Show dialog to scan QR code and enter code
      await _show2FASetupDialog(setupData);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _show2FASetupDialog(TwoFactorSetupData setupData) async {
    final codeController = TextEditingController();

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: const Text('Enable Two-Factor Authentication'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '1. Scan this QR code with your authenticator app:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child:
                        setupData.qrCodeUrl.isNotEmpty
                            ? SizedBox(
                              width: 200.0,
                              height: 200.0,
                              child: QrImageView(
                                data: setupData.qrCodeUrl,
                                version: QrVersions.auto,
                                size: 200.0,
                                errorStateBuilder:
                                    (cxt, err) => Center(
                                      child: Text(
                                        'QR Code Error: ${err.toString()}',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ),
                              ),
                            )
                            : const SizedBox(
                              width: 200.0,
                              height: 200.0,
                              child: Center(
                                child: Text(
                                  'QR Code URL not available',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                            ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '2. Or manually enter this secret:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      setupData.secret,
                      style: const TextStyle(fontFamily: 'monospace'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '3. Enter the 6-digit code from your app:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: codeController,
                    decoration: const InputDecoration(
                      hintText: '000000',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.yellow.shade50,
                      border: Border.all(color: Colors.yellow.shade300),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '⚠️ Important: Save these backup codes!',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          setupData.backupCodes,
                          style: const TextStyle(fontFamily: 'monospace'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (codeController.text.length != 6) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter a 6-digit code'),
                        ),
                      );
                    }
                    return;
                  }

                  // Enable 2FA with the code
                  final enableResult = await BetterAuthClient.instance.twoFactor
                      .enable(code: codeController.text);

                  if (!context.mounted) return;

                  if (enableResult.error != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: ${enableResult.error!.message}'),
                      ),
                    );
                  } else {
                    Navigator.pop(context);
                    setState(() => _is2FAEnabled = true);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('2FA enabled successfully!'),
                      ),
                    );
                  }
                },
                child: const Text('Enable 2FA'),
              ),
            ],
          ),
    );
  }

  Future<void> _disable2FA() async {
    final codeController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Disable Two-Factor Authentication'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Enter your 2FA code to disable two-factor authentication:',
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: codeController,
                  decoration: const InputDecoration(
                    hintText: '000000',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Disable'),
              ),
            ],
          ),
    );

    if (confirmed != true || codeController.text.length != 6) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await BetterAuthClient.instance.twoFactor.disable(
        code: codeController.text,
      );

      if (result.error != null) {
        setState(() => _error = result.error!.message);
      } else {
        setState(() => _is2FAEnabled = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('2FA disabled successfully')),
          );
        }
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _signOut() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await BetterAuthClient.instance.signOut(
        onSuccess: (context) {
          log("Successfully signed out");
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
      appBar: AppBar(
        title: const Text('Home'),
        backgroundColor: const Color(0xFF1A1A1A),
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _signOut,
            icon:
                _isLoading
                    ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                    : const Icon(Icons.logout),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              const Text(
                'Welcome to Better Auth!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'You are successfully authenticated.',
                style: TextStyle(color: Colors.grey.shade400, fontSize: 16),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF2A2A2A)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'User Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(
                      'Email',
                      _currentUser?.email ?? 'Not available',
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      'Name',
                      _currentUser?.name ?? 'Not available',
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow('ID', _currentUser?.id ?? 'Not available'),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF2A2A2A)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Two-Factor Authentication',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          _is2FAEnabled
                              ? Icons.security
                              : Icons.security_outlined,
                          color: _is2FAEnabled ? Colors.green : Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _is2FAEnabled ? '2FA is enabled' : '2FA is disabled',
                          style: TextStyle(
                            color: _is2FAEnabled ? Colors.green : Colors.grey,
                          ),
                        ),
                        const Spacer(),
                        if (_is2FAEnabled)
                          ElevatedButton(
                            onPressed: _isLoading ? null : _disable2FA,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade700,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Disable'),
                          )
                        else
                          ElevatedButton(
                            onPressed: _isLoading ? null : _enable2FA,
                            child: const Text('Enable 2FA'),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade400,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(value, style: const TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
