<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/tools/pub/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/to/develop-packages).
-->

# Better Auth Client

A comprehensive Flutter client for Better Auth that provides simple, secure, and feature-rich authentication for your Flutter applications.

## ✨ Features

### Core Authentication
- ✅ **Email & Password Authentication** - Sign in and sign up with email
- ✅ **Social Authentication** - GitHub, Google, and more OAuth providers
- ✅ **Two-Factor Authentication (2FA)** - TOTP-based 2FA with QR code generation
- ✅ **Phone Authentication** - OTP-based phone number authentication
- ✅ **Anonymous Authentication** - Guest sign-in without credentials

### Security & Session Management
- ✅ **User State Management** - Real-time authentication state with streams
- ✅ **Secure Storage** - Encrypted local storage for user data
- ✅ **Password Reset** - Email and phone-based password recovery
- ✅ **Session Verification** - Automatic session validation

### Developer Experience
- ✅ **Cross-platform Support** - iOS, Android, Web, Windows, macOS, Linux
- ✅ **Type-safe API** - Full Dart type safety with records
- ✅ **Error Handling** - Comprehensive error types and callbacks
- ✅ **Extensible Architecture** - Plugin-based system for easy extension

## Getting started

Add the package to your pubspec.yaml:

```yaml
dependencies:
  better_auth_client:
    git:
      url: https://github.com/mrnpro/Better-Auth-Flutter-Client.git
```

Then run:

```
flutter pub get
```

## Usage

### Initialize the client

Initialize the BetterAuthClient in your main method before running your app:

```dart
void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize the authentication client
  BetterAuthClient.create(
    baseUrl: 'https://your-auth-api.com',
    // Optional: Customize the API prefix (defaults to '/api/auth')
    prefix: '/custom/auth/prefix',
  );
  
  // Run your app
  runApp(MyApp());
}
```

This ensures that authentication is properly set up before your application starts and is available throughout your entire app. You can also specify an optional `prefix` parameter if your Better Auth endpoints live at a different base path than the default `/api/auth`.

### Email authentication

```dart
// Sign in
final auth = BetterAuthClient.instance;
await auth.signIn.email(
  email: 'user@example.com',
  password: 'password123',
  onSuccess: (context) {
    print("Success: ${context.toString()}");
  },
  onError: (error) {
    print("Error: ${error.message.toString()}");
  },
);

// Sign up
await auth.signUp.email(
  email: 'user@example.com',
  password: 'password123',
  name: "John Doe",
  image: "https://example.com/image.png",
  callbackUrl: "https://example.com/callback",
  data: {}, // Additional user data
  onSuccess: (context) {
    print("Success: ${context.toString()}");
  },
  onError: (error) {
    print("Error: ${error.toString()}");
  },
);
```

### Social authentication

```dart
await auth.signIn.social(
  provider: Providers.google, // or Providers.github
  onSuccess: (context) {
    print("Success");
  },
  onError: (context) {
    print("Error");
  },
);
```

### Get Current User

```dart
final currentUser = await auth.getCurrentUser();
print("Current User: ${currentUser.toString()}");
```

### Listen to authentication state changes

```dart
BetterAuthClient.instance.userChanges.listen((user) {
  if (user != null) {
    print("User is authenticated: ${user.email}");
  } else {
    print("User is not authenticated");
  }
});
```

### Two-Factor Authentication (2FA)

```dart
// Generate 2FA secret and QR code
final result = await auth.twoFactor.generate();
if (result.error == null) {
  final setupData = result.data!;
  print('Secret: ${setupData.secret}');
  print('QR Code URL: ${setupData.qrCodeUrl}');
  print('Backup Codes: ${setupData.backupCodes}');
}

// Enable 2FA with verification code
await auth.twoFactor.enable(
  code: '123456',
  onSuccess: (response) {
    print('2FA enabled! Backup codes: ${response.backupCodes}');
  },
  onError: (error) {
    print('Error: ${error.message}');
  },
);

// Verify 2FA code during sign-in
await auth.signIn.twoFactor(
  code: '123456',
  onSuccess: (user) {
    print('Authenticated with 2FA: ${user.email}');
  },
);

// Check 2FA status
final status = await auth.twoFactor.status();
print('2FA enabled: ${status.enabled}');

// Disable 2FA
await auth.twoFactor.disable(code: '123456');
```

### Phone Authentication

```dart
// Send OTP to phone number
await auth.phoneNumber.sendOtp(
  phone: '+25191741****',
  onSuccess: (response) {
    print('OTP sent successfully');
  },
  onError: (error) {
    print('Error: ${error.message}');
  },
);

// Verify OTP code
await auth.phoneNumber.verify(
  phone: '+25191741****',
  otp: '123456',
  onSuccess: (response) {
    print('Phone verified!');
  },
);

// Password reset via phone
await auth.phoneNumber.forgetPassword(
  phone: '+25191741****',
  onSuccess: (response) {
    print('Reset OTP sent');
  },
);

await auth.phoneNumber.resetPassword(
  otp: '123456',
  phoneNumber: '+25191741****',
  newPassword: 'newPassword123',
);
```

### Anonymous Authentication

```dart
// Sign in anonymously (guest mode)
await auth.signIn.anonymous(
  onSuccess: (user) {
    print('Guest user created: ${user.id}');
  },
  onError: (error) {
    print('Error: ${error.message}');
  },
);
```

### Sign out

```dart
await BetterAuthClient.instance.signOut();
```

## 📱 Example App

The package includes a complete example app demonstrating all authentication features:
- 4-tab authentication UI (Sign In, Sign Up, Phone, Guest)
- 2FA setup and management
- Phone OTP flow
- Anonymous sign-in
- User profile management

Check out the `example` folder in the repository for the full implementation.

## 🧪 Testing

The package includes comprehensive unit tests for all features:

```bash
flutter test
```

## 🤝 Contributing

We welcome contributions! This project has been enhanced with the following contributions:

### Recent Contributions
- ✅ **Two-Factor Authentication** - Full TOTP implementation with QR codes
- ✅ **Phone Authentication** - OTP-based phone verification system
- ✅ **Anonymous Authentication** - Guest mode functionality
- ✅ **Enhanced Example App** - Professional multi-tab authentication UI
- ✅ **Comprehensive Tests** - Unit tests for all major features

### How to Contribute

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'feat: add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Guidelines
- Follow the existing code style
- Add tests for new features
- Update documentation as needed
- Use conventional commit messages

If you encounter any issues or have feature requests, please file them in the [issues section](https://github.com/mrnpro/Better-Auth-Flutter-Client/issues).

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- [Better Auth](https://github.com/better-auth/better-auth) - The authentication backend
- All contributors who have helped improve this package

## 📞 Support

For questions and support, please open an issue on GitHub.