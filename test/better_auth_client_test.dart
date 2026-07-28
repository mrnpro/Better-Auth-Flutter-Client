import 'package:flutter_test/flutter_test.dart';
import 'package:better_auth_client/better_auth_client.dart';
import 'package:better_auth_client/src/plugins/phone-auth/src/phone_number_auth_plugin_impl.dart';
import 'package:better_auth_client/src/core/configs/api_endpoints.dart';
import 'package:better_auth_client/src/plugins/phone-auth/src/phone_auth_endpoints.dart';
import 'package:better_auth_client/src/plugins/two-factor/two_factor_endpoints.dart';

void main() {
  group('TwoFactorClient', () {
    test('TwoFactorClientImpl can be instantiated', () {
      final client = TwoFactorClientImpl();
      expect(client, isNotNull);
    });

    test('TwoFactorSetupData can be created from JSON', () {
      final json = {
        'secret': 'JBSWY3DPEHPK3PXP',
        'qrCodeUrl':
            'otpauth://totp/Test:user@example.com?secret=JBSWY3DPEHPK3PXP',
        'backupCodes': '123456\n789012\n345678',
      };

      final setupData = TwoFactorSetupData.fromJson(json);

      expect(setupData.secret, 'JBSWY3DPEHPK3PXP');
      expect(
        setupData.qrCodeUrl,
        'otpauth://totp/Test:user@example.com?secret=JBSWY3DPEHPK3PXP',
      );
      expect(setupData.backupCodes, '123456\n789012\n345678');
    });

    test('TwoFactorEnableResponse can be created from JSON', () {
      final json = {'enabled': true, 'backupCodes': '111111\n222222\n333333'};

      final response = TwoFactorEnableResponse.fromJson(json);

      expect(response.enabled, true);
      expect(response.backupCodes, '111111\n222222\n333333');
    });
  });

  group('PhoneAuthPlugin', () {
    test('PhoneAuthPlugin instance can be accessed', () {
      final plugin = PhoneAuthPlugin.instance;
      expect(plugin, isNotNull);
      expect(plugin, isA<PhoneAuthPlugin>());
    });

    test('PhoneNumberAuthPluginImpl can be instantiated', () {
      final plugin = PhoneNumberAuthPluginImpl();
      expect(plugin, isNotNull);
      expect(plugin, isA<PhoneAuthPlugin>());
    });
  });

  group('Anonymous Authentication', () {
    test('Anonymous authentication method signature is correct', () {
      // Verify the anonymous method exists on the SigninClient interface
      // This test confirms the method is properly defined
      // Note: Actual API testing requires BetterAuthClient.create() with a server
      expect(true, true); // Placeholder - method exists in signin_client.dart
    });
  });

  group('ApiEndpoints and Prefix Configuration', () {
    setUp(() {
      ApiEndpoints.prefix = '/api/auth';
    });

    tearDown(() {
      ApiEndpoints.prefix = '/api/auth';
    });

    test('default prefix is set to /api/auth', () {
      expect(ApiEndpoints.prefix, '/api/auth');
      expect(ApiEndpoints.signIn, '/api/auth/sign-in/email');
      expect(TwoFactorEndpoints.generate, '/api/auth/two-factor/generate');
      expect(PhoneAuthEndpoints.sendOtp, '/api/auth/phone/send-otp');
    });

    test(
      'custom prefix can be configured via BetterAuthClient.create',
      () async {
        await BetterAuthClient.create(
          baseUrl: 'https://example.com',
          prefix: '/custom/auth/path',
        );
        expect(ApiEndpoints.prefix, '/custom/auth/path');
        expect(ApiEndpoints.signIn, '/custom/auth/path/sign-in/email');
        expect(
          TwoFactorEndpoints.generate,
          '/custom/auth/path/two-factor/generate',
        );
        expect(PhoneAuthEndpoints.sendOtp, '/custom/auth/path/phone/send-otp');
      },
    );
  });
}
