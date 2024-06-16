import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'home.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

enum SupportState {
  unknown,
  supported,
  unSupported,
}

class _AuthScreenState extends State<AuthScreen> {
  final LocalAuthentication auth = LocalAuthentication();
  final DatabaseReference _databaseReference = FirebaseDatabase.instance.ref();
  SupportState supportState = SupportState.unknown;
  List<BiometricType>? availableBiometrics;

  @override
  void initState() {
    super.initState();
    _checkBiometricSupport();
  }

  Future<void> _checkBiometricSupport() async {
    bool isSupported = false;
    List<BiometricType> biometricTypes = [];

    try {
      isSupported = await auth.isDeviceSupported();
      if (isSupported) {
        biometricTypes = await auth.getAvailableBiometrics();
      }
    } on PlatformException catch (e) {
      print('Error checking biometrics: $e');
    }

    if (!mounted) return;

    setState(() {
      supportState =
          isSupported ? SupportState.supported : SupportState.unSupported;
      availableBiometrics = biometricTypes;
    });
  }

  Future<void> authenticateWithBiometrics() async {
    try {
      final bool authenticated = await auth.authenticate(
        localizedReason: 'Authenticate with fingerprint or Face ID',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );

      if (!mounted) return;

      if (authenticated) {
        _setState(false); // Set state to false upon successful authentication
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Home()),
        );
      }
    } on PlatformException catch (e) {
      print('Error during authentication: $e');
    }
  }

  void _setState(bool state) {
    _databaseReference.child('state').set(state);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Biometric Safe Lock'),
        backgroundColor: const Color.fromARGB(255, 201, 182, 255),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              supportState == SupportState.supported
                  ? 'Biometric authentication is supported on this device'
                  : supportState == SupportState.unSupported
                      ? 'Biometric authentication is not supported on this device'
                      : 'Checking biometric support...',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: supportState == SupportState.supported
                    ? Colors.green
                    : supportState == SupportState.unSupported
                        ? Colors.red
                        : Colors.grey,
              ),
            ),
            const SizedBox(height: 20),
            Text(
                'Supported biometrics: ${availableBiometrics?.join(', ') ?? 'None'}'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: authenticateWithBiometrics,
              child: const Text("UNLOCK WITH BIOMETRICS"),
            ),
          ],
        ),
      ),
    );
  }
}
